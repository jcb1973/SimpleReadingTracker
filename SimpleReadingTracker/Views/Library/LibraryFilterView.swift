import SwiftUI

struct LibraryFilterView: View {
    @Binding var statusFilter: ReadingStatus?
    @Binding var ratingFilter: Int?
    var onExport: (() -> Void)?

    private var hasActiveFilter: Bool {
        statusFilter != nil || ratingFilter != nil
    }

    var body: some View {
        Menu {
            Section("Status") {
                ForEach(ReadingStatus.allCases) { status in
                    Button {
                        statusFilter = statusFilter == status ? nil : status
                    } label: {
                        HStack {
                            Text(status.displayName)
                            if statusFilter == status {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section("Rating") {
                ForEach(1...5, id: \.self) { stars in
                    Button {
                        ratingFilter = ratingFilter == stars ? nil : stars
                    } label: {
                        HStack {
                            Text(String(repeating: "\u{2605}", count: stars))
                            if ratingFilter == stars {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section {
                Button {
                    onExport?()
                } label: {
                    Label("Export (CSV)", systemImage: "square.and.arrow.up")
                }
            }
        } label: {
            Image(systemName: hasActiveFilter
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
    }
}
