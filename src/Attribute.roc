module [
    Attribute,
    attribute,
    accept,
    acceptCharset,
    accesskey,
    action,
    align,
    allow,
    alt,
    async,
    autocapitalize,
    autocomplete,
    autofocus,
    autoplay,
    background,
    bgcolor,
    border,
    buffered,
    capture,
    challenge,
    charset,
    checked,
    cite,
    class,
    code,
    codebase,
    color,
    cols,
    colspan,
    content,
    contenteditable,
    contextmenu,
    controls,
    coords,
    crossorigin,
    csp,
    data,
    datetime,
    decoding,
    default,
    defer,
    dir,
    dirname,
    disabled,
    download,
    draggable,
    enctype,
    enterkeyhint,
    for,
    form,
    formaction,
    formenctype,
    formmethod,
    formnovalidate,
    formtarget,
    headers,
    height,
    hidden,
    high,
    href,
    hreflang,
    httpEquiv,
    icon,
    id,
    importance,
    inputmode,
    integrity,
    intrinsicsize,
    ismap,
    itemprop,
    keytype,
    kind,
    label,
    lang,
    language,
    list,
    loading,
    loop,
    low,
    manifest,
    max,
    maxlength,
    media,
    method,
    min,
    minlength,
    multiple,
    muted,
    name,
    novalidate,
    open,
    optimum,
    pattern,
    ping,
    placeholder,
    poster,
    preload,
    radiogroup,
    readonly,
    referrerpolicy,
    rel,
    required,
    reversed,
    role,
    rows,
    rowspan,
    sandbox,
    scope,
    scoped,
    selected,
    shape,
    size,
    sizes,
    slot,
    span,
    spellcheck,
    src,
    srcdoc,
    srclang,
    srcset,
    start,
    step,
    style,
    summary,
    tabindex,
    target,
    title,
    translate,
    type,
    usemap,
    value,
    width,
    wrap,
]

Attribute : [Attribute Str Str]

## Define a non-standard attribute.
## You can use this to add attributes that are not already supported.
attribute : Str -> (Str -> Attribute)
attribute = \attrName ->
    \attrValue -> Attribute attrName attrValue

## Construct a `accept` attribute.
accept : Str -> Attribute
accept = attribute "accept"

## Construct a `accept-charset` attribute.
acceptCharset : Str -> Attribute
acceptCharset = attribute "accept-charset"

## Construct a `accesskey` attribute.
accesskey : Str -> Attribute
accesskey = attribute "accesskey"

## Construct a `action` attribute.
action : Str -> Attribute
action = attribute "action"

## Construct a `align` attribute.
align : Str -> Attribute
align = attribute "align"

## Construct a `allow` attribute.
allow : Str -> Attribute
allow = attribute "allow"

## Construct a `alt` attribute.
alt : Str -> Attribute
alt = attribute "alt"

## Construct a `async` attribute.
async : Str -> Attribute
async = attribute "async"

## Construct a `autocapitalize` attribute.
autocapitalize : Str -> Attribute
autocapitalize = attribute "autocapitalize"

## Construct a `autocomplete` attribute.
autocomplete : Str -> Attribute
autocomplete = attribute "autocomplete"

## Construct a `autofocus` attribute.
autofocus : Str -> Attribute
autofocus = attribute "autofocus"

## Construct a `autoplay` attribute.
autoplay : Str -> Attribute
autoplay = attribute "autoplay"

## Construct a `background` attribute.
background : Str -> Attribute
background = attribute "background"

## Construct a `bgcolor` attribute.
bgcolor : Str -> Attribute
bgcolor = attribute "bgcolor"

## Construct a `border` attribute.
border : Str -> Attribute
border = attribute "border"

## Construct a `buffered` attribute.
buffered : Str -> Attribute
buffered = attribute "buffered"

## Construct a `capture` attribute.
capture : Str -> Attribute
capture = attribute "capture"

## Construct a `challenge` attribute.
challenge : Str -> Attribute
challenge = attribute "challenge"

## Construct a `charset` attribute.
charset : Str -> Attribute
charset = attribute "charset"

## Construct a `checked` attribute.
checked : Str -> Attribute
checked = attribute "checked"

## Construct a `cite` attribute.
cite : Str -> Attribute
cite = attribute "cite"

## Construct a `class` attribute.
class : Str -> Attribute
class = attribute "class"

## Construct a `code` attribute.
code : Str -> Attribute
code = attribute "code"

## Construct a `codebase` attribute.
codebase : Str -> Attribute
codebase = attribute "codebase"

## Construct a `color` attribute.
color : Str -> Attribute
color = attribute "color"

## Construct a `cols` attribute.
cols : Str -> Attribute
cols = attribute "cols"

## Construct a `colspan` attribute.
colspan : Str -> Attribute
colspan = attribute "colspan"

## Construct a `content` attribute.
content : Str -> Attribute
content = attribute "content"

## Construct a `contenteditable` attribute.
contenteditable : Str -> Attribute
contenteditable = attribute "contenteditable"

