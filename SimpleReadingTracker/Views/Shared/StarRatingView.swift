import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int?
    var maxRating = 5
    var isEditable = true

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= (rating ?? 0) ? "star.fill" : "star")
                    .foregroundStyle(star <= (rating ?? 0) ? .yellow : .gray.opacity(0.4))
                    .onTapGesture {
                        guard isEditable else { return }
                        if rating == star {
                            rating = nil
                        } else {
                            rating = star
                        }
                    }
            }
        }
        .imageScale(.large)
    }
}
