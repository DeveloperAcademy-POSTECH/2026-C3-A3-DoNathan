//
//  SaturationView.swift
//  TestCamera
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI
import UIKit

struct SaturationView: View {
    @StateObject private var viewModel = SaturationViewModel()

    let capturedImage: UIImage
    var onConfirm: (UIImage, Float) -> Void
    var onCancel: () -> Void
    
    // ✅ 판정 상태
    @State private var isJudging: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showFail: Bool = false

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                // 사진 미리보기
                ZStack {
                    Color(.systemGray5)
                    
                    if let image = viewModel.previewImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 채도 슬라이더
                HStack(spacing: 12) {
                    Image(systemName: "camera.filters")
                        .foregroundStyle(.gray)
                    
                    Slider(value: $viewModel.saturation, in: 0.0...2.0) { isEditing in
                        if isEditing { viewModel.applyPreviewFilter() }
                        else { viewModel.applyHighResFilter() }
                    }
                    .tint(.gray)
                    
                    Image("camera.filters.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                
                //Spacer().frame(height: 88)
                
                // 하단 버튼 영역(높이 확보)
                HStack {
                    Spacer()
                    
                    Button {
                        let imageToSend = viewModel.finalImage ?? viewModel.previewImage
                        //                    if let image = imageToSend {
                        //                        onConfirm(image, viewModel.saturation)
                        //                    }
                        if let image = imageToSend {
                            startJudging(image: image)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Text("편집완료")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "checkmark")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .padding(.vertical, 6)
                        
                    }
                    .buttonStyle(GlassButtonStyle())
                    .disabled(isJudging || showSuccess || showFail)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 44)
                .background(Color.white)
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.gray)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(GlassButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(Color.white)
            }
            .onAppear { viewModel.setImage(capturedImage) }
            
            // ✅ 판정 중 오버레이
            if isJudging {
                Color.black.opacity(0.45).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView().tint(.white).scaleEffect(1.3)
                    Text("판정 중...")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // ✅ 성공 오버레이
            MissionSuccessOverlay(isShowing: showSuccess)
            
            // ✅ 실패 오버레이
            MissionFailOverlay(isShowing: showFail)
        }
    }
    
    private func startJudging(image: UIImage) {
            isJudging = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isJudging = false
                
                let isPassed = Bool.random() // ✅ 나중에 MissionEvaluator로 교체
                
                withAnimation {
                    if isPassed { showSuccess = true }
                    else { showFail = true }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if isPassed {
                        onConfirm(image, viewModel.saturation)
                    } else {
                        withAnimation { showFail = false }  // 실패 시 오버레이 닫고 재도전
                    }
                }
            }
        }
}

#Preview {
    // SF Symbols의 카메라 아이콘을 기반으로 임시 UIImage 생성
    let config = UIImage.SymbolConfiguration(pointSize: 300, weight: .ultraLight)
    let systemImage = UIImage(systemName: "camera.shutter.button", withConfiguration: config)
    let fallbackImage = systemImage ?? UIImage()
    
    return SaturationView(
        capturedImage: fallbackImage,
        onConfirm: { filteredImage, saturationValue in
            print("📸 [Preview] 편집 완료 - 채도 수치: \(saturationValue)")
        },
        onCancel: {
            print("❌ [Preview] 취소 버튼 탭")
        }
    )
}
