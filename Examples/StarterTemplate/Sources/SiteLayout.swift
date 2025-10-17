import WingedSwift

class SiteLayout: Layout {
    let siteName: String
    let description: String
    
    init(siteName: String, description: String) {
        self.siteName = siteName
        self.description = description
    }
    
    func render(title: String, currentPage: String = "", content: HTMLTag) -> HTMLTag {
        return html {
            Head(children: [
                Meta(charset: "UTF-8"),
                Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
                Meta(name: "description", content: description),
                Title(content: "\(title) - \(siteName)"),
                Link(href: "css/style.css", rel: "stylesheet"),
                // Adicione favicon se quiser
                // Link(rel: "icon", type: "image/png", href: "favicon.png")
            ])
            
            Body(children: [
                // Header com navegação
                Header(children: [
                    Nav(children: [
                        Div(children: [
                            A(href: "index.html", content: siteName)
                                .addClass("logo")
                        ]),
                        Ul(children: [
                            Li(children: [
                                A(href: "index.html", content: "Home")
                                    .addClass(currentPage == "home" ? "active" : "")
                            ]),
                            Li(children: [
                                A(href: "about.html", content: "Sobre")
                                    .addClass(currentPage == "about" ? "active" : "")
                            ])
                        ])
                        .addClass("nav-links")
                    ])
                    .addClass("navbar")
                ])
                .addClass("site-header"),
                
                // Conteúdo principal
                content,
                
                // Footer
                Footer(children: [
                    P(children: [
                        HTMLTag("span", content: "Criado com ", escapeContent: false),
                        A(href: "https://github.com/micheltlutz/Winged-Swift", 
                          content: "WingedSwift"),
                        HTMLTag("span", content: " 🚀", escapeContent: false)
                    ])
                ])
                .addClass("site-footer")
            ])
        }
    }
    
    // Implementação do protocolo Layout
    func render(content: HTMLTag) -> HTMLTag {
        return render(title: siteName, content: content)
    }
}

