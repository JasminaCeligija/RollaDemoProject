import SwiftUI

struct DeviceItemView: View {
    let title: String
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .shadow(radius: 3, x: 0, y: 2)
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    DeviceItemView(title: "Device name") {}
}
