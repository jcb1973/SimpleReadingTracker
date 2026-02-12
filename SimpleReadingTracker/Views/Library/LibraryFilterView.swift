import SwiftUI

struct LibraryFilterView: View {
    @Binding var statusFilter: ReadingStatus?
    @Binding var ratingFilter: Int?

    private var hasActiveFilter: Bool {
        statusFilter != nil || ratingFilter != nil
    }

    var body: some View {
        Menu {
            Section("Status") {
                Button {
                    statusFilter = nil
                } label: {
                    HStack {
                        Text("All Statuses")
                        if statusFilter == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach(ReadingStatus.allCases) { status in
                    Button {
                        statusFilter = status
                    } label: {
                        HStack {
                            Label(status.displayName, systemImage: status.systemImage)
                            if statusFilter == status {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section("Rating") {
                Button {
                    ratingFilter = nil
                } label: {
                    HStack {
                        Text("All Ratings")
                        if ratingFilter == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach(1...5, id: \.self) { stars in
                    Button {
                        ratingFilter = stars
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
        } label: {
            Image(systemName: hasActiveFilter
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
    }
}
