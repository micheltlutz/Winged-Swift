import XCTest
@testable import WingedSwift

final class CSSHelpersTests: XCTestCase {
    func testAddSingleClass() {
        // Given
        let div = Div()
        
        // When
        div.addClass("container")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("class=\"container\""))
    }
    
    func testAddMultipleClasses() {
        // Given
        let div = Div()
        
        // When
        div.addClass("flex")
            .addClass("items-center")
            .addClass("justify-between")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("class=\"flex items-center justify-between\""))
    }
    
    func testAddClassesArray() {
        // Given
        let div = Div()
        
        // When
        div.addClasses(["container", "mx-auto", "p-4"])
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("class=\"container mx-auto p-4\""))
    }
    
    func testSetId() {
        // Given
        let div = Div()
        
        // When
        div.setId("main-content")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("id=\"main-content\""))
    }
    
    func testSetIdReplacesExisting() {
        // Given
        let div = Div()
        
        // When
        div.setId("old-id")
            .setId("new-id")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("id=\"new-id\""))
        XCTAssertFalse(result.contains("id=\"old-id\""))
    }
    
    func testSetStyle() {
        // Given
        let div = Div()
        
        // When
        div.setStyle("color: red; margin: 10px;")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("style=\"color: red; margin: 10px;\""))
    }
    
    func testChainedHelpers() {
        // Given
        let div = Div()
        
        // When
        div.setId("content")
            .addClass("container")
            .addClass("active")
            .setStyle("padding: 20px;")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("id=\"content\""))
        XCTAssertTrue(result.contains("class=\"container active\""))
        XCTAssertTrue(result.contains("style=\"padding: 20px;\""))
    }
}

