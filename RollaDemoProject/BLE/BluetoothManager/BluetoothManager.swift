import Foundation
import CoreBluetooth

enum BluetoothAuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case allowedAlways
    case allowedWhenInUse
}

class BluetoothManager: NSObject, ObservableObject {
    private let centralManager: CBCentralManager!
    @Published var peripherals = [CBPeripheral]()
    @Published var services = [BLEServiceInfo]()
    @Published var connectedDevice: BluetoothDevice?
    @Published var authorizationStatus: BluetoothAuthorizationStatus = .notDetermined

    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        centralManager.delegate = self
    }

    func scanForPeripherals() {
        peripherals = []
        services = []
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    func disconnectFromPeripherals() {
        for peripheral in peripherals {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    func connect(using peripheralIdentifier: UUID) {
        if let peripheral = peripherals.first(where: { $0.identifier == peripheralIdentifier}) {
            centralManager.connect(peripheral, options: nil)
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown, .resetting:
            authorizationStatus = .notDetermined
        case .unsupported, .poweredOff:
            authorizationStatus = .denied
        case .unauthorized:
            authorizationStatus = .restricted
        case .poweredOn:
            authorizationStatus = .allowedAlways
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = BluetoothDevice(identifier: peripheral.identifier, services: [])
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(where: { $0.identifier == peripheral.identifier}) {
            peripherals.append(peripheral)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            //Handle error
            return
        }

        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            return
        }

        let serviceInfo = BLEServiceInfo(
            uuid: service.uuid,
            characteristics: characteristics.map { characteristic in
                let characteristicInfo = BLECharacteristicInfo(
                    uuid: characteristic.uuid,
                    value: encodedString(uuid: characteristic.uuid, data: characteristic.value),
                    properties: characteristic.properties.stringRepresentation
                )
                return characteristicInfo
            }
        )
        connectedDevice?.services.append(serviceInfo)

        characteristics.forEach { characteristic in
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            return
        }

        guard var connectedDevice else {
            self.connectedDevice = BluetoothDevice(identifier: peripheral.identifier, services: [])
            return
        }

        let updatedServices = connectedDevice.services.map { service in
            guard let characteristicIndex = service.characteristics.firstIndex(where: { $0.uuid == characteristic.uuid }) else {
                return service
            }

            let updatedCharacteristics = service.characteristics.enumerated().map { (index, oldCharacteristic) -> BLECharacteristicInfo in
                if index == characteristicIndex {
                    return BLECharacteristicInfo(
                        uuid: oldCharacteristic.uuid,
                        value: encodedString(uuid: oldCharacteristic.uuid, data: data),
                        properties: oldCharacteristic.properties
                    )
                } else {
                    return oldCharacteristic
                }
            }

            return BLEServiceInfo(uuid: service.uuid, characteristics: updatedCharacteristics)
        }
        connectedDevice.services = updatedServices
    }
}

private extension BluetoothManager {
    func encodedString(uuid: CBUUID, data: Data?) -> String {
        guard let data = data else {
            return "No value"
        }

        if uuid == CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB") {
            let batteryLevel = Int(data[0])
            return "\(batteryLevel)%"
        } else if let stringValue = String(data: data, encoding: .utf8), !stringValue.allSatisfy({ $0 == "\0" }) {
            return stringValue
        } else {
            let hexString = data.map { String(format: "%02X", $0) }.joined()
            return "0x\(hexString.suffix(8))"
        }
    }
}

private extension CBCharacteristicProperties {
    var stringRepresentation: [String] {
        let propertyMappings: [(CBCharacteristicProperties, String)] = [
            (.broadcast, "Broadcast"),
            (.read, "Read"),
            (.writeWithoutResponse, "WriteWithoutResponse"),
            (.write, "Write"),
            (.notify, "Notify"),
            (.indicate, "Indicate"),
            (.authenticatedSignedWrites, "AuthenticatedSignedWrites"),
            (.extendedProperties, "ExtendedProperties"),
            (.notifyEncryptionRequired, "NotifyEncryptionRequired"),
            (.indicateEncryptionRequired, "IndicateEncryptionRequired")
        ]
        return propertyMappings.compactMap { contains($0.0) ? $0.1 : nil }
    }
}
