//
//  PhotoLibraryDeniedOverlay.swift
//  C3_App
//
//  Created by 이윤진 on 6/4/26.
//

import SwiftUI

struct PhotoLibraryDeniedOverlay: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 3) {
                    VStack(spacing: 8) {
                        Text("현재 사진 보관함 접근 권한이 없습니다.")
                            .font(.system(size: 18, weight: .semibold))
                        //                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                            .padding(.top, 5)
                        
                        Text("설정 > PALETO 탭에서 접근 권한을\n활성화할 수 있습니다.")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        //                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    
                    Button {
                        isShowing = false
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("설정으로 이동")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    
                    Button {
                        isShowing = false
                    } label: {
                        Text("취소")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.ultraThinMaterial)
                            .cornerRadius(25)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 21)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.white.opacity(0.3))
                        
                    )
                .padding(.horizontal, 40)
                    
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.45).ignoresSafeArea()
        PhotoLibraryDeniedOverlay(isShowing: .constant(true))
    }
}
