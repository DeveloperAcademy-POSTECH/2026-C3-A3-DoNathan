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
    var onClose: (() -> Void)? = nil

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

                // MARK: - 좌측 상단 X 버튼 (카메라 상단 바와 동일한 글래스 스타일)
                VStack {
                    HStack {
                        Button(action: { onClose?() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: 40, height: 40)
                        }
                        .glassEffect(.regular.interactive(), in: Circle())

                        Spacer()
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: isShowing)
        }
    }
}

#Preview {
    MissionCompleteOverlay(isShowing: true, missionColor: Color(hex: "940017"))
}
