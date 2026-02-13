import SwiftUI

struct StarNavigator: View {
    let ratingCounts: [Int: Int]
    let onRatingTapped: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                let count = ratingCounts[star] ?? 0
                let isActive = count > 0
                Button {
                    onRatingTapped(star)
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(isActive ? .yellow : .gray.opacity(0.3))

                        Text("\(star)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .frame(width: 54, height: 54)
                    .background(
                        isActive
                            ? Color.yellow.opacity(0.15)
                            : Color(red: 0.953, green: 0.957, blue: 0.965)
                    )
                    .clipShape(Circle())
                    .overlay {
                        if isActive {
                            Circle()
                                .strokeBorder(Color(red: 0.918, green: 0.702, blue: 0.031), lineWidth: 1)
                        }
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
