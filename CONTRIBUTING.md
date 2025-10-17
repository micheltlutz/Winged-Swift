# 🤝 Contributing to WingedSwift

Thank you for considering contributing to **WingedSwift**! We're thrilled to have you here. This guide will help you get started with contributing to the project.

**WingedSwift is an open-source project** and we welcome contributions from the community. Whether you're fixing bugs, adding features, improving documentation, or sharing ideas, your help is appreciated!

## 📋 Table of Contents

- [Ways to Contribute](#ways-to-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Guidelines](#commit-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)
- [Getting Help](#getting-help)
- [Code of Conduct](#code-of-conduct)

---

## 🎯 Ways to Contribute

- 🐛 **Report Bugs**: Open an issue with details about the problem
- ✨ **Suggest Features**: Share your ideas for new functionality
- 📝 **Improve Documentation**: Help make our docs clearer and more comprehensive
- 🔧 **Submit Code**: Fix bugs or implement new features
- 💬 **Help Others**: Answer questions in issues and discussions
- 🌍 **Translate**: Help translate documentation to other languages
- 🧪 **Add Tests**: Improve test coverage
- 📖 **Write Tutorials**: Create blog posts, videos, or examples

---

## 🚀 Getting Started

### 1. Set Up Your Development Environment

```bash
# Fork the repository on GitHub first
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/Winged-Swift.git
cd Winged-Swift

# Add upstream remote to keep your fork in sync
git remote add upstream https://github.com/micheltlutz/Winged-Swift.git

# Verify everything works
swift build
swift test
```

### 2. Keep Your Fork Updated

```bash
# Fetch latest changes from upstream
git fetch upstream

# Merge upstream changes to your main branch
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

### 3. Use Local Package in Your Projects

Test your changes in a real project by using the local path:

#### Create a Test Project

```bash
mkdir ~/WingedSwiftTest
cd ~/WingedSwiftTest
swift package init --type executable
```

#### Edit Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WingedSwiftTest",
    dependencies: [
        // Use your local fork for testing
        .package(path: "../Winged-Swift")
    ],
    targets: [
        .executableTarget(
            name: "WingedSwiftTest",
            dependencies: [
                .product(name: "WingedSwift", package: "Winged-Swift")
            ]
        )
    ]
)
```

#### Test Your Changes

```swift
// Sources/main.swift
import WingedSwift

let page = html {
    Head(children: [Title(content: "Testing")])
    Body(children: [H1(content: "Testing My Changes")])
}

print(page.render(pretty: true))
```

```bash
swift run
```

This workflow allows you to:
- ✅ Test your changes in a real-world scenario
- ✅ Verify the API is user-friendly
- ✅ Catch integration issues early
- ✅ Ensure documentation matches implementation

---

## 🔄 Development Workflow

### 1. Create a Feature Branch

```bash
# Always create a new branch for your changes
git checkout -b feature/my-feature-name

# Or for bug fixes
git checkout -b fix/bug-description

# Or for documentation
git checkout -b docs/improve-readme
```

### 2. Make Your Changes

- Write clean, readable code following Swift conventions
- Add tests for new functionality
- Update documentation as needed
- Run tests to ensure nothing breaks: `swift test`
- Run SwiftLint: `swiftlint lint`

### 3. Test Thoroughly

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter HTMLEscapeTests

# Build in release mode
swift build -c release

# Run SwiftLint
swiftlint lint

# Test code coverage
swift test --enable-code-coverage
```

### 4. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a descriptive message (see guidelines below)
git commit -m "Add: support for new HTML tag XYZ"

# Push to your fork
git push origin feature/my-feature-name
```

### 5. Open a Pull Request

1. Go to your fork on GitHub
2. Click **"New Pull Request"**
3. Select your branch
4. Fill in the PR template with:
   - **Description of changes**: What did you change and why?
   - **Related issues**: Link any related issues (#123)
   - **Testing performed**: How did you test your changes?
   - **Breaking changes**: Any API changes that affect existing users?
5. Submit and wait for review

### 6. Respond to Feedback

- Be responsive to code review comments
- Make requested changes promptly
- Ask questions if something is unclear
- Be patient and respectful

---

## 📝 Commit Message Guidelines

Use clear, descriptive commit messages following this format:

### Commit Types

- **Add**: `Add: new Feature component`
- **Fix**: `Fix: escape HTML in attribute values`
- **Update**: `Update: SEO helpers with new OG tags`
- **Docs**: `Docs: add examples for Layout system`
- **Test**: `Test: add tests for Pretty Print feature`
- **Refactor**: `Refactor: simplify HTMLTag rendering logic`
- **Perf**: `Perf: optimize HTML rendering speed`
- **Style**: `Style: format code with SwiftLint`

### Examples

```bash
# Good commits
git commit -m "Add: Article and Aside HTML5 tags"
git commit -m "Fix: XSS vulnerability in content escaping"
git commit -m "Docs: improve SEO helpers documentation"
git commit -m "Test: add comprehensive tests for CSS helpers"

# Bad commits
git commit -m "updates"
git commit -m "fix bug"
git commit -m "wip"
```

### Multi-line Commits

For larger changes:

```bash
git commit -m "Add: Static Site Generator

Features:
- Generate HTML files to disk
- Copy assets automatically
- Clean output directory
- Support for multiple pages

Fixes #42"
```

---

## 💅 Code Style Guidelines

### Swift API Design Guidelines

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Use clear, descriptive names
- Prefer methods and properties over free functions
- Use lowercase for parameter names
- Document all public APIs

### SwiftLint

We use SwiftLint to maintain code quality:

```bash
# Install SwiftLint
brew install swiftlint

# Run linting
swiftlint lint

# Auto-fix issues
swiftlint --fix
```

### Specific Guidelines

#### Naming Conventions

```swift
// ✅ Good
public class StaticSiteGenerator { }
public func addClass(_ className: String) -> HTMLTag { }
let sitemapUrls: [SitemapURL]

// ❌ Bad
public class SSG { }
public func add(_ c: String) -> HTMLTag { }
let urls: [SitemapURL]
```

#### Documentation

All public APIs must have documentation:

```swift
/// Adds a CSS class to the HTML tag.
///
/// If the tag already has a class attribute, the new class is appended.
///
/// - Parameter className: The CSS class name to add.
/// - Returns: The HTMLTag instance for method chaining.
///
/// ## Example
/// ```swift
/// let div = Div().addClass("container")
/// ```
@discardableResult
public func addClass(_ className: String) -> HTMLTag {
    // Implementation
}
```

#### Function Length

- Keep functions focused and single-purpose
- Aim for functions under 50 lines
- Extract complex logic into helper methods

#### Error Handling

```swift
// ✅ Good - throw errors with context
throw GenerationError.fileNotFound(path: fullPath)

// ❌ Bad - generic errors
throw NSError(...)
```

---

## 🧪 Testing

We aim for high test coverage to ensure code quality and prevent regressions.

### Writing Tests

```swift
import XCTest
@testable import WingedSwift

final class MyFeatureTests: XCTestCase {
    func testMyFeature() {
        // Given
        let input = "test"
        
        // When
        let result = myFunction(input)
        
        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter MyFeatureTests

# Run specific test method
swift test --filter MyFeatureTests.testMyFeature

# Run with coverage
swift test --enable-code-coverage

# Verbose output
swift test -v
```

### Test Coverage

- Aim for 80%+ code coverage on new features
- All public APIs should have tests
- Test both success and failure cases
- Test edge cases and error conditions

### Test Organization

Place tests in appropriate files:
- `HTMLTagTests.swift` - Core HTML tag functionality
- `SEOTests.swift` - SEO-related features
- `YourFeatureTests.swift` - New feature tests

---

## 📚 Documentation

### What to Document

- All public classes, methods, and properties
- Complex algorithms or business logic
- Examples for common use cases
- Any breaking changes in CHANGELOG.md

### Documentation Style

Use Swift's documentation markup:

```swift
/// Brief description of what this does.
///
/// Longer description with more details about the functionality,
/// edge cases, or important notes.
///
/// - Parameters:
///   - param1: Description of first parameter.
///   - param2: Description of second parameter.
/// - Returns: Description of return value.
/// - Throws: Description of what errors can be thrown.
///
/// ## Example
/// ```swift
/// let result = myFunction(param1: "value", param2: 42)
/// ```
public func myFunction(param1: String, param2: Int) throws -> String {
    // Implementation
}
```

### Updating Documentation

When making changes:

1. Update inline code documentation
2. Update README.md if it affects main features
3. Update CHANGELOG.md with your changes
4. Add examples to EXAMPLE.md if appropriate
5. Update GETTING_STARTED.md for beginner-facing changes

---

## 🔍 Code Review Process

### What to Expect

1. **Automated Checks**: CI will run tests, linting, and coverage
2. **Code Review**: Maintainers will review your code
3. **Feedback**: You may receive suggestions for improvements
4. **Iteration**: Make requested changes and push updates
5. **Merge**: Once approved, your PR will be merged!

### Review Checklist

Before requesting review, ensure:

- [ ] All tests pass locally
- [ ] SwiftLint has 0 violations
- [ ] Code is well-documented
- [ ] CHANGELOG.md is updated
- [ ] No breaking changes (or clearly documented)
- [ ] Examples are updated if needed

---

## 🐛 Reporting Bugs

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Create HTML with '...'
2. Call render()
3. See error

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened.

**Code snippet**
```swift
let page = html { ... }
print(page.render())
```

**Environment:**
- OS: macOS 14.0 / Ubuntu 22.04
- Swift version: 5.10
- WingedSwift version: 1.3.0

**Additional context**
Any other relevant information.
```

---

## ✨ Feature Requests

### Feature Request Template

```markdown
**Feature description**
Clear description of the feature.

**Use case**
Why is this feature needed? What problem does it solve?

**Proposed solution**
How you think it should work.

**Code example**
```swift
// Example of how the feature would be used
let component = NewFeature(...)
```

**Alternatives considered**
Other solutions you've thought about.
```

---

## 🎓 Good First Issues

New to the project? Look for issues labeled `good first issue`:

https://github.com/micheltlutz/Winged-Swift/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22

These are beginner-friendly issues perfect for your first contribution!

---

## 💡 Development Tips

### Xcode Setup

```bash
cd Winged-Swift
open Package.swift
```

Xcode will:
- Load the package automatically
- Provide autocomplete
- Allow breakpoint debugging
- Run tests with ⌘U

### Quick Development Cycle

```bash
# Terminal 1: Watch for changes
fswatch -o Sources/ | while read; do swift test; done

# Terminal 2: Make your changes
# Tests run automatically!
```

### Debugging

```swift
// Add print statements
print("DEBUG: value = \(value)")

// Or use debugger in Xcode
// Set breakpoints and step through
```

---

## 🌍 Platform Testing

### Test on Multiple Platforms

Since WingedSwift is cross-platform, consider testing on:

- **macOS**: Your main development platform
- **Linux**: Use Docker for quick testing
- **CI**: Let GitHub Actions test for you

### Docker Testing (Linux)

```bash
# Pull Swift Docker image
docker pull swift:5.10

# Run container
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  swift:5.10 \
  bash

# Inside container
swift build
swift test
```

---

## 🏆 Recognition

All contributors are recognized and appreciated!

- Contributors are listed in release notes
- Significant contributions get special mentions
- We may feature your work on social media

---

## 📞 Getting Help

### Before Asking

1. Check existing [documentation](README.md)
2. Search [existing issues](https://github.com/micheltlutz/Winged-Swift/issues)
3. Read [Getting Started guide](GETTING_STARTED.md)

### Where to Ask

- 💭 **General Questions**: [GitHub Discussions](https://github.com/micheltlutz/Winged-Swift/discussions)
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/micheltlutz/Winged-Swift/issues)
- 📧 **Private Contact**: [micheltlutz.me](https://micheltlutz.me)
- 🐦 **Social**: [@micheltlutz](https://twitter.com/micheltlutz)

---

## 📜 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Give constructive feedback
- Focus on what's best for the community
- Show empathy towards others

### Enforcement

Violations of the code of conduct may result in:
1. Warning
2. Temporary ban
3. Permanent ban

Report violations to the project maintainers.

---

## 🎯 Contribution Workflow Summary

```
1. Fork & Clone
   ↓
2. Create feature branch
   ↓
3. Make changes + write tests
   ↓
4. Run tests & linting
   ↓
5. Commit with clear message
   ↓
6. Push to your fork
   ↓
7. Open Pull Request
   ↓
8. Respond to feedback
   ↓
9. Merge! 🎉
```

---

## 📚 Additional Resources

- 📖 [README](README.md) - Project overview
- 🚀 [Getting Started](GETTING_STARTED.md) - Step-by-step guide
- 💡 [Examples](EXAMPLE.md) - Code examples
- 🎯 [Quick Start](QUICK_START_GUIDE.md) - 3 commands to start
- 📋 [Changelog](CHANGELOG.md) - Version history
- 🔒 [Security](SECURITY.md) - Security policy

---

## ❤️ Thank You!

Every contribution, no matter how small, makes WingedSwift better. We appreciate your time and effort!

**Happy coding! 🚀**

---

**Maintained by**: [@micheltlutz](https://github.com/micheltlutz)  
**License**: MIT  
**Last updated**: October 2024
