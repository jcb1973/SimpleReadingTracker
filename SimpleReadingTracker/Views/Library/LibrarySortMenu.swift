import SwiftUI

struct LibrarySortMenu: View {
    @Binding var sortOption: SortOption
    @Binding var ascending: Bool

    var body: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    if sortOption == option {
                        ascending.toggle()
                    } else {
                        sortOption = option
                        ascending = false
                    }
                } label: {
                    HStack {
                        Text(option.displayName)
                        if sortOption == option {
                            Image(systemName: ascending ? "chevron.up" : "chevron.down")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }
}
