import Foundation
import CoreBluetooth

struct BluetoothDevice: Identifiable {
    let id = UUID()
    let identifier: UUID
    var name: String?
    var services: [BLEServiceInfo]

    init(identifier: UUID, name: String? = nil, services: [BLEServiceInfo]) {
        self.identifier = identifier
        self.name = name
        self.services = services
    }
}

struct BLEServiceInfo: Identifiable {
    var id = UUID()
    let uuid: CBUUID
    var characteristics: [BLECharacteristicInfo]

    init(uuid: CBUUID, characteristics: [BLECharacteristicInfo] = []) {
        self.uuid = uuid
        self.characteristics = characteristics
    }
}

struct BLECharacteristicInfo: Identifiable {
    var id = UUID()
    let uuid: CBUUID
    var value: String?
    let properties: [String]

    init(uuid: CBUUID, value: String?, properties: [String]) {
        self.uuid = uuid
        self.value = value
        self.properties = properties
    }
}
