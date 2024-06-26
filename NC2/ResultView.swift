////
////  ResultView.swift
////  NC2
////
////  Created by Jongmin on 6/18/24.
////

import SwiftUI
import Lottie

struct ResultView: View {
    @Binding var isShownFullScreenCover : Bool
    @Binding var successTime : String
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            LottieView(animationFileName: "ResultEffect", loopMode: .loop) // Lottie 애니메이션 추가
                .frame(width: 200, height: 200) // 원하는 크기로 조절
                .padding(.bottom, 365)
                .onAppear{
                    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                        bluetoothManager.celebrationHapticFeedback()
                    }
                }
                .onDisappear{
                    timer?.invalidate()
                }
            VStack {
                VStack {
                    Text("축하합니다!")
                        .font(.system(size: 48))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.orange)
                        .padding(.top, 170)
                }
                VStack {
                    Text(successTime)
                        .font(.system(size: 74))
                        .fontWeight(.thin)
                        .foregroundColor(.black)
                        .padding(.top, 120)
                        .monospacedDigit()
                    Text("달성 시간")
                        .font(.system(size: 26))
                        .fontWeight(.regular)
                        .foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Button(action: {
                        isShownFullScreenCover = false
                    }, label: {
                        Text("처음으로")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 44)
                            .background(Color.orange)
                            .cornerRadius(12)
                            .padding()
                    })
                }
            }
        }
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
