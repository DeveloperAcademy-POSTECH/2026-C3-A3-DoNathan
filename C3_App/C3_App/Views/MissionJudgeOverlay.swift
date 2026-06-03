//
//  MissionJudgeOverlay.swift
//  C3_App
//
//  Created by 최정원 on 5/31/26.
//

import SwiftUI

struct MissionJudgeOverlay: View {
    let isShowing: Bool
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                    Text("일치율을\n확인하고 있어요")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: isShowing)
        }
    }
}

#Preview {
    MissionJudgeOverlay(isShowing: true)
}
