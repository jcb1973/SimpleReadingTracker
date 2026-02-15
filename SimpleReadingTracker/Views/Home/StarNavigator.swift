//import SwiftUI
//
//struct StarNavigator: View {
//    let ratingCounts: [Int: Int]
//    let onRatingTapped: (Int) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Filter by rating")
//                .font(.subheadline)
//
//            HStack(spacing: 6) {
//                ForEach(1...5, id: \.self) { star in
//                    let count = ratingCounts[star] ?? 0
//                    let isActive = true
//                    Button {
//                        onRatingTapped(star)
//                    } label: {
//                        HStack(spacing: 3) {
//                            Image(systemName: "star.fill")
//                                .font(.system(size: 12))
//                                .foregroundStyle(isActive ? .yellow : .gray.opacity(0.3))
//
//                            Text("\(star)")
//                                .font(.subheadline)
//                                .fontWeight(.bold)
//                        }
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                        .frame(maxWidth: .infinity)
//                        .background(
//                            isActive
//                                ? Color.yellow.opacity(0.15)
//                                : Color(red: 0.953, green: 0.957, blue: 0.965)
//                        )
//                        .clipShape(Capsule())
//                        .overlay {
//                            if isActive {
//                                Capsule()
//                                    .strokeBorder(Color(red: 0.918, green: 0.702, blue: 0.031), lineWidth: 1)
//                            }
//                        }
//                        .contentShape(Capsule())
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
