module [
    Node,
    text,
    element,
    void_element,
    render,
    render_without_doc_type,
    dangerously_include_unescaped_html,
    # Content sectioning
    address,
    article,
    aside,
    footer,
    h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    header,
    main,
    nav,
    section,
    # Demarcating edits
    del,
    ins,
    # Document metadata
    base,
    head,
    link,
    meta,
    style,
    title,
    # Embedded content
    embed,
    iframe,
    object,
    picture,
    portal,
    source,
    # Forms
    button,
    datalist,
    fieldset,
    form,
    input,
    label,
    legend,
    meter,
    optgroup,
    option,
    output,
    progress,
    select,
    textarea,
    # Image and multimedia
    area,
    audio,
    img,
    map,
    track,
    video,
    # Inline text semantics
    a,
    abbr,
    b,
    bdi,
    bdo,
    br,
    cite,
    code,
    data,
    dfn,
    em,
    i,
    kbd,
    mark,
    q,
    rp,
    rt,
    ruby,
    s,
    samp,
    small,
    span,
    strong,
    sub,
    sup,
    time,
    u,
    var,
    wbr,
    # Interactive elements
    details,
    dialog,
    summary,
    # Main root
    html,
    # SVG and MathML
    math,
    svg,
    # Scripting
    canvas,
    noscript,
    script,
    # Sectioning root
    body,
    # Table content
    caption,
    col,
    colgroup,
    table,
    tbody,
    td,
    tfoot,
    th,
    thead,
    tr,
    # Text content
    blockquote,
    dd,
    div,
    dl,
    dt,
    figcaption,
    figure,
    hr,
    li,
    menu,
    ol,
    p,
    pre,
    ul,
    # Web components
    slot,
    template,
]

import Attribute exposing [Attribute, attribute]
import SafeStr exposing [SafeStr, escape, dangerously_mark_safe]

## An HTML node, either an HTML element or some text inside an HTML element.
Node : [Element Str U64 (List Attribute) (List Node), Text Str, UnescapedHtml Str]

## Create a `Text` node containing a string.
##
## The string will be escaped so that it's safely rendered as a text node even if the string contains HTML tags.
##
## ```
## expect
##     textNode = Html.text("<script>alert('hi')</script>")
##     Html.render_without_doc_type(textNode) == "&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;"
## ```
text : Str -> Node
text = Text

expect
    text_node = text("<script>alert('hi')</script>")
    render_without_doc_type(text_node) == "&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;"

## Mark a string as safe for HTML without actually escaping it.
##
## DO NOT use this function unless you're sure the input string is safe.
##
## NEVER use this function on user input; use the `text` function instead.
##
## ```
## expect
##     htmlNode = Html.dangerously_include_unescaped_html("<script>alert('This JavaScript will run')</script>")
##     Html.render_without_doc_type(htmlNode) == "<script>alert('This JavaScript will run')</script>"
## ```
dangerously_include_unescaped_html : Str -> Node
dangerously_include_unescaped_html = UnescapedHtml

expect
    html_node = dangerously_include_unescaped_html("<script>alert('This JavaScript will run')</script>")
    render_without_doc_type(html_node) == "<script>alert('This JavaScript will run')</script>"

## Define a non-standard HTML element.
## You can use this to add elements that are not already supported.
##
## For example, you could bring back the obsolete <blink> element and add some 90's nostalgia to your web page!
##
## ```
## blink : List Attribute, List Node -> Node
## blink = element("blink")
##
## blink [] [ text("This text is blinking!") ]
## ```
element : Str -> (List Attribute, List Node -> Node)
element = |tag_name|
    |attrs, children|
        # While building the node tree, calculate the size of Str it will render to
        with_tag = 2 * (3 + Str.count_utf8_bytes(tag_name))
        with_attrs = List.walk(
            attrs,
            with_tag,
            |acc, Attribute(name, val)|
                acc + Str.count_utf8_bytes(name) + Str.count_utf8_bytes(val) + 4,
        )
        total_size = List.walk(
            children,
            with_attrs,
            |acc, child|
                acc + node_size(child),
        )

        Element(tag_name, total_size, attrs, children)

