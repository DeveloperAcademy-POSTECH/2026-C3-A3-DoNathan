//
//  ColorPickerView.swift
//  C3_App
//
//  Created by 최정원 on 5/29/26.
//

import SwiftUI
import CoreImage
import Combine

struct ColorPickerView: View {
    @StateObject private var viewModel = ColorPickerViewModel()
    @StateObject private var judgeVM = JudgeViewModel()
    
    let capturedImage: UIImage
    let missionColor: Color
    var onConfirm: (UIColor) -> Void
    var onCancel: () -> Void
    
    @State private var imageFrame: CGRect = .zero
    @State private var showResult: Bool = false
    @State private var isPickerActive: Bool = false
    @State private var pickerPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // MARK: - 이미지 + 피커
                ZStack {
                    // 원본 이미지
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            GeometryReader { imageGeo in
                                Color.clear.onAppear {
                                    // 이미지 실제 표시 frame 저장
                                    //                                    imageFrame = imageGeo.frame(in: .local)
                                    //                                    // 피커 초기 위치를 이미지 중앙으로
                                    imageFrame = imageGeo.frame(in: .named("imageArea"))
                                    pickerPosition = CGPoint(
                                        x: imageFrame.midX,   // 이미지 실제 중앙으로
                                        y: imageFrame.midY
                                    )
                                }
                            }
                        )
                    
                    CenterColorCell(color: missionColor, height: 145)
                        .frame(width: 112)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(.top, 40)
                        .padding(.trailing, 36)
                        .allowsHitTesting(false)
                    
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "777777"))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(GlassButtonStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    
                    // 피커 아이콘 (비활성 상태일 때만 표시)
                    if !isPickerActive {
                        Button {
                            isPickerActive = true
                            showResult = false
                        } label: {
                            Image(systemName: "eyedropper")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "777777"))
                                .frame(width: 48, height: 48)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(16)
                        .buttonStyle(GlassButtonStyle())
                    }
                    
                    // 피커 활성화 상태일 때 루페 표시 + 드래그
                    if isPickerActive {
                        PickerLoupe(color: viewModel.selectedColor)
                            .position(pickerPosition)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // 이미지 영역 내로 이동 제한
                                        let clampedX = min(max(value.location.x, imageFrame.minX), imageFrame.maxX)
                                        let clampedY = min(max(value.location.y, imageFrame.minY), imageFrame.maxY)
                                        pickerPosition = CGPoint(x: clampedX, y: clampedY)
                                        
                                        viewModel.pickColor(
                                            from: capturedImage.fixedOrientation(),
                                            at: pickerPosition,
                                            imageFrame: imageFrame
                                        )
                                    }
                                    .onEnded { _ in
                                        showResult = true
                                    }
                            )
                    }
                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(width: geo.size.width, height: geo.size.height * 0.76)
                .background(Color(.systemGray6))
                
                // MARK: - 결과 패널
                if showResult {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.selectedColor)
                            .frame(width: 56, height: 56)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("현재 선택한 색상")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("컬러가 만족스럽다면 편집완료! 또는\n컬러 피커를 통해 재도전이 가능해요!")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 재도전 버튼
                        Image(systemName: "eyedropper")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .onTapGesture {
                                showResult = false
                                // 피커는 유지, 다시 드래그 가능
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                }
                
                // MARK: - 하단 버튼
                HStack {
                    Spacer()
                    
                    Button {
                        judgeVM.start(
                            image: capturedImage,
                            type: .colorPicker,
                            targetColor: missionColor,
                            onPassed: { onConfirm(viewModel.selectedUIColor) },  // 선택된 색상 전달
                            onFailed: { }
                        )
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark")
                            Text("편집완료")
                        }
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 20)
                        .frame(height: 48)
                    }
                    .buttonStyle(GlassButtonStyle())
                    .foregroundColor(Color(hex: "777777"))
                    .disabled(viewModel.selectedUIColor == .clear)
                    .opacity(viewModel.selectedUIColor == .clear ? 0.4 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.white)
            }
        }
        .overlay {
            MissionJudgeOverlay(isShowing: judgeVM.isJudging)
            MissionSuccessOverlay(isShowing: judgeVM.showSuccess)
            MissionFailOverlay(isShowing: judgeVM.showFail)
        }
    }
}

// MARK: - 피커 루페 (돋보기 원형 UI)
struct PickerLoupe: View {
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(radius: 6)
            
            // 십자선
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ColorPickerView(
        capturedImage: UIImage(systemName: "photo") ?? UIImage(),
        missionColor: .customRed,
        onConfirm: { _ in },
        onCancel: { }
    )
}
