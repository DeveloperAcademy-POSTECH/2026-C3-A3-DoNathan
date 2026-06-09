//
//  MissionSuccessView.swift
//  C3_App
//
//  Created by 이윤진 on 6/2/26.
//

import SwiftUI

struct MissionSuccessView: View {
    let mainColor: Color
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(mainColor)
                
                Text("해당 미션을\n성공했어요!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("미션 페이지로 돌아가기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(mainColor)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    MissionSuccessView(mainColor: .blue) {
        print("미션 페이지로 이동")
    }
}
