module [
    Node,
    text,
    element,
    voidElement,
    render,
    renderWithoutDocType,
    dangerouslyIncludeUnescapedHtml,
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
import SafeStr exposing [SafeStr, escape, dangerouslyMarkSafe]

## An HTML node, either an HTML element or some text inside an HTML element.
Node : [Element Str U64 (List Attribute) (List Node), Text Str, UnescapedHtml Str]

## Create a `Text` node containing a string.
##
## The string will be escaped so that it's safely rendered as a text node even if the string contains HTML tags.
##
## ```
## expect
##     textNode = Html.text "<script>alert('hi')</script>"
##     Html.renderWithoutDocType textNode == "&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;"
## ```
text : Str -> Node
text = Text

expect
    textNode = text "<script>alert('hi')</script>"
    renderWithoutDocType textNode == "&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;"

## Mark a string as safe for HTML without actually escaping it.
##
## DO NOT use this function unless you're sure the input string is safe.
##
## NEVER use this function on user input; use the `text` function instead.
##
## ```
## expect
##     htmlNode = Html.dangerouslyIncludeUnescapedHtml "<script>alert('This JavaScript will run')</script>"
##     Html.renderWithoutDocType htmlNode ==  "<script>alert('This JavaScript will run')</script>"
## ```
dangerouslyIncludeUnescapedHtml : Str -> Node
dangerouslyIncludeUnescapedHtml = UnescapedHtml

expect
    htmlNode = dangerouslyIncludeUnescapedHtml "<script>alert('This JavaScript will run')</script>"
    renderWithoutDocType htmlNode == "<script>alert('This JavaScript will run')</script>"

## Define a non-standard HTML element.
## You can use this to add elements that are not already supported.
##
## For example, you could bring back the obsolete <blink> element and add some 90's nostalgia to your web page!
##
## ```
## blink : List Attribute, List Node -> Node
## blink = element "blink"
##
## blink [] [ text "This text is blinking!" ]
## ```
element : Str -> (List Attribute, List Node -> Node)
element = \tagName ->
    \attrs, children ->
        # While building the node tree, calculate the size of Str it will render to
        withTag = 2 * (3 + Str.countUtf8Bytes tagName)
        withAttrs = List.walk attrs withTag \acc, Attribute name val ->
            acc + Str.countUtf8Bytes name + Str.countUtf8Bytes val + 4
        totalSize = List.walk children withAttrs \acc, child ->
            acc + nodeSize child

        Element tagName totalSize attrs children

## Define a non-standard HTML [void element](https://developer.mozilla.org/en-US/docs/Glossary/Void_element).
## A void element is an element that cannot have any children.
voidElement : Str -> (List Attribute -> Node)
voidElement = \tagName ->
    \attrs ->
        # While building the node tree, calculate the size of Str it will render to
        withTag = 2 * (3 + Str.countUtf8Bytes tagName)
        withAttrs = List.walk attrs withTag \acc, Attribute name val ->
            acc + Str.countUtf8Bytes name + Str.countUtf8Bytes val + 4

        Element tagName withAttrs attrs []

## Internal helper to calculate the size of a node
nodeSize : Node -> U64
nodeSize = \node ->
    when node is
        Text content ->
            # We allocate more bytes than the original string had because we'll need extra bytes
            # if there are any characters we need to escape. My choice of the proportion 3/2
            # was arbitrary.
            Str.countUtf8Bytes content |> Num.divCeil 2 |> Num.mul 3

        UnescapedHtml content ->
            Str.countUtf8Bytes content

        Element _ size _ _ ->
            size

## Render a Node to an HTML string
##
## The output has no whitespace between nodes, to make it small.
## This is intended for generating full HTML documents, so it automatically adds `<!DOCTYPE html>` to the start of the string.
## See also `renderWithoutDocType`.
render : Node -> Str
render = \node ->
    buffer = SafeStr.reserve (dangerouslyMarkSafe "<!DOCTYPE html>") (nodeSize node)

    renderHelp buffer node
    |> SafeStr.toStr

expect
    exampleDocument = html [] [body [] [p [(attribute "example") "test"] [text "Hello, World!"]]]
    out = render exampleDocument
    out == "<!DOCTYPE html><html><body><p example=\"test\">Hello, World!</p></body></html>"

expect
    exampleDocument = html [] [body [] [p [(attribute "example") "test"] [text "<script>alert('hi')</script>"]]]
    out = render exampleDocument
    out == "<!DOCTYPE html><html><body><p example=\"test\">&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;</p></body></html>"

expect
    exampleDocument = html [] [body [] [p [(attribute "example") "test"] [dangerouslyIncludeUnescapedHtml "<script>alert('hi')</script>"]]]
    out = render exampleDocument
    out == "<!DOCTYPE html><html><body><p example=\"test\"><script>alert('hi')</script></p></body></html>"

expect
    exampleDocument = html [] [body [] [base [], link [], meta [], embed [], source [], input [], area [], img [], track [], br [], wbr [], col [], hr []]]
    out = render exampleDocument
    out == "<!DOCTYPE html><html><body><base/><link/><meta/><embed/><source/><input/><area/><img/><track/><br/><wbr/><col/><hr/></body></html>"

## Render a Node to a string, without a `!DOCTYPE` tag.
renderWithoutDocType : Node -> Str
renderWithoutDocType = \node ->
    buffer = SafeStr.withCapacity (nodeSize node)

    renderHelp buffer node
    |> SafeStr.toStr

## An internal helper to render a node to a string buffer.
renderHelp : SafeStr, Node -> SafeStr
renderHelp = \buffer, node ->
    when node is
        Text content ->
            SafeStr.concat buffer (escape content)

        UnescapedHtml content ->
            SafeStr.concat buffer (dangerouslyMarkSafe content)

        Element tagName _ attrs children ->
            when tagName is
                # Special case for void elements
                "base" | "link" | "meta" | "embed" | "source" | "input" | "area" | "img" | "track" | "br" | "wbr" | "col" | "hr" ->
                    buffer
                    |> SafeStr.concat (dangerouslyMarkSafe "<")
                    |> SafeStr.concat (dangerouslyMarkSafe tagName)
                    |> \withTagName ->
                        if List.isEmpty attrs then
                            withTagName
                        else
                            List.walk attrs withTagName renderAttr
                    |> SafeStr.concat (dangerouslyMarkSafe "/>") # Use self-closing tag syntax for compatibility with XHTML

                _ ->
                    buffer
                    |> SafeStr.concat (dangerouslyMarkSafe "<")
                    |> SafeStr.concat (dangerouslyMarkSafe tagName)
                    |> \withTagName ->
                        if List.isEmpty attrs then
                            withTagName
                        else
                            List.walk attrs withTagName renderAttr
                    |> SafeStr.concat (dangerouslyMarkSafe ">")
                    |> \withTag -> List.walk children withTag renderHelp
                    |> SafeStr.concat (dangerouslyMarkSafe "</")
                    |> SafeStr.concat (dangerouslyMarkSafe tagName)
                    |> SafeStr.concat (dangerouslyMarkSafe ">")

## An internal helper to render an attribute to a string buffer.
renderAttr : SafeStr, Attribute -> SafeStr
renderAttr = \buffer, Attribute key value ->
    buffer
    |> SafeStr.concat (dangerouslyMarkSafe " ")
    |> SafeStr.concat (dangerouslyMarkSafe key)
    |> SafeStr.concat (dangerouslyMarkSafe "=\"")
    |> SafeStr.concat (escape value)
    |> SafeStr.concat (dangerouslyMarkSafe "\"")

# Content sectioning

## Construct a `address` element.
address : List Attribute, List Node -> Node
address = element "address"

## Construct a `article` element.
article : List Attribute, List Node -> Node
article = element "article"

## Construct a `aside` element.
aside : List Attribute, List Node -> Node
aside = element "aside"

## Construct a `footer` element.
footer : List Attribute, List Node -> Node
footer = element "footer"

## Construct a `h1` element.
h1 : List Attribute, List Node -> Node
h1 = element "h1"

## Construct a `h2` element.
h2 : List Attribute, List Node -> Node
h2 = element "h2"

## Construct a `h3` element.
h3 : List Attribute, List Node -> Node
h3 = element "h3"

## Construct a `h4` element.
h4 : List Attribute, List Node -> Node
h4 = element "h4"

## Construct a `h5` element.
h5 : List Attribute, List Node -> Node
h5 = element "h5"

## Construct a `h6` element.
h6 : List Attribute, List Node -> Node
h6 = element "h6"

## Construct a `header` element.
header : List Attribute, List Node -> Node
header = element "header"

## Construct a `main` element.
main : List Attribute, List Node -> Node
main = element "main"

## Construct a `nav` element.
nav : List Attribute, List Node -> Node
nav = element "nav"

## Construct a `section` element.
section : List Attribute, List Node -> Node
section = element "section"

# Demarcating edits

## Construct a `del` element.
del : List Attribute, List Node -> Node
del = element "del"

## Construct a `ins` element.
ins : List Attribute, List Node -> Node
ins = element "ins"

# Document metadata

## Construct a `base` element.
base : List Attribute -> Node
base = voidElement "base"

## Construct a `head` element.
head : List Attribute, List Node -> Node
head = element "head"

## Construct a `link` element.
link : List Attribute -> Node
link = voidElement "link"

## Construct a `meta` element.
meta : List Attribute -> Node
meta = voidElement "meta"

## Construct a `style` element.
style : List Attribute, List Node -> Node
style = element "style"

## Construct a `title` element.
title : List Attribute, List Node -> Node
title = element "title"

# Embedded content

## Construct a `embed` element.
embed : List Attribute -> Node
embed = voidElement "embed"

## Construct a `iframe` element.
iframe : List Attribute, List Node -> Node
iframe = element "iframe"

## Construct a `object` element.
object : List Attribute, List Node -> Node
object = element "object"

## Construct a `picture` element.
picture : List Attribute, List Node -> Node
picture = element "picture"

## Construct a `portal` element.
portal : List Attribute, List Node -> Node
portal = element "portal"

## Construct a `source` element.
source : List Attribute -> Node
source = voidElement "source"

# Forms

## Construct a `button` element.
button : List Attribute, List Node -> Node
button = element "button"

## Construct a `datalist` element.
datalist : List Attribute, List Node -> Node
datalist = element "datalist"

## Construct a `fieldset` element.
fieldset : List Attribute, List Node -> Node
fieldset = element "fieldset"

## Construct a `form` element.
form : List Attribute, List Node -> Node
form = element "form"

## Construct a `input` element.
input : List Attribute -> Node
input = voidElement "input"

## Construct a `label` element.
label : List Attribute, List Node -> Node
label = element "label"

## Construct a `legend` element.
legend : List Attribute, List Node -> Node
legend = element "legend"

## Construct a `meter` element.
meter : List Attribute, List Node -> Node
meter = element "meter"

## Construct a `optgroup` element.
optgroup : List Attribute, List Node -> Node
optgroup = element "optgroup"

## Construct a `option` element.
option : List Attribute, List Node -> Node
option = element "option"

## Construct a `output` element.
output : List Attribute, List Node -> Node
output = element "output"

## Construct a `progress` element.
progress : List Attribute, List Node -> Node
progress = element "progress"

## Construct a `select` element.
select : List Attribute, List Node -> Node
select = element "select"

## Construct a `textarea` element.
textarea : List Attribute, List Node -> Node
textarea = element "textarea"

# Image and multimedia

## Construct a `area` element.
area : List Attribute -> Node
area = voidElement "area"

## Construct a `audio` element.
audio : List Attribute, List Node -> Node
audio = element "audio"

## Construct a `img` element.
img : List Attribute -> Node
img = voidElement "img"

## Construct a `map` element.
map : List Attribute, List Node -> Node
map = element "map"

## Construct a `track` element.
track : List Attribute -> Node
track = voidElement "track"

## Construct a `video` element.
video : List Attribute, List Node -> Node
video = element "video"

# Inline text semantics

## Construct a `a` element.
a : List Attribute, List Node -> Node
a = element "a"

## Construct a `abbr` element.
abbr : List Attribute, List Node -> Node
abbr = element "abbr"

## Construct a `b` element.
b : List Attribute, List Node -> Node
b = element "b"

## Construct a `bdi` element.
bdi : List Attribute, List Node -> Node
bdi = element "bdi"

## Construct a `bdo` element.
bdo : List Attribute, List Node -> Node
bdo = element "bdo"

## Construct a `br` element.
br : List Attribute -> Node
br = voidElement "br"

## Construct a `cite` element.
cite : List Attribute, List Node -> Node
cite = element "cite"

## Construct a `code` element.
code : List Attribute, List Node -> Node
code = element "code"

## Construct a `data` element.
data : List Attribute, List Node -> Node
data = element "data"

## Construct a `dfn` element.
dfn : List Attribute, List Node -> Node
dfn = element "dfn"

## Construct a `em` element.
em : List Attribute, List Node -> Node
em = element "em"

## Construct a `i` element.
i : List Attribute, List Node -> Node
i = element "i"

## Construct a `kbd` element.
kbd : List Attribute, List Node -> Node
kbd = element "kbd"

## Construct a `mark` element.
mark : List Attribute, List Node -> Node
mark = element "mark"

## Construct a `q` element.
q : List Attribute, List Node -> Node
q = element "q"

## Construct a `rp` element.
rp : List Attribute, List Node -> Node
rp = element "rp"

## Construct a `rt` element.
rt : List Attribute, List Node -> Node
rt = element "rt"

## Construct a `ruby` element.
ruby : List Attribute, List Node -> Node
ruby = element "ruby"

## Construct a `s` element.
s : List Attribute, List Node -> Node
s = element "s"

## Construct a `samp` element.
samp : List Attribute, List Node -> Node
samp = element "samp"

## Construct a `small` element.
small : List Attribute, List Node -> Node
small = element "small"

## Construct a `span` element.
span : List Attribute, List Node -> Node
span = element "span"

## Construct a `strong` element.
strong : List Attribute, List Node -> Node
strong = element "strong"

## Construct a `sub` element.
sub : List Attribute, List Node -> Node
sub = element "sub"

## Construct a `sup` element.
sup : List Attribute, List Node -> Node
sup = element "sup"

## Construct a `time` element.
time : List Attribute, List Node -> Node
time = element "time"

## Construct a `u` element.
u : List Attribute, List Node -> Node
u = element "u"

## Construct a `var` element.
var : List Attribute, List Node -> Node
var = element "var"

## Construct a `wbr` element.
wbr : List Attribute -> Node
wbr = voidElement "wbr"

# Interactive elements

## Construct a `details` element.
details : List Attribute, List Node -> Node
details = element "details"

## Construct a `dialog` element.
dialog : List Attribute, List Node -> Node
dialog = element "dialog"

## Construct a `summary` element.
summary : List Attribute, List Node -> Node
summary = element "summary"

# Main root

## Construct a `html` element.
html : List Attribute, List Node -> Node
html = element "html"

# SVG and MathML

## Construct a `math` element.
math : List Attribute, List Node -> Node
math = element "math"

## Construct a `svg` element.
svg : List Attribute, List Node -> Node
svg = element "svg"

# Scripting

## Construct a `canvas` element.
canvas : List Attribute, List Node -> Node
canvas = element "canvas"

## Construct a `noscript` element.
noscript : List Attribute, List Node -> Node
noscript = element "noscript"

## Construct a `script` element.
script : List Attribute, List Node -> Node
script = element "script"

# Sectioning root

## Construct a `body` element.
body : List Attribute, List Node -> Node
body = element "body"

# Table content

## Construct a `caption` element.
caption : List Attribute, List Node -> Node
caption = element "caption"

## Construct a `col` element.
col : List Attribute -> Node
col = voidElement "col"

## Construct a `colgroup` element.
colgroup : List Attribute, List Node -> Node
colgroup = element "colgroup"

## Construct a `table` element.
table : List Attribute, List Node -> Node
table = element "table"

## Construct a `tbody` element.
tbody : List Attribute, List Node -> Node
tbody = element "tbody"

## Construct a `td` element.
td : List Attribute, List Node -> Node
td = element "td"

## Construct a `tfoot` element.
tfoot : List Attribute, List Node -> Node
tfoot = element "tfoot"

## Construct a `th` element.
th : List Attribute, List Node -> Node
th = element "th"

## Construct a `thead` element.
thead : List Attribute, List Node -> Node
thead = element "thead"

## Construct a `tr` element.
tr : List Attribute, List Node -> Node
tr = element "tr"

# Text content

## Construct a `blockquote` element.
blockquote : List Attribute, List Node -> Node
blockquote = element "blockquote"

## Construct a `dd` element.
dd : List Attribute, List Node -> Node
dd = element "dd"

## Construct a `div` element.
div : List Attribute, List Node -> Node
div = element "div"

## Construct a `dl` element.
dl : List Attribute, List Node -> Node
dl = element "dl"

## Construct a `dt` element.
dt : List Attribute, List Node -> Node
dt = element "dt"

## Construct a `figcaption` element.
figcaption : List Attribute, List Node -> Node
figcaption = element "figcaption"

## Construct a `figure` element.
figure : List Attribute, List Node -> Node
figure = element "figure"

## Construct a `hr` element.
hr : List Attribute -> Node
hr = voidElement "hr"

## Construct a `li` element.
li : List Attribute, List Node -> Node
li = element "li"

## Construct a `menu` element.
menu : List Attribute, List Node -> Node
menu = element "menu"

## Construct a `ol` element.
ol : List Attribute, List Node -> Node
ol = element "ol"

## Construct a `p` element.
p : List Attribute, List Node -> Node
p = element "p"

## Construct a `pre` element.
pre : List Attribute, List Node -> Node
pre = element "pre"

## Construct a `ul` element.
ul : List Attribute, List Node -> Node
ul = element "ul"

# Web components

## Construct a `slot` element.
slot : List Attribute, List Node -> Node
slot = element "slot"

## Construct a `template` element.
template : List Attribute, List Node -> Node
template = element "template"
