module [
    SafeStr,
    to_str,
    escape,
    dangerously_mark_safe,
    with_capacity,
    concat,
    reserve,
]

## An opaque type used to keep track of the fact that we know a string is HTML-safe.
SafeStr := Str

## Escape a string so that it can safely be used in HTML text nodes or attributes.
## This is the function that should usually be used for converting a Str to a SafeStr.
escape : Str -> SafeStr
escape = |str|
    (encoded_bytes, is_original_string_fine) =
        # We allocate more bytes than the original string had because we'll need extra bytes
        # if there are any characters we need to escape. My choice of the proportion 3/2
        # was arbitrary.
        capacity = Str.count_utf8_bytes(str) |> Num.div_ceil(2) |> Num.mul(3)
        bytes = List.with_capacity(capacity)
        # Look at each byte in the string. It's important to look at each codepoint, not the
        # whole graheme. (See the test below.) Because we're only looking for `"`, `&`, `'`,
        # `<`, and `>`, each of which are one byte, it's fine to just iterate over the bytes.
        # In UTF-8, the only bytes that ever start with a 0 are the single-byte codepoints, so
        # these bytes will never appear in the middle of a codepoint.
        Str.walk_utf8(
            str,
            (bytes, Bool.true),
            |(bytes_so_far, is_original_string_fine_so_far), byte|
                when byte is
                    34 -> (List.concat(bytes_so_far, Str.to_utf8("&quot;")), Bool.false) # " must be escaped
                    38 -> (List.concat(bytes_so_far, Str.to_utf8("&amp;")), Bool.false) # & must be escaped
                    39 -> (List.concat(bytes_so_far, Str.to_utf8("&#39;")), Bool.false) # ' must be escaped
                    60 -> (List.concat(bytes_so_far, Str.to_utf8("&lt;")), Bool.false) # < must be escaped
                    62 -> (List.concat(bytes_so_far, Str.to_utf8("&gt;")), Bool.false) # > must be escaped
                    _ -> (List.append(bytes_so_far, byte), is_original_string_fine_so_far),
        ) # All other bytes are fine!
    if is_original_string_fine then
        # If we didn't do any replacements, we might as well use the original string
        # so that Roc can free encodedBytes and avoid re-validating the UTF-8.
        @SafeStr(str)
    else
        when Str.from_utf8(encoded_bytes) is
            Ok(s) -> @SafeStr(s)
            Err(BadUtf8(_)) ->
                crash("SafeStr.escape: bad utf8. This should not be possible; please report this bug to roc-html.")

## Convert a SafeStr to a regular Str.
to_str : SafeStr -> Str
to_str = |@SafeStr(str)| str

expect to_str(escape("<h1>abc</h1>")) == "&lt;h1&gt;abc&lt;/h1&gt;"
expect to_str(escape("abc")) == "abc"
expect to_str(escape("折り紙🕊")) == "折り紙🕊"
expect to_str(escape("é é")) == "é é"
expect to_str(escape("﷽ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி")) == "﷽ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி"
expect to_str(escape("﷽&ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி")) == "﷽&amp;ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி"
expect to_str(escape("'&\"<>")) == "&#39;&amp;&quot;&lt;&gt;"
# Note: This sometimes displays incorrectly in VSCode. It's a family emoji.
expect to_str(escape("👩‍👩‍👦‍👦")) == "👩‍👩‍👦‍👦"
expect to_str(escape("&👩‍👩‍👦‍👦&")) == "&amp;👩‍👩‍👦‍👦&amp;"
expect to_str(escape("`~!@#$%^&*()-=_+[]\\{}|;':\",./<>?")) == "`~!@#$%^&amp;*()-=_+[]\\{}|;&#39;:&quot;,./&lt;&gt;?"
# Even though this string doesn't contain the *grapheme* "<" or the grapheme ">",
# it does contain the *codepoints* "<" and ">". The browser still interprets them
# as HTML tags, so it's important to escape them.
expect to_str(escape("something؀<h1>͏bad؀</h1>͏something")) == "something؀&lt;h1&gt;͏bad؀&lt;/h1&gt;͏something"

## Mark a string as safe for HTML without actually escaping it.
## DO NOT use this function unless you know the input string is safe.
## NEVER use this function on user input.
dangerously_mark_safe : Str -> SafeStr
dangerously_mark_safe = |str| @SafeStr(str)

expect
    bad_str = "<script>alert('&bad' + \"script\")</script>"
    to_str(dangerously_mark_safe(bad_str)) == bad_str

## The SafeStr equivalent of Str.withCapacity
with_capacity : U64 -> SafeStr
with_capacity = |capacity|
    @SafeStr(Str.with_capacity(capacity))

expect to_str(with_capacity(10)) == ""

## The SafeStr equivalent of Str.reserve
reserve : SafeStr, U64 -> SafeStr
reserve = |@SafeStr(str), additional_capacity|
    @SafeStr(Str.reserve(str, additional_capacity))

expect "abc>" |> escape |> reserve(50) |> to_str == "abc&gt;"

## The SafeStr equivalent of Str.concat
concat : SafeStr, SafeStr -> SafeStr
concat = |@SafeStr(str1), @SafeStr(str2)|
    # If two strings are HTML-safe, their concatenation must be too.
    @SafeStr(Str.concat(str1, str2))

expect escape("3>2") |> concat(escape("2<3")) |> to_str == "3&gt;22&lt;3"
