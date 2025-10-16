import XCTest
@testable import WingedSwift

final class AttributeHelpersTests: XCTestCase {
    func testDataAttribute() {
        // Given
        let div = Div()
        
        // When
        div.dataAttribute(key: "toggle", value: "modal")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("data-toggle=\"modal\""))
    }
    
    func testMultipleDataAttributes() {
        // Given
        let div = Div()
        
        // When
        div.dataAttributes([
            "id": "123",
            "type": "product"
        ])
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("data-id=\"123\""))
        XCTAssertTrue(result.contains("data-type=\"product\""))
    }
    
    func testAriaAttribute() {
        // Given
        let button = Button()
        
        // When
        button.ariaAttribute(key: "label", value: "Close")
        let result = button.render()
        
        // Then
        XCTAssertTrue(result.contains("aria-label=\"Close\""))
    }
    
    func testMultipleAriaAttributes() {
        // Given
        let nav = Nav()
        
        // When
        nav.ariaAttributes([
            "label": "Main navigation",
            "expanded": "true"
        ])
        let result = nav.render()
        
        // Then
        XCTAssertTrue(result.contains("aria-label=\"Main navigation\""))
        XCTAssertTrue(result.contains("aria-expanded=\"true\""))
    }
    
    func testSetRole() {
        // Given
        let div = Div()
        
        // When
        div.setRole("navigation")
        let result = div.render()
        
        // Then
        XCTAssertTrue(result.contains("role=\"navigation\""))
    }
    
    func testSetAttribute() {
        // Given
        let input = Input(type: "text", name: "email")
        
        // When
        input.setAttribute(key: "placeholder", value: "Enter email")
            .setAttribute(key: "required", value: "true")
        let result = input.render()
        
        // Then
        XCTAssertTrue(result.contains("placeholder=\"Enter email\""))
        XCTAssertTrue(result.contains("required=\"true\""))
    }
}

