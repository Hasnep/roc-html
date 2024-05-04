module [
    SafeStr,
    toStr,
    escape,
    dangerouslyMarkSafe,
    withCapacity,
    concat,
    reserve,
]

## An opaque type used to keep track of the fact that we know a string is HTML-safe.
SafeStr := Str

## Escape a string so that it can safely be used in HTML text nodes or attributes.
## This is the function that should usually be used for converting a Str to a SafeStr.
escape : Str -> SafeStr
escape = \str ->
    (encodedBytes, isOriginalStringFine) =
        # We allocate more bytes than the original string had because we'll need extra bytes
        # if there are any characters we need to escape. My choice of the proportion 3/2
        # was arbitrary.
        capacity = Str.countUtf8Bytes str |> Num.divCeil 2 |> Num.mul 3
        bytes = List.withCapacity capacity
        # Look at each byte in the string. It's important to look at each codepoint, not the
        # whole graheme. (See the test below.) Because we're only looking for `"`, `&`, `'`,
        # `<`, and `>`, each of which are one byte, it's fine to just iterate over the bytes.
        # In UTF-8, the only bytes that ever start with a 0 are the single-byte codepoints, so
        # these bytes will never appear in the middle of a codepoint.
        Str.walkUtf8 str (bytes, Bool.true) \(bytesSoFar, isOriginalStringFineSoFar), byte ->
            when byte is
                34 -> (List.concat bytesSoFar (Str.toUtf8 "&quot;"), Bool.false) # " must be escaped
                38 -> (List.concat bytesSoFar (Str.toUtf8 "&amp;"), Bool.false) # & must be escaped
                39 -> (List.concat bytesSoFar (Str.toUtf8 "&#39;"), Bool.false) # ' must be escaped
                60 -> (List.concat bytesSoFar (Str.toUtf8 "&lt;"), Bool.false) # < must be escaped
                62 -> (List.concat bytesSoFar (Str.toUtf8 "&gt;"), Bool.false) # > must be escaped
                _ -> (List.append bytesSoFar byte, isOriginalStringFineSoFar) # All other bytes are fine!
    if isOriginalStringFine then
        # If we didn't do any replacements, we might as well use the original string
        # so that Roc can free encodedBytes and avoid re-validating the UTF-8.
        @SafeStr str
    else
        when Str.fromUtf8 encodedBytes is
            Ok s -> @SafeStr s
            Err (BadUtf8 _ _) ->
                crash "SafeStr.escape: bad utf8. This should not be possible; please report this bug to roc-html."

## Convert a SafeStr to a regular Str.
toStr : SafeStr -> Str
toStr = \@SafeStr str -> str

expect toStr (escape "<h1>abc</h1>") == "&lt;h1&gt;abc&lt;/h1&gt;"
expect toStr (escape "abc") == "abc"
expect toStr (escape "折り紙🕊") == "折り紙🕊"
expect toStr (escape "é é") == "é é"
expect toStr (escape "﷽ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி") == "﷽ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி"
expect toStr (escape "﷽&ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி") == "﷽&amp;ᄀᄀᄀ각ᆨᆨ🇺🇸각नीநி"
expect toStr (escape "'&\"<>") == "&#39;&amp;&quot;&lt;&gt;"
# Note: This sometimes displays incorrectly in VSCode. It's a family emoji.
expect toStr (escape "👩‍👩‍👦‍👦") == "👩‍👩‍👦‍👦"
expect toStr (escape "&👩‍👩‍👦‍👦&") == "&amp;👩‍👩‍👦‍👦&amp;"
expect toStr (escape "`~!@#$%^&*()-=_+[]\\{}|;':\",./<>?") == "`~!@#$%^&amp;*()-=_+[]\\{}|;&#39;:&quot;,./&lt;&gt;?"
# Even though this string doesn't contain the *grapheme* "<" or the grapheme ">",
# it does contain the *codepoints* "<" and ">". The browser still interprets them
# as HTML tags, so it's important to escape them.
expect toStr (escape "something؀<h1>͏bad؀</h1>͏something") == "something؀&lt;h1&gt;͏bad؀&lt;/h1&gt;͏something"

## Mark a string as safe for HTML without actually escaping it.
## DO NOT use this function unless you know the input string is safe.
## NEVER use this function on user input.
dangerouslyMarkSafe : Str -> SafeStr
dangerouslyMarkSafe = \str -> @SafeStr str

expect
    badStr = "<script>alert('&bad' + \"script\")</script>"
    toStr (dangerouslyMarkSafe badStr) == badStr

## The SafeStr equivalent of Str.withCapacity
withCapacity : U64 -> SafeStr
withCapacity = \capacity ->
    @SafeStr (Str.withCapacity capacity)

expect toStr (withCapacity 10) == ""

## The SafeStr equivalent of Str.reserve
reserve : SafeStr, U64 -> SafeStr
reserve = \@SafeStr str, additionalCapacity ->
    @SafeStr (Str.reserve str additionalCapacity)

expect "abc>" |> escape |> reserve 50 |> toStr == "abc&gt;"

## The SafeStr equivalent of Str.concat
concat : SafeStr, SafeStr -> SafeStr
concat = \@SafeStr str1, @SafeStr str2 ->
    # If two strings are HTML-safe, their concatenation must be too.
    @SafeStr (Str.concat str1 str2)

expect escape "3>2" |> concat (escape "2<3") |> toStr == "3&gt;22&lt;3"
