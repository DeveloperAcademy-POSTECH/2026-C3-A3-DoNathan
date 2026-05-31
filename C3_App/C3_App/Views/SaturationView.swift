//
//  SaturationView.swift
//  TestCamera
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI

struct SaturationView: View {
    @StateObject private var viewModel = SaturationViewModel()
    @State private var isJudging: Bool = false

    let capturedImage: UIImage
    var onConfirm: (UIImage, Float) -> Void  // 이미지 + 채도값 함께 전달
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // MARK: - 사진 미리보기
                ZStack {
                    Color(.systemGray5)
                    
                    if let image = viewModel.previewImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - 채도 슬라이더
                HStack(spacing: 12) {
                    Image(systemName: "camera.filters")
                        .foregroundColor(.gray)
                    
                    Slider(value: $viewModel.saturation, in: 0.0...2.0) { isEditing in
                        if isEditing {
                            // 드래그 중: 저해상도 빠른 렌더링
                            viewModel.applyPreviewFilter()
                        } else {
                            // 드래그 종료: 원본 해상도 고품질 렌더링
                            viewModel.applyHighResFilter()
                        }
                    }
                    .tint(.gray)
                    
                    Image(systemName: "camera.filters.fill")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray5))
                
                // MARK: - 하단 버튼
                HStack {
                    // 취소
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 44))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // 편집완료
                    Button {
                        // finalImage 없으면 previewImage라도 전달
                        let imageToSend = viewModel.finalImage ?? viewModel.previewImage
                        if let image = imageToSend {
                            isJudging = true
                            //onConfirm(image, viewModel.saturation)
                            judgeAndConfirm(image: image)
                        }
                    } label: {
                        HStack {
                            Text("편집완료")
                            Image(systemName: "checkmark")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .overlay(Capsule().stroke(Color.primary, lineWidth: 1.5))
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.white)
            }
            .onAppear {
                viewModel.setImage(capturedImage)
            }
            
            MissionJudgeOverlay(isJudging: isJudging)
        }
    }
    
    private func judgeAndConfirm(image: UIImage) {
            // 판정 로직 (예: 1.5초 후 완료)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isJudging = false
                onConfirm(image, viewModel.saturation)
            }
        }
}
