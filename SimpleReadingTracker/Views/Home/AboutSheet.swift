import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .accessibilityHidden(true)

                Text("Marginalia")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Book data provided by Open Library and Google Books.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)

                Link(destination: URL(string: "https://jcb1973.github.io/marginalia-support/")!) {
                    Label("Support", systemImage: "questionmark.circle")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationBackground(Color(.systemBackground))
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}
