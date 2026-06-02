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

    var body: some View {
        VStack(spacing: 0) {
            // 사진 미리보기
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

            // 채도 슬라이더
            HStack(spacing: 12) {
                Image(systemName: "camera.filters")
                    .foregroundStyle(.gray)

                Slider(value: $viewModel.saturation, in: 0.0...2.0) { isEditing in
                    if isEditing { viewModel.applyPreviewFilter() }
                    else { viewModel.applyHighResFilter() }
                }
                .tint(.gray)

                Image("camera.filters.fill") // 에셋이면 이름 바꾸는 것 권장: ic_filters_fill
                    .resizable()
                    .scaledToFit()
//                    .renderingMode(.template)
//                    .foregroundStyle(.gray)
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            
            Spacer().frame(height: 88) // ✅ 원하는 만큼

            // 하단 버튼 영역(높이 확보)
            HStack {
                Spacer()

                Button {
                    let imageToSend = viewModel.finalImage ?? viewModel.previewImage
                    if let image = imageToSend {
                        onConfirm(image, viewModel.saturation)
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
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 44)   // ✅ 이 값 키우면 슬라이더가 더 위로
            .background(Color.white)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                        .shadow(radius: 6, y: 3)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Color.white)
        }
        .onAppear { viewModel.setImage(capturedImage) }
    }
}
