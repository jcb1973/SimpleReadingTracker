import SwiftUI

struct TagColorPicker: View {
    let selectedColor: TagColor?
    let onSelect: (TagColor?) -> Void

    private let circleSize: CGFloat = 30

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                defaultCircle
                ForEach(TagColor.allCases, id: \.self) { tagColor in
                    colorCircle(tagColor)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var defaultCircle: some View {
        Button {
            onSelect(nil)
        } label: {
            Circle()
                .fill(Color.accentColor)
                .frame(width: circleSize, height: circleSize)
                .overlay {
                    if selectedColor == nil {
                        Circle()
                            .strokeBorder(.primary, lineWidth: 2.5)
                            .frame(width: circleSize + 6, height: circleSize + 6)
                    }
                }
                .overlay {
                    Text("A")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Default color")
    }

    private func colorCircle(_ tagColor: TagColor) -> some View {
        Button {
            onSelect(tagColor)
        } label: {
            Circle()
                .fill(tagColor.color)
                .frame(width: circleSize, height: circleSize)
                .overlay {
                    if selectedColor == tagColor {
                        Circle()
                            .strokeBorder(.primary, lineWidth: 2.5)
                            .frame(width: circleSize + 6, height: circleSize + 6)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tagColor.rawValue)
    }
}
