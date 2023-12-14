import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(.bordered)
        .tint(.blue)
        .controlSize(.large)
    }
}
