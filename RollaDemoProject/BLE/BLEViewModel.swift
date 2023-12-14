import Foundation
import Combine

@MainActor
protocol BLEViewModelType: ObservableObject {
    var primaryButtonText: String { get }
    var foundDevices: [FoundDevice] { get }
    var isConnecting: Bool { get }
    func didTapPrimaryButton()
    func didTap(_ bluetoothDeviceIdentifier: UUID)
    func didDismissDeviceDetails()
    var connectedDevice: BluetoothDevice? { get set }
}

final class BLEViewModel: BLEViewModelType {
    private let bluetoothManager: BluetoothManager
    private var cancellables: Set<AnyCancellable> = []

    @Published var primaryButtonText = "Scan"
    @Published var foundDevices = [FoundDevice]()
    @Published var isConnecting = false
    @Published var connectedDevice: BluetoothDevice?

    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        setupBinding()
    }

    func setupBinding() {
        bluetoothManager.$peripherals
            .receive(on: DispatchQueue.main)
            .map { peripherals in
                peripherals.map { peripheral in
                    FoundDevice(
                        identifier: peripheral.identifier,
                        name: peripheral.name
                    )
                }
            }
            .sink { [weak self] foundDevices in
                self?.foundDevices = foundDevices
            }
            .store(in: &cancellables)

        bluetoothManager.$connectedDevice
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectedDevice, on: self)
            .store(in: &cancellables)
    }

    func didTapPrimaryButton() {
        bluetoothManager.scanForPeripherals()
    }

    func didTap(_ bluetoothDeviceIdentifier: UUID) {
        isConnecting = true
        bluetoothManager.stopScanning()
        bluetoothManager.connect(using: bluetoothDeviceIdentifier)
    }

    func didDismissDeviceDetails() {
        isConnecting = false
        bluetoothManager.disconnectFromPeripherals()
    }
}

struct FoundDevice: Identifiable {
    let id = UUID()
    let identifier: UUID
    let name: String?
}
