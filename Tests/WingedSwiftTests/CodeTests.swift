import Foundation
import Testing
@testable import WingedSwift

@Suite struct CodeTests {

    @Test func testPreTag() {
        let pre = Pre(content: """
        This is preformatted text.
        It preserves whitespace and line breaks.
        """)

        let expected = """
        <pre>This is preformatted text.
        It preserves whitespace and line breaks.</pre>
        """
        #expect(pre.render() == expected)
    }

    @Test func testCodeTag() {
        let code = Code(content: """
        let x = 10
        print(x)
        """)

        let expected = """
        <code>let x = 10
        print(x)</code>
        """
        #expect(code.render() == expected)
    }

    @Test func testEmbedTag() {
        let embed = Embed(src: "video.mp4", type: "video/mp4")

        let expected = """
        <embed src="video.mp4" type="video/mp4">
        """
        #expect(embed.render() == expected)
    }
}