## Define a non-standard HTML [void element](https://developer.mozilla.org/en-US/docs/Glossary/Void_element).
## A void element is an element that cannot have any children.
void_element : Str -> (List Attribute -> Node)
void_element = |tag_name|
    |attrs|
        # While building the node tree, calculate the size of Str it will render to
        with_tag = 2 * (3 + Str.count_utf8_bytes(tag_name))
        with_attrs = List.walk(
            attrs,
            with_tag,
            |acc, Attribute(name, val)|
                acc + Str.count_utf8_bytes(name) + Str.count_utf8_bytes(val) + 4,
        )

        Element(tag_name, with_attrs, attrs, [])

## Internal helper to calculate the size of a node
node_size : Node -> U64
node_size = |node|
    when node is
        Text(content) ->
            # We allocate more bytes than the original string had because we'll need extra bytes
            # if there are any characters we need to escape. My choice of the proportion 3/2
            # was arbitrary.
            Str.count_utf8_bytes(content) |> Num.div_ceil(2) |> Num.mul(3)

        UnescapedHtml(content) ->
            Str.count_utf8_bytes(content)

        Element(_, size, _, _) ->
            size

## Render a Node to an HTML string
##
## The output has no whitespace between nodes, to make it small.
## This is intended for generating full HTML documents, so it automatically adds `<!DOCTYPE html>` to the start of the string.
## See also `render_without_doc_type`.
render : Node -> Str
render = |node|
    buffer = SafeStr.reserve(dangerously_mark_safe("<!DOCTYPE html>"), node_size(node))

    render_help(buffer, node)
    |> SafeStr.to_str

expect
    example_document = html([], [body([], [p([(attribute("example"))("test")], [text("Hello, World!")])])])
    out = render(example_document)
    out == "<!DOCTYPE html><html><body><p example=\"test\">Hello, World!</p></body></html>"

expect
    example_document = html([], [body([], [p([(attribute("example"))("test")], [text("<script>alert('hi')</script>")])])])
    out = render(example_document)
    out == "<!DOCTYPE html><html><body><p example=\"test\">&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;</p></body></html>"

expect
    example_document = html([], [body([], [p([(attribute("example"))("test")], [dangerously_include_unescaped_html("<script>alert('hi')</script>")])])])
    out = render(example_document)
    out == "<!DOCTYPE html><html><body><p example=\"test\"><script>alert('hi')</script></p></body></html>"

expect
    example_document = html([], [body([], [base([]), link([]), meta([]), embed([]), source([]), input([]), area([]), img([]), track([]), br([]), wbr([]), col([]), hr([])])])
    out = render(example_document)
    out == "<!DOCTYPE html><html><body><base><link><meta><embed><source><input><area><img><track><br><wbr><col><hr></body></html>"

## Render a Node to a string, without a `!DOCTYPE` tag.
render_without_doc_type : Node -> Str
render_without_doc_type = |node|
    buffer = SafeStr.with_capacity(node_size(node))

    render_help(buffer, node)
    |> SafeStr.to_str

## An internal helper to render a node to a string buffer.
render_help : SafeStr, Node -> SafeStr
render_help = |buffer, node|
    when node is
        Text(content) ->
            SafeStr.concat(buffer, escape(content))

        UnescapedHtml(content) ->
            SafeStr.concat(buffer, dangerously_mark_safe(content))

        Element(tag_name, _, attrs, children) ->
            when tag_name is
                # Special case for void elements
                "base" | "link" | "meta" | "embed" | "source" | "input" | "area" | "img" | "track" | "br" | "wbr" | "col" | "hr" ->
                    buffer
                    |> SafeStr.concat(dangerously_mark_safe("<"))
                    |> SafeStr.concat(dangerously_mark_safe(tag_name))
                    |> |with_tag_name|
                        if List.is_empty(attrs) then
                            with_tag_name
                        else
                            List.walk(attrs, with_tag_name, render_attr)
                    |> SafeStr.concat(dangerously_mark_safe(">")) # Don't use self-closing tag syntax for void elements

                _ ->
                    buffer
                    |> SafeStr.concat(dangerously_mark_safe("<"))
                    |> SafeStr.concat(dangerously_mark_safe(tag_name))
                    |> |with_tag_name|
                        if List.is_empty(attrs) then
                            with_tag_name
                        else
                            List.walk(attrs, with_tag_name, render_attr)
                    |> SafeStr.concat(dangerously_mark_safe(">"))
                    |> |with_tag| List.walk(children, with_tag, render_help)
                    |> SafeStr.concat(dangerously_mark_safe("</"))
                    |> SafeStr.concat(dangerously_mark_safe(tag_name))
                    |> SafeStr.concat(dangerously_mark_safe(">"))

