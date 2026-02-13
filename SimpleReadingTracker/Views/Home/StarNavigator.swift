import SwiftUI

struct StarNavigator: View {
    let ratingCounts: [Int: Int]
    let onRatingTapped: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                let count = ratingCounts[star] ?? 0
                Button {
                    onRatingTapped(star)
                } label: {
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(count > 0 ? .yellow : .gray.opacity(0.3))

                            Text("\(star)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }

                        Text("\(count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        count > 0
                            ? Color.yellow.opacity(0.15)
                            : Color(red: 0.953, green: 0.957, blue: 0.965)
                    )
                    .clipShape(Capsule())
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
