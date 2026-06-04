//
//  CameraDeniedOverlay.swift
//  C3_App
//
//  Created by 이윤진 on 6/4/26.
//

import SwiftUI

struct CameraDeniedOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6) //0.45 ?
                .ignoresSafeArea()
            
            // 안내 문구와 버튼
            VStack(spacing: 20) {
                Image(systemName: "camera.badge.ellipsis")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                Text("카메라 권한이 거부되었습니다")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("사진을 촬영하려면 설정에서\n카메라 접근 권한을 허용해주세요.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Button(action: openSettings) {
                    Text("설정으로 이동")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(30)
            .background(Color(uiColor: .darkGray).opacity(0.9))
            .cornerRadius(16)
            .padding(40)
        }
    }
    
    private func openSettings() {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