## An internal helper to render an attribute to a string buffer.
render_attr : SafeStr, Attribute -> SafeStr
render_attr = |buffer, Attribute(key, value)|
    buffer
    |> SafeStr.concat(dangerously_mark_safe(" "))
    |> SafeStr.concat(dangerously_mark_safe(key))
    |> SafeStr.concat(dangerously_mark_safe("=\""))
    |> SafeStr.concat(escape(value))
    |> SafeStr.concat(dangerously_mark_safe("\""))

# Content sectioning

## Construct a `address` element.
address : List Attribute, List Node -> Node
address = element("address")

## Construct a `article` element.
article : List Attribute, List Node -> Node
article = element("article")

## Construct a `aside` element.
aside : List Attribute, List Node -> Node
aside = element("aside")

## Construct a `footer` element.
footer : List Attribute, List Node -> Node
footer = element("footer")

## Construct a `h1` element.
h1 : List Attribute, List Node -> Node
h1 = element("h1")

## Construct a `h2` element.
h2 : List Attribute, List Node -> Node
h2 = element("h2")

## Construct a `h3` element.
h3 : List Attribute, List Node -> Node
h3 = element("h3")

## Construct a `h4` element.
h4 : List Attribute, List Node -> Node
h4 = element("h4")

## Construct a `h5` element.
h5 : List Attribute, List Node -> Node
h5 = element("h5")

## Construct a `h6` element.
h6 : List Attribute, List Node -> Node
h6 = element("h6")

## Construct a `header` element.
header : List Attribute, List Node -> Node
header = element("header")

## Construct a `main` element.
main : List Attribute, List Node -> Node
main = element("main")

## Construct a `nav` element.
nav : List Attribute, List Node -> Node
nav = element("nav")

## Construct a `section` element.
section : List Attribute, List Node -> Node
section = element("section")

# Demarcating edits

## Construct a `del` element.
del : List Attribute, List Node -> Node
del = element("del")

## Construct a `ins` element.
ins : List Attribute, List Node -> Node
ins = element("ins")

# Document metadata

## Construct a `base` element.
base : List Attribute -> Node
base = void_element("base")

## Construct a `head` element.
head : List Attribute, List Node -> Node
head = element("head")

## Construct a `link` element.
link : List Attribute -> Node
link = void_element("link")

## Construct a `meta` element.
meta : List Attribute -> Node
meta = void_element("meta")

## Construct a `style` element.
style : List Attribute, List Node -> Node
style = element("style")

## Construct a `title` element.
title : List Attribute, List Node -> Node
title = element("title")

# Embedded content

## Construct a `embed` element.
embed : List Attribute -> Node
embed = void_element("embed")

## Construct a `iframe` element.
iframe : List Attribute, List Node -> Node
iframe = element("iframe")

## Construct a `object` element.
object : List Attribute, List Node -> Node
object = element("object")

## Construct a `picture` element.
picture : List Attribute, List Node -> Node
picture = element("picture")

## Construct a `portal` element.
portal : List Attribute, List Node -> Node
portal = element("portal")

## Construct a `source` element.
source : List Attribute -> Node
source = void_element("source")

# Forms

## Construct a `button` element.
button : List Attribute, List Node -> Node
button = element("button")

