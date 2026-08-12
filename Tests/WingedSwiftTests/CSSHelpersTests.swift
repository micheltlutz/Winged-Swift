import Foundation
import Testing
@testable import WingedSwift

@Suite struct CSSHelpersTests {
    @Test func testChainingPreservesTheConcreteType() {
        // A chained helper must still be usable where the concrete tag type is expected.
        let card: Div = Div().addClass("card").setId("hero").setRole("region")

        #expect(card.render().contains("<div class=\"card\" id=\"hero\" role=\"region\">"))
    }

    @Test func testAddClassEscapesQuotesInsteadOfBreakingOutOfTheAttribute() {
        // Given a class name built from untrusted data
        let div = Div().addClass("card").addClass("\" onclick=\"alert(1)")

        // When
        let result = div.render()

        // Then the injected quote is neutralised
        #expect(!(result.contains("onclick=\"alert(1)\"")))
        #expect(result.contains("&quot; onclick=&quot;alert(1)"))
    }

    @Test func testAddClassDoesNotDoubleEscapeExistingValues() {
        let div = Div().addClass("a&b").addClass("c")

        #expect(div.render().contains("class=\"a&amp;b c\""))
        #expect(!(div.render().contains("&amp;amp;")))
    }

    @Test func testSetStyleEscapesQuotes() {
        let div = Div().setStyle("font-family: \"Inter\", sans-serif")

        #expect(div.render().contains("style=\"font-family: &quot;Inter&quot;, sans-serif\""))
    }

    @Test func testAddSingleClass() {
        // Given
        let div = Div()
        
        // When
        div.addClass("container")
        let result = div.render()
        
        // Then
        #expect(result.contains("class=\"container\""))
    }
    
    @Test func testAddMultipleClasses() {
        // Given
        let div = Div()
        
        // When
        div.addClass("flex")
            .addClass("items-center")
            .addClass("justify-between")
        let result = div.render()
        
        // Then
        #expect(result.contains("class=\"flex items-center justify-between\""))
    }
    
    @Test func testAddClassesArray() {
        // Given
        let div = Div()
        
        // When
        div.addClasses(["container", "mx-auto", "p-4"])
        let result = div.render()
        
        // Then
        #expect(result.contains("class=\"container mx-auto p-4\""))
    }
    
    @Test func testSetId() {
        // Given
        let div = Div()
        
        // When
        div.setId("main-content")
        let result = div.render()
        
        // Then
        #expect(result.contains("id=\"main-content\""))
    }
    
    @Test func testSetIdReplacesExisting() {
        // Given
        let div = Div()
        
        // When
        div.setId("old-id")
            .setId("new-id")
        let result = div.render()
        
        // Then
        #expect(result.contains("id=\"new-id\""))
        #expect(!(result.contains("id=\"old-id\"")))
    }
    
    @Test func testSetStyle() {
        // Given
        let div = Div()
        
        // When
        div.setStyle("color: red; margin: 10px;")
        let result = div.render()
        
        // Then
        #expect(result.contains("style=\"color: red; margin: 10px;\""))
    }
    
    @Test func testChainedHelpers() {
        // Given
        let div = Div()
        
        // When
        div.setId("content")
            .addClass("container")
            .addClass("active")
            .setStyle("padding: 20px;")
        let result = div.render()
        
        // Then
        #expect(result.contains("id=\"content\""))
        #expect(result.contains("class=\"container active\""))
        #expect(result.contains("style=\"padding: 20px;\""))
    }
}
