import Foundation
import Testing
@testable import WingedSwift

private func md(_ source: String, _ options: MarkdownOptions = MarkdownOptions()) -> String {
    Fragment(children: Markdown.parse(source, options: options)).render(.compact)
}

@Suite struct MarkdownBlockTests {
    @Test func headings() {
        #expect(md("# Hello") == "<h1 id=\"hello\">Hello</h1>")
        #expect(md("###### Six ##") == "<h6 id=\"six\">Six</h6>")
        #expect(md("#NoSpace") == "<p>#NoSpace</p>")
        #expect(md("####### seven") == "<p>####### seven</p>")
        #expect(md("## A *b*\n## A b\n## !!!") == "<h2 id=\"a-b\">A <em>b</em></h2><h2 id=\"a-b-1\">A b</h2><h2 id=\"section\">!!!</h2>")
        #expect(md("# Hi", MarkdownOptions(headingIDs: false)) == "<h1>Hi</h1>")
        #expect(md("#") == "<h1 id=\"section\"></h1>")
    }

    @Test func paragraphsAndBreaks() {
        #expect(md("one\ntwo\n\nthree") == "<p>one\ntwo</p><p>three</p>")
        #expect(md("hard" + "  " + "\nbreak") == "<p>hard<br>break</p>")
        #expect(md("back\\\nslash") == "<p>back<br>slash</p>")
        #expect(md("\n\n").isEmpty)
        #expect(md("<b>x</b> & y") == "<p>&lt;b&gt;x&lt;/b&gt; &amp; y</p>")
    }

    @Test func thematicBreaks() {
        #expect(md("---") == "<hr>")
        #expect(md("* * *") == "<hr>")
        #expect(md("--") == "<p>--</p>")
        #expect(md("-*-") == "<p>-*-</p>")
    }

    @Test func fencedCode() {
        #expect(md("```swift\nlet a = 1 < 2\n```") == "<pre><code class=\"language-swift\">let a = 1 &lt; 2</code></pre>")
        #expect(md("~~~\nplain\n\n" + "  " + "kept\n~~~") == "<pre><code>plain\n\n" + "  " + "kept</code></pre>")
        #expect(md("````\n```\n````") == "<pre><code>```</code></pre>")
        #expect(md("```js extra\nx\n") == "<pre><code class=\"language-js\">x\n</code></pre>")
    }

    @Test func blockquotes() {
        #expect(md("> quoted\n> *still*\n>\n> second") == "<blockquote><p>quoted\n<em>still</em></p><p>second</p></blockquote>")
        #expect(md(">no space") == "<blockquote><p>no space</p></blockquote>")
    }

    @Test func unorderedLists() {
        #expect(md("- a\n- b\n* c") == "<ul><li>a</li><li>b</li></ul><ul><li>c</li></ul>")
        #expect(md("- one\n" + "  " + "continued\n- two") == "<ul><li>one\ncontinued</li><li>two</li></ul>")
        #expect(md("- lazy\nline") == "<ul><li>lazy\nline</li></ul>")
        #expect(md("- outer\n" + "  " + "- inner\n" + "  " + "- inner 2\n- next")
            == "<ul><li>outer<ul><li>inner</li><li>inner 2</li></ul></li><li>next</li></ul>")
        #expect(md("- loose\n\n- items") == "<ul><li><p>loose</p></li><li><p>items</p></li></ul>")
        #expect(md("- a\n\n" + "  " + "para\n- b") == "<ul><li><p>a</p><p>para</p></li><li><p>b</p></li></ul>")
        #expect(md("- a\n\nafter") == "<ul><li>a</li></ul><p>after</p>")
        #expect(md("- a\n# heading") == "<ul><li>a</li></ul><h1 id=\"heading\">heading</h1>")
    }

    @Test func orderedLists() {
        #expect(md("1. a\n2. b") == "<ol><li>a</li><li>b</li></ol>")
        #expect(md("3) c\n4) d") == "<ol start=\"3\"><li>c</li><li>d</li></ol>")
        #expect(md("1.no") == "<p>1.no</p>")
        #expect(md("1234567890. x") == "<p>1234567890. x</p>")
        #expect(md("- a\n1. b") == "<ul><li>a</li></ul><ol><li>b</li></ol>")
    }

    @Test func tables() {
        let table = md("| A | B | C | D |\n|:--|:-:|--:|---|\n| 1 | **2** | 3 | a \\| b |\n| 4 |")
        #expect(table == "<table><thead><tr><th style=\"text-align: left\">A</th><th style=\"text-align: center\">B</th>"
            + "<th style=\"text-align: right\">C</th><th>D</th></tr></thead><tbody><tr><td style=\"text-align: left\">1</td>"
            + "<td style=\"text-align: center\"><strong>2</strong></td><td style=\"text-align: right\">3</td><td>a | b</td></tr>"
            + "<tr><td style=\"text-align: left\">4</td><td style=\"text-align: center\"></td><td style=\"text-align: right\"></td><td></td></tr></tbody></table>")
        #expect(md("A | B\n--- | ---") == "<table><thead><tr><th>A</th><th>B</th></tr></thead></table>")
        #expect(md("a | b\nnot a separator") == "<p>a | b\nnot a separator</p>")
        #expect(md("a | b\n| x | y |") == "<p>a | b\n| x | y |</p>")
    }

    @Test func rawHTML() {
        let source = "<div class=\"note\">\n**raw**\n</div>\n\ntext <kbd>K</kbd>"
        #expect(md(source, MarkdownOptions(rawHTML: true)) == "<div class=\"note\">\n**raw**\n</div><p>text <kbd>K</kbd></p>")
        #expect(md("<!-- c -->", MarkdownOptions(rawHTML: true)) == "<!-- c -->")
        #expect(md(source) == "<p>&lt;div class=&quot;note&quot;&gt;\n<strong>raw</strong>\n&lt;/div&gt;</p><p>text &lt;kbd&gt;K&lt;/kbd&gt;</p>")
        #expect(md("<3 and <not closed", MarkdownOptions(rawHTML: true)) == "<p>&lt;3 and &lt;not closed</p>")
    }
}

