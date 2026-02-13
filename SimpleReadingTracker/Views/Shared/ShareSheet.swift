import SwiftUI

struct ShareSheet: ViewModifier {
    @Binding var isPresented: Bool
    let activityItems: [Any]

    func body(content: Content) -> some View {
        content
            .background {
                ShareSheetPresenter(isPresented: $isPresented, activityItems: activityItems)
                    .frame(width: 0, height: 0)
            }
    }
}

private struct ShareSheetPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        if isPresented, controller.presentedViewController == nil {
            let activityVC = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                isPresented = false
            }
            controller.present(activityVC, animated: true)
        }
    }
}

extension View {
    func shareSheet(isPresented: Binding<Bool>, activityItems: [Any]) -> some View {
        modifier(ShareSheet(isPresented: isPresented, activityItems: activityItems))
    }
}
