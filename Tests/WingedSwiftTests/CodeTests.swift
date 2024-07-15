import XCTest
@testable import WingedSwift

final class CodeTests: XCTestCase {

    func testPreTag() {
        let pre = Pre(content: """
        This is preformatted text.
        It preserves whitespace and line breaks.
        """)

        let expected = """
        <pre>This is preformatted text.
        It preserves whitespace and line breaks.</pre>
        """
        XCTAssertEqual(pre.render(), expected)
    }

    func testCodeTag() {
        let code = Code(content: """
        let x = 10
        print(x)
        """)

        let expected = """
        <code>let x = 10
        print(x)</code>
        """
        XCTAssertEqual(code.render(), expected)
    }

    func testEmbedTag() {
        let embed = Embed(src: "video.mp4", type: "video/mp4")

        let expected = """
        <embed src="video.mp4" type="video/mp4" />
        """
        XCTAssertEqual(embed.render(), expected)
    }
}
