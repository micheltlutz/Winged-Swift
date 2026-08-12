import Foundation
import Testing
@testable import WingedSwift

/// Covers the tags added in 1.5.0 and the completed void-element set.
@Suite struct TagCatalogTests {

    // MARK: - Tables

    @Test func testTableStructure() {
        let table = Table(children: [
            Caption(content: "Sales"),
            Colgroup(children: [Col(span: 2)]),
            Thead(children: [Tr(children: [Th(content: "Month"), Th(content: "Total")])]),
            Tbody(children: [Tr(children: [Td(content: "Jan"), Td(content: "10")])]),
            Tfoot(children: [Tr(children: [Td(content: "Sum"), Td(content: "10")])])
        ])

        let html = table.render()

        #expect(html.contains("<caption>Sales</caption>"))
        #expect(html.contains("<colgroup><col span=\"2\"></colgroup>"))
        #expect(html.contains("<thead><tr><th>Month</th><th>Total</th></tr></thead>"))
        #expect(html.contains("<tbody>"))
        #expect(html.contains("<tfoot>"))
    }

    // MARK: - Void elements

    @Test func testVoidElementsRenderWithoutClosingTag() {
        #expect(Col().render() == "<col>")
        #expect(Wbr().render() == "<wbr>")
        #expect(Base(href: "https://example.com/").render() == "<base href=\"https://example.com/\">")
        #expect(Source(srcset: "a.webp", type: "image/webp").render() == "<source srcset=\"a.webp\" type=\"image/webp\">")
        #expect(Track(src: "cc.vtt", srclang: "en", isDefault: true).render() == "<track src=\"cc.vtt\" kind=\"subtitles\" srclang=\"en\" default>")
    }

    @Test func testVoidElementsHonourXHTMLMode() {
        let options = RenderOptions(xhtmlSelfClosing: true)

        #expect(Col().render(options) == "<col />")
        #expect(Wbr().render(options) == "<wbr />")
    }

    // MARK: - Media

