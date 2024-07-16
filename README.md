# WingedSwift

![main](https://github.com/micheltlutz/Winged-Swift/actions/workflows/tests.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/micheltlutz/Winged-Swift/graph/badge.svg?token=3pxQp1KgnV)](https://codecov.io/gh/micheltlutz/Winged-Swift)
[![codebeat badge](https://codebeat.co/badges/b0a28fb9-ffba-4214-980f-a4333781f98f)](https://codebeat.co/projects/github-com-micheltlutz-winged-swift-main)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
# =============

WingedSwift is a DSL (Domain-Specific Language) library for writing HTML efficiently using 100% Swift.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Usage Examples](#usage-examples)
- [Documentation](#documentation)
- [Contribution](#contribution)
- [License](#license)

## Installation

### Swift Package Manager

To add WingedSwift to your project, add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/WingedSwift.git", from: "1.0.0")
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

The complete documentation is available [here](docs/index.html).

### Generating the Documentation

To generate the DocC documentation, use the following command in the terminal:

```bash
swift package generate-documentation --target WingedSwift --output-path ./docs
```

```bash
open ./docs/index.html
```

## Contribution

Contributions are welcome! Please follow the steps below to contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
