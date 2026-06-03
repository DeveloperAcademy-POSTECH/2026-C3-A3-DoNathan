//
//  CropView.swift
//  TestCameraAndCrop
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI

struct CropView: View {
    @StateObject private var viewModel = CropViewModel()
    
    let capturedImage: UIImage
    var onConfirm: (UIImage) -> Void
    var onCancel: () -> Void
    
    // 드래그 상태
    @State private var dragOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showPreview: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // MARK: - 상단 바 (X 버튼)
                HStack {
                    Button(action: {
                        if showPreview {
                            showPreview = false
                        } else {
                            onCancel()
                        }
                    }) {
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
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.white)
                
                // MARK: - 이미지 + 크롭 오버레이
                ZStack {
                    // 미리보기 시 원본 숨김
                    if !showPreview {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        CropMaskView(
                            boxSize: viewModel.cropBoxSize,
                            offset: viewModel.cropOffset
                        )
                        .frame(
                            width: viewModel.actualImageSize.width,
                            height: viewModel.actualImageSize.height
                        )
                        
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(
                                width: viewModel.cropBoxSize.width,
                                height: viewModel.cropBoxSize.height
                            )
                            .offset(viewModel.cropOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newWidth = lastOffset.width + value.translation.width
                                        let newHeight = lastOffset.height + value.translation.height
                                        
                                        let imageAspect = capturedImage.size.width / capturedImage.size.height
                                        let actualImageWidth = min(geo.size.width, (geo.size.height - 88) * imageAspect)
                                        let actualImageHeight = actualImageWidth / imageAspect
                                        
                                        let maxX = (actualImageWidth - viewModel.cropBoxSize.width) / 2
                                        let maxY = (actualImageHeight - viewModel.cropBoxSize.height) / 2
                                        
                                        viewModel.cropOffset = CGSize(
                                            width: min(max(newWidth, -maxX), maxX),
                                            height: min(max(newHeight, -maxY), maxY)
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = viewModel.cropOffset
                                    }
                            )
                    } else {
                        // 크롭 미리보기
                        if let cropped = viewModel.croppedImage {
                            Image(uiImage: cropped)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .onAppear {
                    let imageAreaSize = CGSize(
                        width: geo.size.width,
                        height: geo.size.height - 88
                    )
                    viewModel.cropBoxSize = viewModel.calculateCropBoxSize(
                        image: capturedImage,
                        displaySize: imageAreaSize
                    )
                    viewModel.actualImageSize = viewModel.calcActualImageSize(
                        image: capturedImage,
                        displaySize: imageAreaSize
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray5))
                
                // MARK: - 하단 바 (파란 체크 버튼)
                HStack {
                    Spacer()
                    Button {
                        if showPreview {
                            if let cropped = viewModel.croppedImage {
                                onConfirm(cropped)
                            }
                        } else {
                            let displaySize = CGSize(
                                width: geo.size.width,
                                height: geo.size.height - 88
                            )
                            viewModel.cropImage(capturedImage, displaySize: displaySize) {
                                showPreview = true
                            }
                        }
                    } label: {
                        Circle()
                            .fill(Color(hex: "4BBCF0"))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.white)
            }
        }
    }
}

// MARK: - 크롭 마스크 (박스 외부 어둡게)
struct CropMaskView: View {
    let boxSize: CGSize
    let offset: CGSize
    
    var body: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2 + offset.width
            let centerY = geo.size.height / 2 + offset.height
            let boxRect = CGRect(
                x: centerX - boxSize.width / 2,
                y: centerY - boxSize.height / 2,
                width: boxSize.width,
                height: boxSize.height
            )
            
            // 전체를 어둡게 → 크롭 박스 영역만 투명하게 뚫기
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .mask(
                    Rectangle()
                        .overlay(
                            Rectangle()
                                .frame(width: boxSize.width, height: boxSize.height)
                                .offset(offset)
                                .blendMode(.destinationOut)
                        )
                        .compositingGroup()
                )
        }
        .ignoresSafeArea()
    }
}
#Preview {
    CropView(
        capturedImage: UIImage(systemName: "photo") ?? UIImage(),
        onConfirm: { _ in },
        onCancel: { }
    )
}