    @Test func testPictureWithSources() {
        let picture = Picture(children: [
            Source(srcset: "/img/hero.avif", type: "image/avif"),
            Img(src: "/img/hero.jpg", alt: "Hero")
        ])

        #expect(picture.render() == "<picture><source srcset=\"/img/hero.avif\" type=\"image/avif\">"
            + "<img src=\"/img/hero.jpg\" alt=\"Hero\"></picture>")
    }

    @Test func testVideoBooleanAttributes() {
        let video = Video(src: "/demo.mp4", controls: true, muted: true, poster: "/poster.jpg")
        let html = video.render()

        #expect(html.hasPrefix("<video src=\"/demo.mp4\" poster=\"/poster.jpg\""))
        #expect(html.contains(" controls"))
        #expect(html.contains(" muted"))
        #expect(!(html.contains("autoplay")))
        #expect(html.hasSuffix("</video>"))
    }

    @Test func testAudioWithoutControls() {
        #expect(Audio(src: "/song.mp3", controls: false).render() == "<audio src=\"/song.mp3\"></audio>")
    }

    @Test func testIframeRequiresTitleAndDefaultsToLazyLoading() {
        #expect(Iframe(src: "https://example.com", title: "Example").render() == "<iframe src=\"https://example.com\" title=\"Example\" loading=\"lazy\"></iframe>")
    }

    // MARK: - Interactive and text semantics

    @Test func testDetailsAndSummary() {
        let details = Details(open: true, children: [
            Summary(content: "More"),
            P(content: "Hidden text")
        ])

        #expect(details.render() == "<details open><summary>More</summary><p>Hidden text</p></details>")
    }

    @Test func testDetailsClosedByDefault() {
        #expect(Details(children: [Summary(content: "More")]).render() == "<details><summary>More</summary></details>")
    }

    @Test func testDefinitionList() {
        let list = Dl(children: [
            Dt(content: "WingedSwift"),
            Dd(content: "An HTML DSL for Swift")
        ])

        #expect(list.render() == "<dl><dt>WingedSwift</dt><dd>An HTML DSL for Swift</dd></dl>")
    }

    @Test func testTextSemanticTags() {
        #expect(Blockquote(content: "Quoted").render() == "<blockquote>Quoted</blockquote>")
        #expect(Q(cite: "https://example.com", content: "Short").render() == "<q cite=\"https://example.com\">Short</q>")
        #expect(Cite(content: "Moby Dick").render() == "<cite>Moby Dick</cite>")
        #expect(Abbr(attributes: [Attribute(key: "title", value: "HyperText Markup Language")],
                            content: "HTML").render() == "<abbr title=\"HyperText Markup Language\">HTML</abbr>")
        #expect(Address(content: "Rua 1").render() == "<address>Rua 1</address>")
        #expect(Sub(content: "2").render() == "<sub>2</sub>")
        #expect(Sup(content: "2").render() == "<sup>2</sup>")
        #expect(Del(content: "old").render() == "<del>old</del>")
        #expect(Ins(content: "new").render() == "<ins>new</ins>")
        #expect(Kbd(content: "⌘S").render() == "<kbd>⌘S</kbd>")
        #expect(Samp(content: "ok").render() == "<samp>ok</samp>")
        #expect(VarTag(content: "x").render() == "<var>x</var>")
        #expect(Dialog(content: "Hi").render() == "<dialog>Hi</dialog>")
        #expect(Noscript(content: "Enable JS").render() == "<noscript>Enable JS</noscript>")
        #expect(Canvas(attributes: [Attribute(key: "width", value: "300")]).render() == "<canvas width=\"300\"></canvas>")
    }

    @Test func testStyleDoesNotEscapeCSS() {
        let style = Style(media: "screen", content: "a > b { color: red; }")

        #expect(style.render() == "<style media=\"screen\">a > b { color: red; }</style>")
    }

    // MARK: - Flow containers accept text as well as children

    @Test func testFlowContainersAcceptContent() {
        #expect(Aside(content: "Note").render() == "<aside>Note</aside>")
        #expect(Nav(content: "Menu").render() == "<nav>Menu</nav>")
        #expect(Header(content: "Top").render() == "<header>Top</header>")
        #expect(Footer(content: "Bottom").render() == "<footer>Bottom</footer>")
        #expect(MainTag(content: "Body").render() == "<main>Body</main>")
        #expect(Article(content: "Post").render() == "<article>Post</article>")
        #expect(Figure(content: "Fig").render() == "<figure>Fig</figure>")
        #expect(Form(content: "F").render() == "<form>F</form>")
        #expect(Fieldset(content: "Set").render() == "<fieldset>Set</fieldset>")
    }

    @Test func testFlowContainerContentIsEscaped() {
        #expect(Aside(content: "<b>x</b>").render() == "<aside>&lt;b&gt;x&lt;/b&gt;</aside>")
    }

    // MARK: - Forms

    @Test func testFieldsetWithLegend() {
        let fieldset = Fieldset(children: [
            Legend(content: "Account"),
            Input(type: "text", name: "email")
        ])

        #expect(fieldset.render() == "<fieldset><legend>Account</legend><input type=\"text\" name=\"email\"></fieldset>")
    }

    @Test func testSelectWithOptgroup() {
        let select = Select(name: "city", children: [
            Optgroup(label: "Brazil", children: [Option(value: "sp", content: "São Paulo")])
        ])

        #expect(select.render() == "<select name=\"city\"><optgroup label=\"Brazil\">"
            + "<option value=\"sp\">São Paulo</option></optgroup></select>")
    }

    @Test func testDatalistProgressMeterAndOutput() {
        #expect(Datalist(children: [Option(value: "swift")]).render() == "<datalist><option value=\"swift\"></option></datalist>")
        #expect(Progress(value: 0.7).render() == "<progress value=\"0.7\" max=\"1.0\"></progress>")
        #expect(Progress().render() == "<progress max=\"1.0\"></progress>")
        #expect(Meter(value: 6, min: 0, max: 10).render() == "<meter value=\"6.0\" min=\"0.0\" max=\"10.0\"></meter>")
        #expect(Output(content: "42").render() == "<output>42</output>")
    }
}
