# Pitfalls

The mistakes that actually happen, and what to do instead.

## Type names that differ from the element

| Element | Type | Note |
| --- | --- | --- |
| `<main>` | `MainTag` | `Main` does not exist. |
| `<var>` | `VarTag` | `var` is a Swift keyword. |
| `<section>` | `Section` | Lives in `HTML/Commons/`, not `HTML/Forms/`. |

Anything without a dedicated type is still reachable:

```swift
HTMLTag("hgroup") { H1(content: "Title"); P(content: "Subtitle") }
RawHTML("<svg viewBox=\"0 0 24 24\"><path d=\"M4 4h16\"/></svg>")
```

## Not every element takes `content:`

Elements whose HTML content model forbids bare text only accept children — `Ul`, `Ol`, `Dl`,
`Table`, `Tr`, `Head`, `Select`, `Colgroup`, `Optgroup`, `Picture`. Put the text in the child that
is allowed to hold it:

```swift
Ul { Li(content: "First") }        // ✅
Ul(content: "First")               // ❌ does not compile
```

Flow containers (`Div`, `Section`, `Article`, `Aside`, `Header`, `Footer`, `MainTag`, `Nav`,
`Figure`, `Form`, `Fieldset`) accept both, and render `content` before their children.

## Not every element takes children

Void and leaf elements have no children builder: `Img`, `Br`, `Hr`, `Input`, `Meta`, `Link`,
`Base`, `Col`, `Source`, `Track`, `Wbr`, `Embed`, `Iframe`, `Title`, `Textarea`, `Script`, `Style`,
`Option`, `Progress`, `Meter`. `Img { … }` does not compile, and that is the point.

## Double escaping

Content and attribute values are escaped exactly once, when the tag is created.

```swift
P(content: "Tom & Jerry").render()        // <p>Tom &amp; Jerry</p>   ✅
P(content: "Tom &amp; Jerry").render()    // <p>Tom &amp;amp; Jerry</p> ❌
```

If you are reading text from JSON, Markdown or a CMS, pass it through untouched.

## When to disable escaping

`escapeContent: false` means "this string is already HTML". It is correct for markup you generated
and wrong for anything a user or a CMS supplied.

```swift
Div(content: renderedMarkdown, escapeContent: false)   // ✅ you produced it
Div(content: commentFromUser, escapeContent: false)    // ❌ XSS
```

`Script` and `Style` default to `escapeContent: false` — escaping would corrupt `a > b` in CSS and
`i < 10` in JavaScript.

## `Fragment` vs `RawHTML`

Both avoid a wrapper element, but only one keeps the tree:

```swift
fragment { items.map { Li(content: $0) } }        // ✅ tags, pretty printing still works
RawHTML(items.map { "<li>\($0)</li>" }.joined())  // ⚠️ a string; nothing is escaped
```

`Fragment(children:)` is also how you drop a `[Meta]` from `SEO.complete(...)` into a builder block.

## `Document` vs `html { }`

`html { }` builds the `<html>` element only — no doctype, no `lang`. Prefer `Document`, which owns
both:

```swift
Document(lang: "pt-BR") { Title(content: "T") } body: { H1(content: "Olá") }
```

Use `html { }` for a fragment of a page, or when something else writes the doctype.

## Rendering options are values, not settings

```swift
page.render()          // compact
page.render(.pretty)   // indented
page.render(RenderOptions(pretty: true, indent: "\t"))
```

XHTML-style void elements (`<br />`) come from `RenderOptions(xhtmlSelfClosing: true)`; the old
global `HTMLTag.xhtmlSelfClosing` was removed in 3.0. `<pre>`, `<code>` and `<textarea>` are always
rendered compactly, because whitespace inside them is visible text. When diffing generated HTML,
compare compact output to avoid indentation noise.

## Script URLs render as `#` (3.0+)

`href`, `src`, `action`, `formaction`, `poster`, `cite`, `background`, `xlink:href` and `data`
values that start with `javascript:`, `vbscript:` or `data:text/html` render as `#` — including
links from Markdown. Browsers ignore case and control characters in the scheme, and so does the
check. For a script URL you wrote yourself, use `.trustedURL("href", "javascript:print()")` or
`Attribute.trustedURL(key:value:)`; never pass data through them.

## Attribute order and duplicates

Attributes render in insertion order and are **not** deduplicated, except by the helpers that
explicitly replace: `setId`, `setStyle`, `setRole` and the typed setters (`target`, `rel`,
`loading`, `decoding`, `hidden`, `tabIndex`, `lang`). `addClass` appends, so calling it twice with
the same class emits it twice. Convenience parameters (`href`, `src`, `type`) are appended by the
initializer — if you also pass the same key inside `attributes`, both are rendered.

## Text nodes and pretty printing

A bare string in a builder (`P { "Hello, "; Strong(content: name) }`) becomes a `TextNode`. In
compact output it sits flush against its neighbours. In pretty output every child goes on its own
line, so the browser sees whitespace between the text and the inline element — `name!` can become
`name !`. When spacing between inline pieces matters, end the element with `.inline()` (2.4+) —
it renders that element on one line, even in pretty output — or render the page `.compact`.

## `Site` / `Page` properties must match the requirement's type

Protocol defaults only apply when you do not declare the property. The requirements are
non-optional `String`s (`description`, `image`, `author`) so that `var description = "…"` matches.
If you write `var description: String? = "…"` it is a *different* property: it compiles without a
warning, the protocol default (empty) wins, and the meta tag disappears. `homePage`, `layout` and
`errorPage` are associated types, so write `var layout = MainLayout()` —
`var layout: any PageLayout = MainLayout()` does not compile.

## Markdown escapes HTML by default

`Markdown.parse` — and therefore every `Content/*.md` page — escapes HTML in the source unless you
pass `MarkdownOptions(rawHTML: true)` (or set `markdownOptions` on the site). That is deliberate:
turn it on only for content you write yourself. Front matter values are plain text, never HTML.

## Boolean attributes

```swift
Input(type: "checkbox", name: "tos", attributes: [.boolean("checked"), .boolean("required")])
// <input type="checkbox" name="tos" checked required>
```

`Attribute(key: "checked", value: "true")` would render `checked="true"` — valid, but not what the
HTML spec means.

## Reference semantics, and no `Sendable`

`HTMLTag` is a class. Reusing one instance in two places puts *the same node* in both, and mutating
it later changes both. Build components with functions that return a fresh tag each call:

```swift
static func divider() -> HTMLTag { Hr().addClass("my-8") }   // ✅
let divider = Hr().addClass("my-8")                          // ⚠️ shared node
let second = divider.copy()                                  // ✅ independent (3.0+)
```

For the same reason a tag tree is not `Sendable`. Build and render inside one task, then move the
`String` across isolation boundaries — not the tree.

## Overriding rendering in a subclass

The overridable primitive is `write(into:options:indentLevel:)`. `renderCompact()` and
`renderPretty(_:)` no longer exist (removed in 3.0).