## Construct a `contextmenu` attribute.
contextmenu : Str -> Attribute
contextmenu = attribute "contextmenu"

## Construct a `controls` attribute.
controls : Str -> Attribute
controls = attribute "controls"

## Construct a `coords` attribute.
coords : Str -> Attribute
coords = attribute "coords"

## Construct a `crossorigin` attribute.
crossorigin : Str -> Attribute
crossorigin = attribute "crossorigin"

## Construct a `csp` attribute.
csp : Str -> Attribute
csp = attribute "csp"

## Construct a `data` attribute.
data : Str -> Attribute
data = attribute "data"

## Construct a `datetime` attribute.
datetime : Str -> Attribute
datetime = attribute "datetime"

## Construct a `decoding` attribute.
decoding : Str -> Attribute
decoding = attribute "decoding"

## Construct a `default` attribute.
default : Str -> Attribute
default = attribute "default"

## Construct a `defer` attribute.
defer : Str -> Attribute
defer = attribute "defer"

## Construct a `dir` attribute.
dir : Str -> Attribute
dir = attribute "dir"

## Construct a `dirname` attribute.
dirname : Str -> Attribute
dirname = attribute "dirname"

## Construct a `disabled` attribute.
disabled : Str -> Attribute
disabled = attribute "disabled"

## Construct a `download` attribute.
download : Str -> Attribute
download = attribute "download"

## Construct a `draggable` attribute.
draggable : Str -> Attribute
draggable = attribute "draggable"

## Construct a `enctype` attribute.
enctype : Str -> Attribute
enctype = attribute "enctype"

## Construct a `enterkeyhint` attribute.
enterkeyhint : Str -> Attribute
enterkeyhint = attribute "enterkeyhint"

## Construct a `for` attribute.
for : Str -> Attribute
for = attribute "for"

## Construct a `form` attribute.
form : Str -> Attribute
form = attribute "form"

## Construct a `formaction` attribute.
formaction : Str -> Attribute
formaction = attribute "formaction"

## Construct a `formenctype` attribute.
formenctype : Str -> Attribute
formenctype = attribute "formenctype"

## Construct a `formmethod` attribute.
formmethod : Str -> Attribute
formmethod = attribute "formmethod"

## Construct a `formnovalidate` attribute.
formnovalidate : Str -> Attribute
formnovalidate = attribute "formnovalidate"

## Construct a `formtarget` attribute.
formtarget : Str -> Attribute
formtarget = attribute "formtarget"

## Construct a `headers` attribute.
headers : Str -> Attribute
headers = attribute "headers"

## Construct a `height` attribute.
height : Str -> Attribute
height = attribute "height"

## Construct a `hidden` attribute.
hidden : Str -> Attribute
hidden = attribute "hidden"

## Construct a `high` attribute.
high : Str -> Attribute
high = attribute "high"

## Construct a `href` attribute.
href : Str -> Attribute
href = attribute "href"

## Construct a `hreflang` attribute.
hreflang : Str -> Attribute
hreflang = attribute "hreflang"

## Construct a `http-equiv` attribute.
httpEquiv : Str -> Attribute
httpEquiv = attribute "http-equiv"

## Construct a `icon` attribute.
icon : Str -> Attribute
icon = attribute "icon"

## Construct a `id` attribute.
id : Str -> Attribute
id = attribute "id"

## Construct a `importance` attribute.
importance : Str -> Attribute
importance = attribute "importance"

## Construct a `inputmode` attribute.
inputmode : Str -> Attribute
inputmode = attribute "inputmode"

## Construct a `integrity` attribute.
integrity : Str -> Attribute
integrity = attribute "integrity"

## Construct a `intrinsicsize` attribute.
intrinsicsize : Str -> Attribute
intrinsicsize = attribute "intrinsicsize"

## Construct a `ismap` attribute.
ismap : Str -> Attribute
ismap = attribute "ismap"

## Construct a `itemprop` attribute.
itemprop : Str -> Attribute
itemprop = attribute "itemprop"

## Construct a `keytype` attribute.
keytype : Str -> Attribute
keytype = attribute "keytype"

## Construct a `kind` attribute.
kind : Str -> Attribute
kind = attribute "kind"

## Construct a `label` attribute.
label : Str -> Attribute
label = attribute "label"

## Construct a `lang` attribute.
lang : Str -> Attribute
lang = attribute "lang"

## Construct a `language` attribute.
language : Str -> Attribute
language = attribute "language"

## Construct a `list` attribute.
list : Str -> Attribute
list = attribute "list"

## Construct a `loading` attribute.
loading : Str -> Attribute
loading = attribute "loading"

## Construct a `loop` attribute.
loop : Str -> Attribute
loop = attribute "loop"

## Construct a `low` attribute.
low : Str -> Attribute
low = attribute "low"

## Construct a `manifest` attribute.
manifest : Str -> Attribute
manifest = attribute "manifest"

## Construct a `max` attribute.
max : Str -> Attribute
max = attribute "max"

