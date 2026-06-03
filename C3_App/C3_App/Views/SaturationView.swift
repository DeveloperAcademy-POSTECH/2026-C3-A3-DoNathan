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
                if let image = viewModel.previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray5))

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

            Spacer().frame(height: 88)

            // 하단 버튼 영역(높이 확보)
            HStack {
                Spacer()

                Button {
                    let imageToSend = viewModel.finalImage ?? viewModel.previewImage
                    if let image = imageToSend {
                        onConfirm(image, viewModel.saturation)
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text("편집완료")
                            .font(.system(size: 19, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(hex: "0076FF").opacity(0.65), in: Capsule())
                }
                .glassEffect(.regular, in: Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
            .background(Color.white)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: onCancel) {
                    ZStack {
                        Circle()
                            .fill(.clear)
                        Image(systemName: "xmark")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(Color(hex: "888888"))
                    }
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
                }
                .glassEffect(.regular, in: Circle())

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 28)
            .padding(.bottom, 20)
            .background(Color.white)
        }
        .onAppear { viewModel.setImage(capturedImage) }
    }
}
#Preview {
    SaturationView(
        capturedImage: UIImage(systemName: "photo") ?? UIImage(),
        onConfirm: { _, _ in },
        onCancel: {}
    )
}
