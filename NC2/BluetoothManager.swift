//
//  BluetoothCentralManager.swift
//  NC2
//
//  Created by Jongmin on 6/17/24.
//

import Foundation
import CoreBluetooth
import CoreHaptics
import UIKit

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
    private var hapticEngine: CHHapticEngine?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        createHapticEngine()
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
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        peripheral.readRSSI()
    }

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
            print("Failed to read RSSI: \(error.localizedDescription)")
            return
        }
        
        let rssiValue = RSSI.doubleValue
        let distance = calculateDistance(rssi: rssiValue)
        DispatchQueue.main.async {
            self.distance = distance
            self.provideHapticFeedback(for: distance)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            peripheral.readRSSI()
        }
    }
    
    func calculateDistance(rssi: Double) -> Double {
        let txPower = -59
        if rssi == 0 {
            return -1.0
        }
        let ratio = rssi / Double(txPower)
        if ratio < 1.0 {
            return pow(ratio, 10.0)
        } else {
            let distance = (0.89976) * pow(ratio, 7.7095) + 0.111
            return distance
        }
    }
    
    private func createHapticEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch let error {
            print("Haptic engine Creation Error: \(error.localizedDescription)")
        }
    }
    
    func startHapticFeedback() {
        guard let hapticEngine = hapticEngine else { return }
        hapticEngine.start(completionHandler: nil)
    }
    
    func stopHapticFeedback() {
        guard let hapticEngine = hapticEngine else { return }
        hapticEngine.stop(completionHandler: nil)
    }

    private func provideHapticFeedback(for distance: Double) {
        guard let hapticEngine = hapticEngine else { return }
        
        let intensity: Float = max(0.1, min(1.0, Float(1.0 - ((distance - 1.0) / 4.0))))
        let sharpness: Float = intensity
        
        let hapticEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: 1.0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch let error {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}
