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

`HTMLTag.xhtmlSelfClosing` still exists but is deprecated process-wide state — pass
`RenderOptions(xhtmlSelfClosing: true)` instead. `<pre>`, `<code>` and `<textarea>` are always
rendered compactly, because whitespace inside them is visible text. When diffing generated HTML,
compare compact output to avoid indentation noise.

## Attribute order and duplicates

Attributes render in insertion order and are **not** deduplicated, except by the helpers that
explicitly replace: `setId`, `setStyle` and `setRole`. `addClass` appends, so calling it twice with
the same class emits it twice. Convenience parameters (`href`, `src`, `type`) are appended by the
initializer — if you also pass the same key inside `attributes`, both are rendered.

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
```

For the same reason a tag tree is not `Sendable`. Build and render inside one task, then move the
`String` across isolation boundaries — not the tree.

## Overriding rendering in a subclass

The overridable primitive is `write(into:options:indentLevel:)`. Overriding `renderCompact()` or
`renderPretty(_:)` has no effect in 2.0 — the new pipeline never calls them.
