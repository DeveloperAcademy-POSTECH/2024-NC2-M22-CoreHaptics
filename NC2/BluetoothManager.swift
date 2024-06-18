//
//  BluetoothCentralManager.swift
//  NC2
//
//  Created by Jongmin on 6/17/24.
//

import CoreBluetooth
import SwiftUI

// Identifiable 확장 추가
extension CBPeripheral: Identifiable {
    public var id: UUID {
        return identifier
    }
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var peripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var distance: Double?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self  // Delegate 설정
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self  // Delegate 설정
        peripheral.discoverServices(nil)
        peripheral.readRSSI()  // 연결 후 RSSI 읽기 시작
    }

    // CBPeripheralDelegate 메서드 구현
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic)")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        
        let rssiValue = RSSI.doubleValue
        distance = calculateDistance(rssi: rssiValue)
        
        // 주기적으로 RSSI 읽기
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            peripheral.readRSSI()
        }
    }
    
    func calculateDistance(rssi: Double) -> Double {
        let txPower = -59 // 기본 Tx 파워 값, 필요에 따라 조정
        if rssi == 0 {
            return -1.0 // 측정 불가
        }
        let ratio = rssi / Double(txPower)
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            let distance = (0.89976) * pow(ratio, 7.7095) + 0.111
            return distance
        }
    }
}
