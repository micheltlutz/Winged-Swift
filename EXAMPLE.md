# Example Documentation

Welcome to the example documentation for WingedSwift.

## Overview

This is an example page to demonstrate how to create documentation using DocC.

## Usage

Below is an example of how to use the `HTMLTag` class in WingedSwift:

```swift
import WingedSwift

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
        Main(children: [
            P(content: "Welcome to our website!")
        ]),
        Footer(children: [
            P(content: "© 2024 Company, Inc.")
        ])
    ])
}

print(document.render())
