//
//  MissionJudgeOverlay.swift
//  C3_App
//
//  Created by 최정원 on 5/31/26.
//

import SwiftUI

struct MissionJudgeOverlay: View {
    let isJudging: Bool

    var body: some View {
        if isJudging {
            ZStack {
                // 딤 처리
                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)

                    Text("일치율을\n확인하고 있어요")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
//               .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5, style: StrokeStyle(dash: [6, 4]))
//                        .background(Color.black.opacity(0.3).cornerRadius(12))
//                )
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: isJudging)
        }
    }
}


// MARK: - 판정 성공 화면 (fullScreenCover로 띄우는 것)
struct MissionSuccessView: View {
    let mainColor: Color
    let onDismiss: () -> Void  // 미션 페이지로 돌아가기

    var body: some View {
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










// MARK: - Extension
extension Shape {
    func stroke(_ content: Color, lineWidth: CGFloat, style: StrokeStyle) -> some View {
        self.stroke(content, style: style)
    }
}

#Preview {
    MissionJudgeOverlay(isJudging: true)
}
