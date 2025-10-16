import XCTest
@testable import WingedSwift

final class HTML5TagsTests: XCTestCase {
    func testArticleTag() {
        // Given
        let article = Article(children: [
            H1(content: "Title", escapeContent: false)
        ])
        
        // When
        let result = article.render()
        
        // Then
        XCTAssertTrue(result.contains("<article>"))
        XCTAssertTrue(result.contains("</article>"))
        XCTAssertTrue(result.contains("<h1>"))
    }
    
    func testAsideTag() {
        // Given
        let aside = Aside(children: [
            P(content: "Sidebar", escapeContent: false)
        ])
        
        // When
        let result = aside.render()
        
        // Then
        XCTAssertTrue(result.contains("<aside>"))
        XCTAssertTrue(result.contains("</aside>"))
    }
    
    func testFigureAndFigcaption() {
        // Given
        let figure = Figure(children: [
            Img(src: "image.jpg", alt: "Test"),
            Figcaption(content: "Image caption", escapeContent: false)
        ])
        
        // When
        let result = figure.render()
        
        // Then
        XCTAssertTrue(result.contains("<figure>"))
        XCTAssertTrue(result.contains("<figcaption>"))
    }
    
    func testTimeTag() {
        // Given
        let time = Time(datetime: "2024-01-15", content: "January 15, 2024", escapeContent: false)
        
        // When
        let result = time.render()
        
        // Then
        XCTAssertTrue(result.contains("<time"))
        XCTAssertTrue(result.contains("datetime=\"2024-01-15\""))
        XCTAssertTrue(result.contains("January 15, 2024"))
    }
    
    func testMarkTag() {
        // Given
        let mark = Mark(content: "highlighted", escapeContent: false)
        
        // When
        let result = mark.render()
        
        // Then
        XCTAssertTrue(result.contains("<mark>"))
        XCTAssertTrue(result.contains("highlighted"))
    }
    
    func testHeadingTags() {
        // Test all heading levels
        let headings = [
            H1(content: "H1", escapeContent: false),
            H2(content: "H2", escapeContent: false),
            H3(content: "H3", escapeContent: false),
            H4(content: "H4", escapeContent: false),
            H5(content: "H5", escapeContent: false),
            H6(content: "H6", escapeContent: false)
        ]
        
        for (index, heading) in headings.enumerated() {
            let result = heading.render()
            let level = index + 1
            XCTAssertTrue(result.contains("<h\(level)>"))
            XCTAssertTrue(result.contains("</h\(level)>"))
        }
    }
}