## Construct a `datalist` element.
datalist : List Attribute, List Node -> Node
datalist = element("datalist")

## Construct a `fieldset` element.
fieldset : List Attribute, List Node -> Node
fieldset = element("fieldset")

## Construct a `form` element.
form : List Attribute, List Node -> Node
form = element("form")

## Construct a `input` element.
input : List Attribute -> Node
input = void_element("input")

## Construct a `label` element.
label : List Attribute, List Node -> Node
label = element("label")

## Construct a `legend` element.
legend : List Attribute, List Node -> Node
legend = element("legend")

## Construct a `meter` element.
meter : List Attribute, List Node -> Node
meter = element("meter")

## Construct a `optgroup` element.
optgroup : List Attribute, List Node -> Node
optgroup = element("optgroup")

## Construct a `option` element.
option : List Attribute, List Node -> Node
option = element("option")

## Construct a `output` element.
output : List Attribute, List Node -> Node
output = element("output")

## Construct a `progress` element.
progress : List Attribute, List Node -> Node
progress = element("progress")

## Construct a `select` element.
select : List Attribute, List Node -> Node
select = element("select")

## Construct a `textarea` element.
textarea : List Attribute, List Node -> Node
textarea = element("textarea")

# Image and multimedia

## Construct a `area` element.
area : List Attribute -> Node
area = void_element("area")

## Construct a `audio` element.
audio : List Attribute, List Node -> Node
audio = element("audio")

## Construct a `img` element.
img : List Attribute -> Node
img = void_element("img")

## Construct a `map` element.
map : List Attribute, List Node -> Node
map = element("map")

## Construct a `track` element.
track : List Attribute -> Node
track = void_element("track")

## Construct a `video` element.
video : List Attribute, List Node -> Node
video = element("video")

# Inline text semantics

## Construct a `a` element.
a : List Attribute, List Node -> Node
a = element("a")

## Construct a `abbr` element.
abbr : List Attribute, List Node -> Node
abbr = element("abbr")

## Construct a `b` element.
b : List Attribute, List Node -> Node
b = element("b")

## Construct a `bdi` element.
bdi : List Attribute, List Node -> Node
bdi = element("bdi")

## Construct a `bdo` element.
bdo : List Attribute, List Node -> Node
bdo = element("bdo")

## Construct a `br` element.
br : List Attribute -> Node
br = void_element("br")

## Construct a `cite` element.
cite : List Attribute, List Node -> Node
cite = element("cite")

## Construct a `code` element.
code : List Attribute, List Node -> Node
code = element("code")

## Construct a `data` element.
data : List Attribute, List Node -> Node
data = element("data")

## Construct a `dfn` element.
dfn : List Attribute, List Node -> Node
dfn = element("dfn")

## Construct a `em` element.
em : List Attribute, List Node -> Node
em = element("em")

## Construct a `i` element.
i : List Attribute, List Node -> Node
i = element("i")

## Construct a `kbd` element.
kbd : List Attribute, List Node -> Node
kbd = element("kbd")

## Construct a `mark` element.
mark : List Attribute, List Node -> Node
mark = element("mark")

## Construct a `q` element.
q : List Attribute, List Node -> Node
q = element("q")

## Construct a `rp` element.
rp : List Attribute, List Node -> Node
rp = element("rp")

## Construct a `rt` element.
rt : List Attribute, List Node -> Node
rt = element("rt")

## Construct a `ruby` element.
ruby : List Attribute, List Node -> Node
ruby = element("ruby")

## Construct a `s` element.
s : List Attribute, List Node -> Node
s = element("s")

## Construct a `samp` element.
samp : List Attribute, List Node -> Node
samp = element("samp")

## Construct a `small` element.
small : List Attribute, List Node -> Node
small = element("small")

## Construct a `span` element.
span : List Attribute, List Node -> Node
span = element("span")

## Construct a `strong` element.
strong : List Attribute, List Node -> Node
strong = element("strong")

## Construct a `sub` element.
sub : List Attribute, List Node -> Node
sub = element("sub")

