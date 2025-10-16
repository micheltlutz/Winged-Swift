import XCTest
@testable import WingedSwift

final class SEOTests: XCTestCase {
    func testOpenGraphMetaTags() {
        // When
        let tags = SEO.openGraph(
            title: "Test Page",
            description: "Test Description",
            image: "https://example.com/image.jpg",
            url: "https://example.com/page"
        )
        
        // Then
        XCTAssertEqual(tags.count, 5)
        
        let rendered = tags.map { $0.render() }.joined()
        XCTAssertTrue(rendered.contains("property=\"og:title\""))
        XCTAssertTrue(rendered.contains("content=\"Test Page\""))
        XCTAssertTrue(rendered.contains("property=\"og:description\""))
        XCTAssertTrue(rendered.contains("property=\"og:image\""))
        XCTAssertTrue(rendered.contains("property=\"og:url\""))
    }
    
    func testOpenGraphArticle() {
        // When
        let tags = SEO.openGraphArticle(
            title: "Article Title",
            description: "Article Description",
            image: "https://example.com/image.jpg",
            url: "https://example.com/article",
            author: "John Doe",
            publishedTime: "2024-01-15T12:00:00Z"
        )
        
        // Then
        let rendered = tags.map { $0.render() }.joined()
        XCTAssertTrue(rendered.contains("property=\"og:type\""))
        XCTAssertTrue(rendered.contains("content=\"article\""))
        XCTAssertTrue(rendered.contains("property=\"article:author\""))
        XCTAssertTrue(rendered.contains("property=\"article:published_time\""))
    }
    
    func testTwitterCardMetaTags() {
        // When
        let tags = SEO.twitterCard(
            title: "Test Page",
            description: "Test Description",
            image: "https://example.com/image.jpg",
            site: "@testsite",
            creator: "@creator"
        )
        
        // Then
        let rendered = tags.map { $0.render() }.joined()
        XCTAssertTrue(rendered.contains("name=\"twitter:card\""))
        XCTAssertTrue(rendered.contains("name=\"twitter:title\""))
        XCTAssertTrue(rendered.contains("name=\"twitter:site\""))
        XCTAssertTrue(rendered.contains("content=\"@testsite\""))
    }
    
    func testCommonSEOTags() {
        // When
        let tags = SEO.common(
            title: "Test",
            description: "Test Description",
            keywords: ["swift", "html"],
            author: "Test Author"
        )
        
        // Then
        let rendered = tags.map { $0.render() }.joined()
        XCTAssertTrue(rendered.contains("charset=\"UTF-8\""))
        XCTAssertTrue(rendered.contains("name=\"viewport\""))
        XCTAssertTrue(rendered.contains("name=\"description\""))
        XCTAssertTrue(rendered.contains("name=\"keywords\""))
        XCTAssertTrue(rendered.contains("content=\"swift, html\""))
    }
    
    func testCompleteSEOTags() {
        // When
        let tags = SEO.complete(
            title: "Test",
            description: "Description",
            image: "https://example.com/image.jpg",
            url: "https://example.com"
        )
        
        // Then
        // Should include common + OG + Twitter tags
        XCTAssertTrue(tags.count > 10)
        
        let rendered = tags.map { $0.render() }.joined()
        XCTAssertTrue(rendered.contains("charset=\"UTF-8\""))
        XCTAssertTrue(rendered.contains("property=\"og:title\""))
        XCTAssertTrue(rendered.contains("name=\"twitter:card\""))
    }
    
    func testMetaWithProperty() {
        // Given
        let meta = Meta(property: "og:title", content: "Test Title")
        
        // When
        let result = meta.render()
        
        // Then
        XCTAssertTrue(result.contains("property=\"og:title\""))
        XCTAssertTrue(result.contains("content=\"Test Title\""))
    }
    
    func testMetaWithCharset() {
        // Given
        let meta = Meta(charset: "UTF-8")
        
        // When
        let result = meta.render()
        
        // Then
        XCTAssertTrue(result.contains("charset=\"UTF-8\""))
    }
}

