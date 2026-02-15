import SwiftUI

struct LogoTitle: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 36)
                .accessibilityHidden(true)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
        }
    }
}
