
import SwiftUI

struct AppMainViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea()
            .statusBarHidden()
    }
}
