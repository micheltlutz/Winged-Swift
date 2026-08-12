import WingedSwift

/// The shell every page shares: head, navigation and footer.
///
/// `page(...)` returns a `Document`, so the doctype and the `lang` attribute are handled for you.
struct SiteLayout {
    let siteName: String
    let description: String

    func page(
        title: String,
        currentPage: String = "",
        @HTMLFragmentBuilder content: () -> [HTMLTag]
    ) -> Document {
        Document(lang: "en") {
            Meta(charset: "UTF-8")
            Meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
            Meta(name: "description", content: description)
            Title(content: "\(title) - \(siteName)")
            Link(href: "/css/style.css", rel: "stylesheet")
        } body: {
            Header {
                Nav {
                    Div {
                        A(href: "/", content: siteName).addClass("logo")
                    }
                    Ul {
                        navigationLink(to: "/", label: "Home", isCurrent: currentPage == "home")
                        navigationLink(to: "/about.html", label: "About", isCurrent: currentPage == "about")
                    }
                    .addClass("nav-links")
                }
                .addClass("navbar")
            }
            .addClass("site-header")

            MainTag(children: content()).addClass("container")

            Footer {
                Div {
                    P(content: "© 2026 \(siteName). Built with WingedSwift 🚀")
                    P {
                        A(href: "https://github.com/micheltlutz/Winged-Swift", content: "WingedSwift on GitHub")
                    }
                }
                .addClass("footer-content")
            }
            .addClass("site-footer")
        }
    }

    private func navigationLink(to href: String, label: String, isCurrent: Bool) -> HTMLTag {
        Li {
            A(href: href, content: label)
                .addClass(isCurrent ? "active" : "")
        }
    }
}
