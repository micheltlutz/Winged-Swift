import Foundation
import Testing
@testable import WingedSwift

@Suite struct HTML5TagsTests {
    @Test func testArticleTag() {
        // Given
        let article = Article(children: [
            H1(content: "Title", escapeContent: false)
        ])
        
        // When
        let result = article.render()
        
        // Then
        #expect(result.contains("<article>"))
        #expect(result.contains("</article>"))
        #expect(result.contains("<h1>"))
    }
    
    @Test func testAsideTag() {
        // Given
        let aside = Aside(children: [
            P(content: "Sidebar", escapeContent: false)
        ])
        
        // When
        let result = aside.render()
        
        // Then
        #expect(result.contains("<aside>"))
        #expect(result.contains("</aside>"))
    }
    
    @Test func testFigureAndFigcaption() {
        // Given
        let figure = Figure(children: [
            Img(src: "image.jpg", alt: "Test"),
            Figcaption(content: "Image caption", escapeContent: false)
        ])
        
        // When
        let result = figure.render()
        
        // Then
        #expect(result.contains("<figure>"))
        #expect(result.contains("<figcaption>"))
    }
    
    @Test func testTimeTag() {
        // Given
        let time = Time(datetime: "2024-01-15", content: "January 15, 2024", escapeContent: false)
        
        // When
        let result = time.render()
        
        // Then
        #expect(result.contains("<time"))
        #expect(result.contains("datetime=\"2024-01-15\""))
        #expect(result.contains("January 15, 2024"))
    }
    
    @Test func testMarkTag() {
        // Given
        let mark = Mark(content: "highlighted", escapeContent: false)
        
        // When
        let result = mark.render()
        
        // Then
        #expect(result.contains("<mark>"))
        #expect(result.contains("highlighted"))
    }
    
    @Test func testHeadingTags() {
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
            #expect(result.contains("<h\(level)>"))
            #expect(result.contains("</h\(level)>"))
        }
    }
}