## Construct a `maxlength` attribute.
maxlength : Str -> Attribute
maxlength = attribute "maxlength"

## Construct a `media` attribute.
media : Str -> Attribute
media = attribute "media"

## Construct a `method` attribute.
method : Str -> Attribute
method = attribute "method"

## Construct a `min` attribute.
min : Str -> Attribute
min = attribute "min"

## Construct a `minlength` attribute.
minlength : Str -> Attribute
minlength = attribute "minlength"

## Construct a `multiple` attribute.
multiple : Str -> Attribute
multiple = attribute "multiple"

## Construct a `muted` attribute.
muted : Str -> Attribute
muted = attribute "muted"

## Construct a `name` attribute.
name : Str -> Attribute
name = attribute "name"

## Construct a `novalidate` attribute.
novalidate : Str -> Attribute
novalidate = attribute "novalidate"

## Construct a `open` attribute.
open : Str -> Attribute
open = attribute "open"

## Construct a `optimum` attribute.
optimum : Str -> Attribute
optimum = attribute "optimum"

## Construct a `pattern` attribute.
pattern : Str -> Attribute
pattern = attribute "pattern"

## Construct a `ping` attribute.
ping : Str -> Attribute
ping = attribute "ping"

## Construct a `placeholder` attribute.
placeholder : Str -> Attribute
placeholder = attribute "placeholder"

## Construct a `poster` attribute.
poster : Str -> Attribute
poster = attribute "poster"

## Construct a `preload` attribute.
preload : Str -> Attribute
preload = attribute "preload"

## Construct a `radiogroup` attribute.
radiogroup : Str -> Attribute
radiogroup = attribute "radiogroup"

## Construct a `readonly` attribute.
readonly : Str -> Attribute
readonly = attribute "readonly"

## Construct a `referrerpolicy` attribute.
referrerpolicy : Str -> Attribute
referrerpolicy = attribute "referrerpolicy"

## Construct a `rel` attribute.
rel : Str -> Attribute
rel = attribute "rel"

## Construct a `required` attribute.
required : Str -> Attribute
required = attribute "required"

## Construct a `reversed` attribute.
reversed : Str -> Attribute
reversed = attribute "reversed"

## Construct a `role` attribute.
role : Str -> Attribute
role = attribute "role"

## Construct a `rows` attribute.
rows : Str -> Attribute
rows = attribute "rows"

## Construct a `rowspan` attribute.
rowspan : Str -> Attribute
rowspan = attribute "rowspan"

## Construct a `sandbox` attribute.
sandbox : Str -> Attribute
sandbox = attribute "sandbox"

## Construct a `scope` attribute.
scope : Str -> Attribute
scope = attribute "scope"

## Construct a `scoped` attribute.
scoped : Str -> Attribute
scoped = attribute "scoped"

## Construct a `selected` attribute.
selected : Str -> Attribute
selected = attribute "selected"

## Construct a `shape` attribute.
shape : Str -> Attribute
shape = attribute "shape"

## Construct a `size` attribute.
size : Str -> Attribute
size = attribute "size"

## Construct a `sizes` attribute.
sizes : Str -> Attribute
sizes = attribute "sizes"

## Construct a `slot` attribute.
slot : Str -> Attribute
slot = attribute "slot"

## Construct a `span` attribute.
span : Str -> Attribute
span = attribute "span"

## Construct a `spellcheck` attribute.
spellcheck : Str -> Attribute
spellcheck = attribute "spellcheck"

## Construct a `src` attribute.
src : Str -> Attribute
src = attribute "src"

## Construct a `srcdoc` attribute.
srcdoc : Str -> Attribute
srcdoc = attribute "srcdoc"

## Construct a `srclang` attribute.
srclang : Str -> Attribute
srclang = attribute "srclang"

## Construct a `srcset` attribute.
srcset : Str -> Attribute
srcset = attribute "srcset"

## Construct a `start` attribute.
start : Str -> Attribute
start = attribute "start"

## Construct a `step` attribute.
step : Str -> Attribute
step = attribute "step"

## Construct a `style` attribute.
style : Str -> Attribute
style = attribute "style"

## Construct a `summary` attribute.
summary : Str -> Attribute
summary = attribute "summary"

## Construct a `tabindex` attribute.
tabindex : Str -> Attribute
tabindex = attribute "tabindex"

## Construct a `target` attribute.
target : Str -> Attribute
target = attribute "target"

## Construct a `title` attribute.
title : Str -> Attribute
title = attribute "title"

## Construct a `translate` attribute.
translate : Str -> Attribute
translate = attribute "translate"

## Construct a `type` attribute.
type : Str -> Attribute
type = attribute "type"

## Construct a `usemap` attribute.
usemap : Str -> Attribute
usemap = attribute "usemap"

## Construct a `value` attribute.
value : Str -> Attribute
value = attribute "value"

## Construct a `width` attribute.
width : Str -> Attribute
width = attribute "width"

## Construct a `wrap` attribute.
wrap : Str -> Attribute
wrap = attribute "wrap"
