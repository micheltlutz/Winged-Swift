import XCTest
@testable import WingedSwift

final class FormTests: XCTestCase {

    func testFormCreation() {
        let form = Form(attributes: [Attribute(key: "action", value: "/submit")], children: [
            Fieldset(children: [
                Label(for: "name", content: "Name"),
                Input(type: "text", name: "name")
            ]),
            Fieldset(children: [
                Label(for: "message", content: "Message"),
                Textarea(name: "message")
            ]),
            Input(type: "submit", name: "submit", value: "Send")
        ])

        let expected = """
        <form action="/submit"><fieldset><label for="name">Name</label><input type="text" name="name" /></fieldset><fieldset><label for="message">Message</label><textarea name="message"></textarea></fieldset><input type="submit" name="submit" value="Send" /></form>
        """
        XCTAssertEqual(form.render(), expected)
    }
    
    func testSelectAndOptions() {
        let select = Select(name: "options", children: [
            Option(value: "1", content: "Option 1"),
            Option(value: "2", content: "Option 2"),
            Option(value: "3", content: "Option 3")
        ])

        let expected = """
        <select name="options"><option value="1">Option 1</option><option value="2">Option 2</option><option value="3">Option 3</option></select>
        """
        XCTAssertEqual(select.render(), expected)
    }
    
    func testLabel() {
        let label = Label(for: "username", content: "Username")

        let expected = """
        <label for="username">Username</label>
        """
        XCTAssertEqual(label.render(), expected)
    }
    
    func testInput() {
        let input = Input(type: "text", name: "username", value: "JohnDoe")

        let expected = """
        <input type="text" name="username" value="JohnDoe" />
        """
        XCTAssertEqual(input.render(), expected)
    }
    
    func testTextarea() {
        let textarea = Textarea(name: "message", content: "Hello, World!")

        let expected = """
        <textarea name="message">Hello, World!</textarea>
        """
        XCTAssertEqual(textarea.render(), expected)
    }
    
    func testFieldset() {
        let fieldset = Fieldset(children: [
            Label(for: "name", content: "Name"),
            Input(type: "text", name: "name")
        ])

        let expected = """
        <fieldset><label for="name">Name</label><input type="text" name="name" /></fieldset>
        """
        XCTAssertEqual(fieldset.render(), expected)
    }
    
    func testSection() {
        let section = Section(children: [
            P(content: "This is a section.")
        ])

        let expected = """
        <section><p>This is a section.</p></section>
        """
        XCTAssertEqual(section.render(), expected)
    }
}
