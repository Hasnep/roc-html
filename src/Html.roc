
import Attribute
import SafeStr exposing [SafeStr, escape, dangerously_mark_safe]

Html :: [].{

	## An HTML node, either an HTML element or some text inside an HTML element.
	Node := [Element(Str, U64, List(Attribute), List(Node)), Text(Str), UnescapedHtml(Str)]

	## Create a `Text` node containing a string.
	##
	## The string will be escaped so that it's safely rendered as a text node even if the string contains HTML tags.
	##
	## ```
	## expect
	##     text_node = Node.text("<script>alert('hi')</script>")
	##     Node.render_without_doc_type(text_node) == SafeStr.dangerously_mark_safe("&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;")
	## ```
	text : Str -> Node
	text = |s| Text(s)

	expect {
		text_node = text("<script>alert('hi')</script>")
		render_without_doc_type(text_node) == SafeStr.dangerously_mark_safe("&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;")
	}

	## Mark a string as safe for HTML without actually escaping it.
	##
	## DO NOT use this function unless you're sure the input string is safe.
	##
	## NEVER use this function on user input; use the `text` function instead.
	##
	## ```
	## expect
	##     htmlNode = Node.dangerously_include_unescaped_html("<script>alert('This JavaScript will run')</script>")
	##     Node.render_without_doc_type(htmlNode) == "<script>alert('This JavaScript will run')</script>"
	## ```
	dangerously_include_unescaped_html : Str -> Node
	dangerously_include_unescaped_html = |str| UnescapedHtml(str)

	expect {
		html_node = dangerously_include_unescaped_html("<script>alert('This JavaScript will run')</script>")
		render_without_doc_type(html_node) == SafeStr.dangerously_mark_safe("<script>alert('This JavaScript will run')</script>")
	}

	## Define a non-standard HTML element.
	## You can use this to add elements that are not already supported.
	##
	## For example, you could bring back the obsolete <blink> element and add some 90's nostalgia to your web page!
	##
	## ```
	## blink : List(Attribute), List(Node) -> Node
	## blink = element("blink")
	##
	## blink([], [text("This text is blinking!")])
	## ```
	element : Str -> (List(Attribute), List(Node) -> Node)
	element = |tag_name| {
		|attrs, children| {
			# While building the node tree, calculate the size of Str it will render to
			with_tag = 2 * (3 + Str.count_utf8_bytes(tag_name))
			with_attrs = attrs.fold(
				with_tag,
				|acc, Attribute(name, val)| {
					acc + Str.count_utf8_bytes(name) + Str.count_utf8_bytes(val) + 4
				},
			)
			total_size = children.fold(
				with_attrs,
				|acc, child| {
					acc + node_size(child)
				},
			)
			Element(tag_name, total_size, attrs, children)
		}
	}

	## Define a non-standard HTML [void element](https://developer.mozilla.org/en-US/docs/Glossary/Void_element).
	## A void element is an element that cannot have any children.
	void_element : Str -> (List(Attribute) -> Node)
	void_element = |tag_name| {
		|attrs| {
			# While building the node tree, calculate the size of Str it will render to
			with_tag = 2 * (3 + Str.count_utf8_bytes(tag_name))
			with_attrs = attrs.fold(
				with_tag,
				|acc, Attribute(name, val)| {
					acc + Str.count_utf8_bytes(name) + Str.count_utf8_bytes(val) + 4
				},
			)
			Element(tag_name, with_attrs, attrs, [])
		}
	}

	## Render a node to an HTML string
	##
	## The output has no whitespace between nodes, to make it small.
	## This is intended for generating full HTML documents, so it automatically adds `<!DOCTYPE html>` to the start of the string.
	## See also `render_without_doc_type`.
	render : Node -> Str
	render = |node| {
		buffer = SafeStr.reserve(dangerously_mark_safe("<!DOCTYPE html>"), node_size(node))
		render_help(buffer, node).to_str()
	}
	#
	# expect {
	# example_document = html([], [body([], [p([Attribute.attribute("example")("test")], [text("Hello, World!")])])])
	# out = render(example_document)
	# out == \\ <!DOCTYPE html><html><body><p example="test">Hello, World!</p></body></html>
	# }
	#
	# expect {
	# example_document = html([], [body([], [p([Attribute.attribute("example")("test")], [text("<script>alert('hi')</script>")])])])
	# out = render(example_document)
	# out == \\ <!DOCTYPE html><html><body><p example="test">&lt;script&gt;alert(&#39;hi&#39;)&lt;/script&gt;</p></body></html>
	# }
	#
	# expect {
	# example_document = html([], [body([], [p([Attribute.attribute("example")("test")], [dangerously_include_unescaped_html("<script>alert('hi')</script>")])])])
	# out = render(example_document)
	# out == \\ <!DOCTYPE html><html><body><p example="test"><script>alert('hi')</script></p></body></html>
	# }
	#
	# expect {
	# example_document = html([], [body([], [base([]), link([]), meta([]), embed([]), source([]), input([]), area([]), img([]), track([]), br([]), wbr([]), col([]), hr([])])])
	# out = render(example_document)
	# out == "<!DOCTYPE html><html><body><base/><link/><meta/><embed/><source/><input/><area/><img/><track/><br/><wbr/><col/><hr/></body></html>"
	# }
	#
	# ## Render a node to a string, without a `!DOCTYPE` tag.
	# render_without_doc_type : Node -> SafeStr
	# render_without_doc_type = |node| {
	# buffer = SafeStr.with_capacity(node_size(node))
	# render_help(buffer, node)
	# }
	#
}

