import SwiftUI

struct BLEView<ViewModel: BLEViewModelType>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.foundDevices, id: \.id) { foundDevice in
                            DeviceItemView(
                                title: foundDevice.name ?? "No name"
                            ) {
                                viewModel.didTap(foundDevice.identifier)
                            }
                        }
                    }
                }
                .blur(radius: viewModel.isConnecting ? 3.0 : 0)
                .overlay(
                    Group {
                        if viewModel.isConnecting {
                            ConnectingView()
                        }
                    }
                )
            }

            Spacer()
            PrimaryButton(viewModel.primaryButtonText) {
                viewModel.didTapPrimaryButton()
            }
        }
        .padding(25)
        .sheet(item: $viewModel.connectedDevice, onDismiss: viewModel.didDismissDeviceDetails, content: { connectedDevice in
            DeviceInfoView(services: viewModel.connectedDevice?.services ?? [])
                .padding(8)
        })
    }
}

private struct ConnectingView: View {
    var body: some View {
        VStack(spacing: 15) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2.0)
                .padding()
            Text("Connecting...")
                .font(.title3)

        }
    }
}

struct DeviceInfoView: View {
    let services: [BLEServiceInfo]

    var body: some View {
        List(services) { serviceInfo in
            Section(header: Text("\(serviceInfo.uuid)").font(.headline).foregroundColor(.primary)) {
                ForEach(serviceInfo.characteristics) { characteristic in
                    CharacteristicInfoView(
                        uuid: "\(characteristic.uuid)",
                        value: characteristic.value,
                        properties: characteristic.properties
                    )
                    .listRowInsets(.none)
                    .listRowSeparator(.hidden)
                    .listRowSpacing(4)
                }
            }
        }
    }
}

struct CharacteristicInfoView: View {
    let uuid: String
    let value: String?
    let properties: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(uuid)
                .font(.headline)
            Text(value ?? "No value")
                .foregroundColor(.secondary)
            Text("Properties: \(properties.joined(separator: ", "))")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 3, x: 0, y: 2)
    }
}
