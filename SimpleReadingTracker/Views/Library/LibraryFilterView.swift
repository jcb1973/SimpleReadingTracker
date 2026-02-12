import SwiftUI

struct LibraryFilterView: View {
    @Binding var statusFilter: ReadingStatus?

    var body: some View {
        Menu {
            Button {
                statusFilter = nil
            } label: {
                HStack {
                    Text("All")
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
        } label: {
            Image(systemName: statusFilter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
    }
}
