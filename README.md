# WingedSwift

![main](https://github.com/micheltlutz/Winged-Swift/actions/workflows/tests.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/micheltlutz/Winged-Swift/graph/badge.svg?token=3pxQp1KgnV)](https://codecov.io/gh/micheltlutz/Winged-Swift)
[![codebeat badge](https://codebeat.co/badges/b0a28fb9-ffba-4214-980f-a4333781f98f)](https://codebeat.co/projects/github-com-micheltlutz-winged-swift-main)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)


![Swift Versions](https://img.shields.io/badge/Swift-5.5%2B-orange.svg?style=flat)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https://swiftpackageindex.com/api/packages/micheltlutz/Winged-Swift/badge?type=platforms)](https://swiftpackageindex.com/micheltlutz/Winged-Swift)


[![](https://img.shields.io/endpoint?url=https://swiftpackageindex.com/api/packages/micheltlutz/Winged-Swift/badge?type=swift-versions)](https://swiftpackageindex.com/micheltlutz/Winged-Swift)


# =============

WingedSwift is an innovative Domain-Specific Language (DSL) library for efficient HTML writing in Swift. Mirroring its Python counterpart, WingedSwift is based on the DSL concept, focusing on simplification and specificity in HTML generation. Using the Composite design pattern, the library enables developers to construct HTML structures in a logical, organized, and reusable manner.

This library is created to be fully independent, not requiring integration with specific server frameworks or front-end libraries. This offers developers the freedom to use WingedSwift across a variety of projects, from simple static pages to complex web applications, keeping the code clean, readable, and efficient.

## Table of Contents

- [Swift Package Index](https://swiftpackageindex.com/micheltlutz/Winged-Swift)
- [Demo](#demo)
- [Installation](#installation)
- [Usage](#usage)
  - [Usage Examples](#usage-examples)
- [Documentation](#documentation)
- [Contribution](#contribution)
- [License](#license)

## Demo

- [https://github.com/micheltlutz/WingedSwiftDemoVapor](https://github.com/micheltlutz/WingedSwiftDemoVapor)

## Installation

### Swift Package Manager

To add WingedSwift to your project, add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.2.2")
]
```


And include `WingedSwift` as a dependency in your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["WingedSwift"]),
]
```

To include in Vapor project use this line code in `executableTarget`.

```swift
.product(name: "WingedSwift", package: "Winged-Swift")
```

## Usage

WingedSwift allows you to build HTML documents using a DSL syntax in Swift. Here are some examples of how to use the library.

### Basic Example

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
```

### Working with Forms

```swift
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

print(form.render())
```

### Code Structure

```swift
let pre = Pre(content: """
This is preformatted text.
It preserves whitespace and line breaks.
""")

print(pre.render())

let code = Code(content: """
let x = 10
print(x)
""")

print(code.render())

let embed = Embed(src: "video.mp4", type: "video/mp4")

print(embed.render())
```

## Documentation

The complete documentation is available [here soon]().

### Generating the Documentation

To generate the DocC documentation, use the following command in the terminal:

```bash
swift package generate-documentation --target WingedSwift --output-path ./docs
```

```bash
open ./docs/index.html
```

### Preview Documentation

```
swift package --disable-sandbox preview-documentation --target WingedSwift
```

- [http://localhost:8080/documentation/wingedswift](http://localhost:8080/documentation/wingedswift)


## Contribution

Contributions are welcome! Please follow the steps below to contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
