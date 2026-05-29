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
            
                
                // MARK: - 이미지 + 크롭 오버레이
                // ZStack 들어가기 전에 박스 크기 계산
                ZStack {
                    // ✅ 미리보기일 때는 원본 숨김
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
                        // ✅ 크롭 미리보기
                        if let cropped = viewModel.croppedImage {
                            Image(uiImage: cropped)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                // ✅ onAppear는 ZStack modifier로 이동 (조건과 무관하게 한 번만 실행)
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
                // MARK: - 하단 버튼
                HStack {
                    Button(action: {
                        if showPreview {
                            // 미리보기 → 다시 크롭으로
                            showPreview = false
                        } else {
                            onCancel()
                        }
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 44))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if showPreview {
                        // 편집완료 버튼
                        Button {
                            if let cropped = viewModel.croppedImage {
                                onConfirm(cropped)
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
                        
                    } else {
                        // 확인(체크) 버튼 → 크롭 실행 후 미리보기로
                        Button {
                            let displaySize = CGSize(
                                width: geo.size.width,
                                height: geo.size.height - 88   // ✅ 88로 통일 (기존 160 → 88)
                            )
                            viewModel.cropImage(capturedImage, displaySize: displaySize) {
                                showPreview = true
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 44))
                                .foregroundColor(.primary)
                        }
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
