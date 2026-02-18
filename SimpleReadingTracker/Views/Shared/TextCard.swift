import SwiftUI

struct TextCard<Content: View>: View {
    let height: CGFloat
    let accessibilityLabel: String
    @ViewBuilder let content: () -> Content

    init(
        height: CGFloat = 180,
        accessibilityLabel: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.height = height
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }

    var body: some View {
        content()
            .padding(12)
            .frame(width: 200, height: height, alignment: .topLeading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
    }
}
