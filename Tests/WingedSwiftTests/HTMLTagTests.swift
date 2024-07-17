import XCTest
@testable import WingedSwift

final class HTMLTagTests: XCTestCase {
    
    func testHTMLTagCreation() {
        let htmlTag = HTMLTag("p")
            .addAttribute(Attribute(key: "class", value: "text"))
            .setContent("Hello, World!")
        
        let expected = "<p class=\"text\">Hello, World!</p>"
        XCTAssertEqual(htmlTag.render(), expected)
    }
    
    func testHTMLTagWithMultipleAttributes() {
        let htmlTag = Img(src: "image.png", alt: "An image", attributes: [
            Attribute(key: "width", value: "100"),
            Attribute(key: "height", value: "100")
        ])
        
        let expected = "<img width=\"100\" height=\"100\" src=\"image.png\" alt=\"An image\" />"
        XCTAssertEqual(htmlTag.render(), expected)
    }
    
    func testHTMLBuilder() {
        let document = html {
            Div(children: [
                P(content: "This is a paragraph."),
                Img(src: "image.png", alt: "An image")
            ])
        }
        
        let expected = """
        <html><div><p>This is a paragraph.</p><img src="image.png" alt="An image" /></div></html>
        """
        XCTAssertEqual(document.render(), expected)
    }
    
    func testHTMLBuilderWithAttributes() {
        let document = html {
            Div(attributes: [Attribute(key: "class", value: "main-body")], children: [
                P(content: "Title"),
                P(content: "This is a paragraph.")
            ])
        }
        
        let expected = """
        <html><div class="main-body"><p>Title</p><p>This is a paragraph.</p></div></html>
        """
        XCTAssertEqual(document.render(), expected)
    }
    
    func testHTMLTable() {
        let document = html {
            Table(attributes: [Attribute(key: "class", value: "table")], children: [
                Tr(children: [
                    Th(content: "Header 1"),
                    Th(content: "Header 2")
                ]),
                Tr(children: [
                    Td(content: "Row 1, Cell 1"),
                    Td(content: "Row 1, Cell 2")
                ]),
                Tr(children: [
                    Td(content: "Row 2, Cell 1"),
                    Td(content: "Row 2, Cell 2")
                ])
            ])
        }
        
        let expected = """
        <html><table class="table"><tr><th>Header 1</th><th>Header 2</th></tr><tr><td>Row 1, Cell 1</td><td>Row 1, Cell 2</td></tr><tr><td>Row 2, Cell 1</td><td>Row 2, Cell 2</td></tr></table></html>
        """
        XCTAssertEqual(document.render(), expected)
    }

    func testHTMLList() {
        let document = html {
            Ul(attributes: [Attribute(key: "class", value: "unordered-list")], children: [
                Li(content: "Item 1"),
                Li(content: "Item 2"),
                Li(content: "Item 3")
            ])
        }
        
        let expected = """
        <html><ul class="unordered-list"><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul></html>
        """
        XCTAssertEqual(document.render(), expected)
    }
        
    func testHTMLOrderedList() {
        let document = html {
            Ol(attributes: [Attribute(key: "class", value: "ordered-list")], children: [
                Li(content: "First"),
                Li(content: "Second"),
                Li(content: "Third")
            ])
        }
        
        let expected = """
        <html><ol class="ordered-list"><li>First</li><li>Second</li><li>Third</li></ol></html>
        """
        XCTAssertEqual(document.render(), expected)
    }
    
    func testHTMLDescriptionList() {
        let document = html {
            Dl(attributes: [Attribute(key: "class", value: "description-list")], children: [
                HTMLTag("dt", content: "Term 1"),
                HTMLTag("dd", content: "Description 1"),
                HTMLTag("dt", content: "Term 2"),
                HTMLTag("dd", content: "Description 2")
            ])
        }
        
        let expected = """
        <html><dl class="description-list"><dt>Term 1</dt><dd>Description 1</dd><dt>Term 2</dt><dd>Description 2</dd></dl></html>
        """
        XCTAssertEqual(document.render(), expected)
    }

    func testHTMLStructuralTags() {
        let document = html {
            Head(children: [
                Meta(name: "description", content: "A description of the page"),
                Link(href: "styles.css", rel: "stylesheet")
            ])
            Body(children: [
                Header(children: [
                    Nav(children: [
                        A(href: "#home", content: "Home"),
                        A(href: "#about", content: "About"),
                        A(href: "#contact", content: "Contact")
                    ])
                ]),
                MainTag(children: [
                    P(content: "Welcome to our website!")
                ]),
                Footer(children: [
                    P(content: "© 2024 Company, Inc.")
                ])
            ])
        }
        
        let expected = """
        <html><head><meta name="description" content="A description of the page" /><link href="styles.css" rel="stylesheet" /></head><body><header><nav><a href="#home">Home</a><a href="#about">About</a><a href="#contact">Contact</a></nav></header><main><p>Welcome to our website!</p></main><footer><p>© 2024 Company, Inc.</p></footer></body></html>
        """
        XCTAssertEqual(document.render(), expected)
    }
}
