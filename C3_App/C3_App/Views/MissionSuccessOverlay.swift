//
//  MissionSuccessOverlay.swift
//  C3_App
//
//  Created by 이윤진 on 6/2/26.
//

import SwiftUI

struct MissionSuccessOverlay: View {
    let isShowing: Bool

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 36))
                        .foregroundColor(.white)

                    Text("색상과 이미지가\n일치합니다")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)

                
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: isShowing)
        }
    }
}

#Preview {
    MissionSuccessOverlay(isShowing: true)
}
