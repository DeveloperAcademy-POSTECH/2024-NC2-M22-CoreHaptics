//
//  DeviceSelect.swift
//  NC2
//
//  Created by 변준섭 on 6/18/24.
//
import SwiftUI
import CoreBluetooth

struct DeviceSelectView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var isShowingDevice: Bool
    @State private var selectedPeripheral: CBPeripheral? // 선택한 기기를 저장할 상태 변수
    @State private var showConfirmationAlert = false // 확인 알림을 표시할 상태 변수

    var body: some View {
        VStack {
            List(bluetoothManager.peripherals.sorted {
                ($0.name ?? "Unknown") != "Unknown" && ($1.name ?? "Unknown") == "Unknown"
            }, id: \.identifier) { peripheral in
                Button(action: {
                    selectedPeripheral = peripheral
                    showConfirmationAlert = true
                }) {
                    Text(peripheral.name ?? "Unknown")
                }
            }
        }
        .onAppear {
            bluetoothManager.centralManagerDidUpdateState(bluetoothManager.centralManager)
        }
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("연결 확인"),
                message: Text("\(selectedPeripheral?.name ?? "Unknown") 기기에 연결하시겠습니까?"),
                primaryButton: .default(Text("예"), action: {
                    if let peripheral = selectedPeripheral {
                        bluetoothManager.connectToPeripheral(peripheral)
                        isShowingDevice.toggle()
                    }
                }),
                secondaryButton: .cancel(Text("아니오"))
            )
        }
    }
}
