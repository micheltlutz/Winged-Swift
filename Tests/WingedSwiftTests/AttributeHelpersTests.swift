import Foundation
import Testing
@testable import WingedSwift

@Suite struct AttributeHelpersTests {
    @Test func testDataAttribute() {
        // Given
        let div = Div()
        
        // When
        div.dataAttribute(key: "toggle", value: "modal")
        let result = div.render()
        
        // Then
        #expect(result.contains("data-toggle=\"modal\""))
    }
    
    @Test func testMultipleDataAttributes() {
        // Given
        let div = Div()
        
        // When
        div.dataAttributes([
            "id": "123",
            "type": "product"
        ])
        let result = div.render()
        
        // Then
        #expect(result.contains("data-id=\"123\""))
        #expect(result.contains("data-type=\"product\""))
    }
    
    @Test func testAriaAttribute() {
        // Given
        let button = Button()
        
        // When
        button.ariaAttribute(key: "label", value: "Close")
        let result = button.render()
        
        // Then
        #expect(result.contains("aria-label=\"Close\""))
    }
    
    @Test func testMultipleAriaAttributes() {
        // Given
        let nav = Nav()
        
        // When
        nav.ariaAttributes([
            "label": "Main navigation",
            "expanded": "true"
        ])
        let result = nav.render()
        
        // Then
        #expect(result.contains("aria-label=\"Main navigation\""))
        #expect(result.contains("aria-expanded=\"true\""))
    }
    
    @Test func testSetRole() {
        // Given
        let div = Div()
        
        // When
        div.setRole("navigation")
        let result = div.render()
        
        // Then
        #expect(result.contains("role=\"navigation\""))
    }
    
    @Test func testSetAttribute() {
        // Given
        let input = Input(type: "text", name: "email")
        
        // When
        input.setAttribute(key: "placeholder", value: "Enter email")
            .setAttribute(key: "required", value: "true")
        let result = input.render()
        
        // Then
        #expect(result.contains("placeholder=\"Enter email\""))
        #expect(result.contains("required=\"true\""))
    }
}
