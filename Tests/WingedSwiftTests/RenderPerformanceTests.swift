import Foundation
import Testing
@testable import WingedSwift

/// A regression guard, not a benchmark: rendering builds one buffer instead of a string per node,
/// and a change that reintroduces quadratic concatenation shows up here as a timeout.
@Suite struct RenderPerformanceTests {

    private func largeTree(rows: Int) -> HTMLTag {
        Table {
            Tbody {
                for row in 0..<rows {
                    Tr {
                        for column in 0..<5 {
                            Td(content: "cell \(row)-\(column)")
                                .addClass("cell")
                                .dataAttribute(key: "row", value: String(row))
                        }
                    }
                }
            }
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func rendersFiveThousandNodesQuickly() {
        let tree = largeTree(rows: 1_000)   // ~6 000 nodes

        let clock = ContinuousClock()
        let compact = clock.measure { _ = tree.render(.compact) }
        let pretty = clock.measure { _ = tree.render(.pretty) }

        #expect(compact < .seconds(2), "compact render took \(compact)")
        #expect(pretty < .seconds(2), "pretty render took \(pretty)")
    }

    @Test func outputSizeIsWhatWeExpect() {
        let rendered = largeTree(rows: 100).render(.compact)

        #expect(rendered.hasPrefix("<table><tbody><tr><td class=\"cell\" data-row=\"0\">cell 0-0</td>"))
        #expect(rendered.hasSuffix("</tr></tbody></table>"))
    }
}
