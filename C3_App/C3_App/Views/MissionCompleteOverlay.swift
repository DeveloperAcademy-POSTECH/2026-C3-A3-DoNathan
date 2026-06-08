//
//  MissionCompleteOverlay.swift
//  C3_App
//
//  Created by Noah on 6/8/26.
//

import SwiftUI

struct MissionCompleteOverlay: View {
    let isShowing: Bool
    let missionColor: Color
    var onTapFilter: (() -> Void)? = nil

    var body: some View {
        if isShowing {
            ZStack {
                // MARK: - 흰색 전체 배경
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // MARK: - 아이콘 + 텍스트
                    VStack(spacing: 4) {
                        Image(systemName: "medal.star.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 44)

                        Text("모든 미션 성공!\n필터를 바로 사용하러 가볼까요?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "3C3C3C"))
                            .lineSpacing(12)
                            .multilineTextAlignment(.center)
                            .frame(width: 300)
                    }

                    Spacer()

                    // MARK: - 하단 버튼
                    Button(action: { onTapFilter?() }) {
                        Text("필터 사용하러 가기")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 275, height: 48)
                            .background(missionColor)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 55)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: isShowing)
        }
    }
}

#Preview {
    MissionCompleteOverlay(isShowing: true, missionColor: Color(hex: "940017"))
}
