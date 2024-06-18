////
////  ResultView.swift
////  NC2
////
////  Created by Jongmin on 6/18/24.
////

import SwiftUI

struct ResultView: View {
    var body: some View {
        VStack {
            VStack {
                Text("축하합니다!")
                    .font(.system(size: 48))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.orange)
                    .padding(.top, 154-16)
            }
            VStack {
                Text("00:00")
                    .font(.system(size: 74))
                    .fontWeight(.thin)
                    .foregroundColor(.black)
                    .padding(.top, 120)
                    .monospacedDigit()
                Text("달성 시간")
                    .font(.system(size: 26))
                    .fontWeight(.regular)
            }
        Spacer()
            VStack {
                Button(action: {
                    
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

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
