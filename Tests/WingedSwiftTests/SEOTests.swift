import Foundation
import Testing
@testable import WingedSwift

@Suite struct SEOTests {
    @Test func testOpenGraphMetaTags() {
        // When
        let tags = SEO.openGraph(
            title: "Test Page",
            description: "Test Description",
            image: "https://example.com/image.jpg",
            url: "https://example.com/page"
        )
        
        // Then
        #expect(tags.count == 5)
        
        let rendered = tags.map { $0.render() }.joined()
        #expect(rendered.contains("property=\"og:title\""))
        #expect(rendered.contains("content=\"Test Page\""))
        #expect(rendered.contains("property=\"og:description\""))
        #expect(rendered.contains("property=\"og:image\""))
        #expect(rendered.contains("property=\"og:url\""))
    }
    
    @Test func testOpenGraphArticle() {
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
        #expect(rendered.contains("property=\"og:type\""))
        #expect(rendered.contains("content=\"article\""))
        #expect(rendered.contains("property=\"article:author\""))
        #expect(rendered.contains("property=\"article:published_time\""))
    }
    
    @Test func testTwitterCardMetaTags() {
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
        #expect(rendered.contains("name=\"twitter:card\""))
        #expect(rendered.contains("name=\"twitter:title\""))
        #expect(rendered.contains("name=\"twitter:site\""))
        #expect(rendered.contains("content=\"@testsite\""))
    }
    
    @Test func testCommonSEOTags() {
        // When
        let tags = SEO.common(
            title: "Test",
            description: "Test Description",
            keywords: ["swift", "html"],
            author: "Test Author"
        )
        
        // Then
        let rendered = tags.map { $0.render() }.joined()
        #expect(rendered.contains("charset=\"UTF-8\""))
        #expect(rendered.contains("name=\"viewport\""))
        #expect(rendered.contains("name=\"description\""))
        #expect(rendered.contains("name=\"keywords\""))
        #expect(rendered.contains("content=\"swift, html\""))
    }
    
    @Test func testCompleteSEOTags() {
        // When
        let tags = SEO.complete(
            title: "Test",
            description: "Description",
            image: "https://example.com/image.jpg",
            url: "https://example.com"
        )
        
        // Then
        // Should include common + OG + Twitter tags
        #expect(tags.count > 10)
        
        let rendered = tags.map { $0.render() }.joined()
        #expect(rendered.contains("charset=\"UTF-8\""))
        #expect(rendered.contains("property=\"og:title\""))
        #expect(rendered.contains("name=\"twitter:card\""))
    }
    
    @Test func testMetaWithProperty() {
        // Given
        let meta = Meta(property: "og:title", content: "Test Title")
        
        // When
        let result = meta.render()
        
        // Then
        #expect(result.contains("property=\"og:title\""))
        #expect(result.contains("content=\"Test Title\""))
    }
    
    @Test func testMetaWithCharset() {
        // Given
        let meta = Meta(charset: "UTF-8")
        
        // When
        let result = meta.render()
        
        // Then
        #expect(result.contains("charset=\"UTF-8\""))
    }
}
