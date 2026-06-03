//
//  MissionFailOverlay.swift
//  C3_App
//
//  Created by 이윤진 on 6/3/26.
//

//
//  MissionSuccessOverlay.swift
//  C3_App
//
//  Created by 이윤진 on 6/2/26.
//

import SwiftUI

struct MissionFailOverlay: View {
    let isShowing: Bool

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundColor(.white)

                    Text("일치하지 않아요\n다시 시도해보세요")
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
    MissionFailOverlay(isShowing: true)
}