@Suite struct MarkdownInlineTests {
    @Test func emphasis() {
        #expect(md("*a* _b_ **c** __d__ ***e*** ~~f~~") == "<p><em>a</em> <em>b</em> <strong>c</strong> <strong>d</strong> <em><strong>e</strong></em> <del>f</del></p>")
        #expect(md("snake_case_name and 2*3*4") == "<p>snake_case_name and 2<em>3</em>4</p>")
        #expect(md("* not em*") == "<ul><li>not em*</li></ul>")
        #expect(md("a * b * c") == "<p>a * b * c</p>")
        #expect(md("**unclosed") == "<p>**unclosed</p>")
        #expect(md("~one~") == "<p>~one~</p>")
        #expect(md("_a_b_") == "<p><em>a_b</em></p>")
        #expect(md("**a *b* c**") == "<p><strong>a <em>b</em> c</strong></p>")
        #expect(md("**a `*` b**") == "<p><strong>a <code>*</code> b</strong></p>")
        #expect(md("*a **b** c*") == "<p><em>a <strong>b</strong> c</em></p>")
    }

    @Test func code() {
        #expect(md("use `let x = <y>` here") == "<p>use <code>let x = &lt;y&gt;</code> here</p>")
        #expect(md("``a ` b``") == "<p><code>a ` b</code></p>")
        #expect(md("` padded `") == "<p><code>padded</code></p>")
        #expect(md("`unclosed") == "<p>`unclosed</p>")
        #expect(md("``a`b") == "<p>``a`b</p>")
    }

    @Test func linksAndImages() {
        #expect(md("[Swift](https://swift.org)") == "<p><a href=\"https://swift.org\">Swift</a></p>")
        #expect(md("[*em* link](/x \"Title\")") == "<p><a href=\"/x\" title=\"Title\"><em>em</em> link</a></p>")
        #expect(md("[a [nested] b](</with space>)") == "<p><a href=\"/with space\">a [nested] b</a></p>")
        #expect(md("![A *cat*](/cat.png \"Cat\")") == "<p><img src=\"/cat.png\" alt=\"A cat\" title=\"Cat\"></p>")
        #expect(md("[no target] and [x](") == "<p>[no target] and [x](</p>")
        #expect(md("[unclosed") == "<p>[unclosed</p>")
        #expect(md("! [not image](/a)") == "<p>! <a href=\"/a\">not image</a></p>")
        #expect(md("[q](/a \"\")") == "<p><a href=\"/a\" title=\"\">q</a></p>")
        #expect(md("[q](\"/odd\")") == "<p><a href=\"&quot;/odd&quot;\">q</a></p>")
    }

    @Test func autolinksAndEscapes() {
        #expect(md("<https://swift.org>") == "<p><a href=\"https://swift.org\">https://swift.org</a></p>")
        #expect(md("<mailto:a@b.c>") == "<p><a href=\"mailto:a@b.c\">mailto:a@b.c</a></p>")
        #expect(md("<https://a b>") == "<p>&lt;https://a b&gt;</p>")
        #expect(md("\\*not em\\* \\# \\q") == "<p>*not em* # \\q</p>")
        #expect(md("trailing \\") == "<p>trailing \\</p>")
    }

    @Test func plainText() {
        #expect(Markdown.plainText("# Title\n\nSome *em* and [a link](/x) & `code`.") == "Title Some em and a link & code .")
        #expect(Markdown.plainText("").isEmpty)
    }

    @Test func prettyOutputKeepsInlineContentOnOneLine() {
        let html = Div(children: Markdown.parse("Hello *world*!\n\n- a **b**\n\n| x |\n|---|\n| *y* |")).render(.pretty)
        let indent = RenderOptions.pretty.indent
        #expect(html.contains("\n" + indent + "<p>Hello <em>world</em>!</p>\n"))
        #expect(html.contains(indent + indent + "<li>a <strong>b</strong></li>"))
        #expect(html.contains("<td><em>y</em></td>"))
    }

    @Test func inlineModifierKeepsAnElementOnOneLine() {
        let html = Div {
            P {
                "Posted "
                Strong(content: "today")
                "."
            }
            .inline()
        }
        .render(.pretty)
        #expect(html == "<div>\n" + RenderOptions.pretty.indent + "<p>Posted <strong>today</strong>.</p>\n</div>")
        #expect(P(content: "x").inline().render(.compact) == "<p>x</p>")
    }

    @Test func optionsAreValues() {
        #expect(MarkdownOptions() == MarkdownOptions(rawHTML: false, headingIDs: true))
    }
}