## Internal helper to calculate the size of a node
node_size : Node -> U64
node_size = |node| {
	match node {
		Text(content) => {
			# We allocate more bytes than the original string had because we'll need extra bytes
			# if there are any characters we need to escape. My choice of the proportion 3/2
			# was arbitrary.
			content.count_utf8_bytes().div_ceil_by(2).times(3)
		}

		UnescapedHtml(content) => Str.count_utf8_bytes(content)

		Element(_, size, _, _) => size
	}
}

## An internal helper to render a node to a string buffer.
render_help : SafeStr, Node -> SafeStr
render_help = |buffer, node| {
	match node {
		Text(content) => SafeStr.concat(buffer, escape(content))
		UnescapedHtml(content) => SafeStr.concat(buffer, dangerously_mark_safe(content))
		Element(tag_name, _, attrs, children) => {
			match tag_name {
				# Special case for void elements
				"base" | "link" | "meta" | "embed" | "source" | "input" | "area" | "img" | "track" | "br" | "wbr" | "col" | "hr" => {
					buffer
						.concat(dangerously_mark_safe("<"))
						.concat(dangerously_mark_safe(tag_name))
						->(|with_tag_name| {
							if attrs.is_empty() {
								with_tag_name
							}
								else {
									attrs.fold(with_tag_name, render_attr)
								}
						})
						.concat(dangerously_mark_safe(">")) # Don't use self-closing tag syntax for void elements
				}
				_ => {
					buffer.concat(dangerously_mark_safe("<")).concat(dangerously_mark_safe(tag_name))
						->(|with_tag_name| {
							if attrs.is_empty() {
								with_tag_name
							} else {
								attrs.fold(with_tag_name, render_attr)
							}
						})
						.concat(dangerously_mark_safe(">"))
						->(|with_tag| {
							children.fold(with_tag, render_help)
						})
						.concat(dangerously_mark_safe("</"))
						.concat(dangerously_mark_safe(tag_name))
						.concat(dangerously_mark_safe(">"))
				}
			}
		}
	}
}

## An internal helper to render an attribute to a string buffer.
render_attr : SafeStr, Attribute -> SafeStr
render_attr = |buffer, attribute| {
	# TODO: Replace this match with argument destructuring when the compiler is fixed
	match attribute {
		Attribute.Attribute(key, value) => {
			buffer
				.concat(dangerously_mark_safe(" "))
				.concat(dangerously_mark_safe(key))
				.concat(dangerously_mark_safe("=\""))
				.concat(escape(value))
				.concat(dangerously_mark_safe("\""))
		}
	}
}
