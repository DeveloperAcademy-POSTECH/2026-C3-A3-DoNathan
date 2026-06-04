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
                                    imageFrame = imageGeo.frame(in: .named("imageArea"))
                                    pickerPosition = CGPoint(
                                        x: imageFrame.midX,
                                        y: imageFrame.midY
                                    )
                                }
                            }
                        )

                    CenterColorCell(color: missionColor, height: 150)
                        .frame(width: 110)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(24)
                        .allowsHitTesting(false)

                    // 피커 아이콘 (비활성 상태일 때만 표시)
                    if !isPickerActive {
                        Button {
                            isPickerActive = true
                            showResult = false
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.clear)
                                Image(systemName: "eyedropper")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "777777"))
                            }
                            .frame(width: 48, height: 48)
                            .contentShape(Circle())
                        }
                        .glassEffect(.regular, in: Circle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.trailing, 22)
                        .padding(.bottom, 32)
                    }

                    // 피커 활성화 상태일 때 루페 표시 + 드래그
                    if isPickerActive {
                        PickerLoupe(color: viewModel.selectedColor)
                            .position(pickerPosition)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
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
                    // MARK: - 결과 패널 (이미지 위 오버레이)
                    if showResult {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.selectedColor)
                                .frame(width: 56, height: 56)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 4)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("현재 선택한 색상")
                                    .font(.system(size: 12, weight: .semibold))

                                Text("컬러가 만족스럽다면 편집완료! \n또는 컬러 피커를 통해 재도전이 가능해요!")
                                    .font(.system(size: 11, weight: .semibold))

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
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(width: 385, height: 112)
                        .glassEffect(.regular.tint(.clear), in: RoundedRectangle(cornerRadius: 16))
                        .opacity(0.7)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
                .coordinateSpace(name: "imageArea")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray5))

                Spacer().frame(height: 123)

                // MARK: - 하단 버튼
                HStack {
                    Spacer()

                    Button {
                        judgeVM.start(
                            onPassed: { onConfirm(viewModel.selectedUIColor) },
                            onFailed: { }
                        )
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("편집완료")
                                .font(.system(size: 19, weight: .semibold))
                        }
                        .foregroundColor(viewModel.selectedUIColor == .clear ? Color(hex: "777777") : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            (viewModel.selectedUIColor == .clear ? Color(hex: "F7F7F7") : Color(hex: "0076FF").opacity(0.65)),
                            in: Capsule()
                        )
                    }
                    .glassEffect(.regular, in: Capsule())
                    .disabled(viewModel.selectedUIColor == .clear)
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
