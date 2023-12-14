import SwiftUI

struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .multilineTextAlignment(.center)
    }
}

extension View {
    func customTitleStyle() -> some View {
        self.modifier(TitleModifier())
    }
}
