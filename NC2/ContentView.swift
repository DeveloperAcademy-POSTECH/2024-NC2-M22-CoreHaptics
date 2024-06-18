//
//  ContentView.swift
//  NC2
//
//  Created by Jongmin on 6/17/24.
//
import SwiftUI

struct ContentView: View {
    @State private var isStarted = false
    @State private var elapsedTime = 0.0
    @State private var timer: Timer?
    @State var isShowingDevice = false
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        VStack {
            if isStarted {
                VStack {
                    Text(timeString(time: elapsedTime))
                        .font(.system(size: 74))
                        .fontWeight(.thin)
                        .foregroundColor(.white)
                        .padding(.top, 120)
                        .monospacedDigit()
                    Spacer()
                    Button(action: {
                        self.stopStopwatch()
                    }) {
                        Text("포기하기")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 76, height: 76)
                            .background(Color.orange)
                            .cornerRadius(38)
                            .padding(.bottom, 130)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Image("GradiBGG").ignoresSafeArea())

            } else {
                VStack {
                    HStack {
                        Text("진동을 따라 목표를 찾아보세요")
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                    Button(action: {
                        self.startStopwatch()
                    }) {
                        Text("시작하기")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 76, height: 76)
                            .background(Color.green)
                            .cornerRadius(38)
                    }
                    Button(action: {
                        self.isShowingDevice.toggle()
                    }) {
                        Text("기기 설정")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 16)
                            .padding(.bottom, 106)
                    }
                    .sheet(isPresented: $isShowingDevice) {
                        DeviceSelectView(bluetoothManager: bluetoothManager, isShowingDevice: $isShowingDevice)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Image("GradiBGOG").ignoresSafeArea())
            }
        }
        .onAppear{bluetoothManager.stopHapticFeedback()}
        .onChange(of: isStarted) { started in
            if started {
                bluetoothManager.startHapticFeedback()
            } else {
                bluetoothManager.stopHapticFeedback()
            }
        }
    }

    func startStopwatch() {
        self.isStarted = true
        self.elapsedTime = 0.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.elapsedTime += 1.0
        }
    }

    func stopStopwatch() {
        self.timer?.invalidate()
        self.timer = nil
        self.isStarted = false
    }

    func timeString(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
