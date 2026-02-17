import SwiftUI

struct SearchMatchIndicator: View {
    let reasons: [MatchReason]

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ForEach(Array(reasons.enumerated()), id: \.offset) { _, reason in
                Text(reasonText(reason))
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.yellow.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }

    private func reasonText(_ reason: MatchReason) -> String {
        switch reason {
        case .title: "Title"
        case .author(let name): "Author: \(name)"
        case .tag(let name): "Tag: \(name)"
        case .note: "Notes"
        case .quote: "Quotes"
        }
    }
}