## Construct a `sup` element.
sup : List Attribute, List Node -> Node
sup = element("sup")

## Construct a `time` element.
time : List Attribute, List Node -> Node
time = element("time")

## Construct a `u` element.
u : List Attribute, List Node -> Node
u = element("u")

## Construct a `var` element.
var : List Attribute, List Node -> Node
var = element("var")

## Construct a `wbr` element.
wbr : List Attribute -> Node
wbr = void_element("wbr")

# Interactive elements

## Construct a `details` element.
details : List Attribute, List Node -> Node
details = element("details")

## Construct a `dialog` element.
dialog : List Attribute, List Node -> Node
dialog = element("dialog")

## Construct a `summary` element.
summary : List Attribute, List Node -> Node
summary = element("summary")

# Main root

## Construct a `html` element.
html : List Attribute, List Node -> Node
html = element("html")

# SVG and MathML

## Construct a `math` element.
math : List Attribute, List Node -> Node
math = element("math")

## Construct a `svg` element.
svg : List Attribute, List Node -> Node
svg = element("svg")

# Scripting

## Construct a `canvas` element.
canvas : List Attribute, List Node -> Node
canvas = element("canvas")

## Construct a `noscript` element.
noscript : List Attribute, List Node -> Node
noscript = element("noscript")

## Construct a `script` element.
script : List Attribute, List Node -> Node
script = element("script")

# Sectioning root

## Construct a `body` element.
body : List Attribute, List Node -> Node
body = element("body")

# Table content

## Construct a `caption` element.
caption : List Attribute, List Node -> Node
caption = element("caption")

## Construct a `col` element.
col : List Attribute -> Node
col = void_element("col")

## Construct a `colgroup` element.
colgroup : List Attribute, List Node -> Node
colgroup = element("colgroup")

## Construct a `table` element.
table : List Attribute, List Node -> Node
table = element("table")

## Construct a `tbody` element.
tbody : List Attribute, List Node -> Node
tbody = element("tbody")

## Construct a `td` element.
td : List Attribute, List Node -> Node
td = element("td")

## Construct a `tfoot` element.
tfoot : List Attribute, List Node -> Node
tfoot = element("tfoot")

## Construct a `th` element.
th : List Attribute, List Node -> Node
th = element("th")

## Construct a `thead` element.
thead : List Attribute, List Node -> Node
thead = element("thead")

## Construct a `tr` element.
tr : List Attribute, List Node -> Node
tr = element("tr")

# Text content

## Construct a `blockquote` element.
blockquote : List Attribute, List Node -> Node
blockquote = element("blockquote")

## Construct a `dd` element.
dd : List Attribute, List Node -> Node
dd = element("dd")

## Construct a `div` element.
div : List Attribute, List Node -> Node
div = element("div")

## Construct a `dl` element.
dl : List Attribute, List Node -> Node
dl = element("dl")

## Construct a `dt` element.
dt : List Attribute, List Node -> Node
dt = element("dt")

## Construct a `figcaption` element.
figcaption : List Attribute, List Node -> Node
figcaption = element("figcaption")

## Construct a `figure` element.
figure : List Attribute, List Node -> Node
figure = element("figure")

## Construct a `hr` element.
hr : List Attribute -> Node
hr = void_element("hr")

## Construct a `li` element.
li : List Attribute, List Node -> Node
li = element("li")

## Construct a `menu` element.
menu : List Attribute, List Node -> Node
menu = element("menu")

## Construct a `ol` element.
ol : List Attribute, List Node -> Node
ol = element("ol")

## Construct a `p` element.
p : List Attribute, List Node -> Node
p = element("p")

## Construct a `pre` element.
pre : List Attribute, List Node -> Node
pre = element("pre")

## Construct a `ul` element.
ul : List Attribute, List Node -> Node
ul = element("ul")

# Web components

## Construct a `slot` element.
slot : List Attribute, List Node -> Node
slot = element("slot")

## Construct a `template` element.
template : List Attribute, List Node -> Node
template = element("template")
