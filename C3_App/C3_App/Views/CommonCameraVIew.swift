//
//  CommonCameraView.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

import SwiftUI
import AVFoundation
import Photos

struct CommonCameraView: View {
    @StateObject var viewModel = CameraViewModel()
    //let overlayContent: () -> Content
    
    @State private var capturedImage: UIImage?
    @Binding var missionType: MissionType?
    @State private var showEditView: Bool = false

    var body: some View {
        ZStack {
            // 전체 배경
            Color.black.edgesIgnoringSafeArea(.all)
        
            // 실시간 카메라 프리뷰
            if let session = viewModel.session {
                CameraPreview(session: session)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .foregroundStyle(.white)
            }
            
            
            // 2. 셔터 플래시 애니메이션 레이어
            if viewModel.showFlashOverlay {
                Color.white
                    .opacity(0.7)
                    .ignoresSafeArea()
            }

            // UI 버튼들
            VStack {
                // [상단] 플래시
                HStack {
                    Button(action: viewModel.toggleFlash) {
                        Image(systemName: flashIconName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(viewModel.flashMode == .off ? .white : .yellow)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isFrontCamera)
                    .opacity(viewModel.isFrontCamera ? 0.35 : 1.0)

                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 8)

                Spacer()

                // [하단] 컨트롤 바
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.45))
                        .ignoresSafeArea()

                    HStack(spacing: 0) {
                        // 왼쪽: 썸네일 버튼
                        Group {
                            if let thumbnail = viewModel.thumbnailImage {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Color(white: 0.2).opacity(0.8)
                            }
                        }
                        .frame(width: 52, height: 52)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.6), lineWidth: 2))
                        .padding(.leading, 28)

                        Spacer()

                        // 중앙: 셔터 버튼
                        Button(action: viewModel.takePhoto) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 5)
                                        .frame(width: 80, height: 80)
                                )
                                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                        }

                        Spacer()

                        // 오른쪽: 전후면 전환 버튼
                        Button(action: viewModel.toggleFlip) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color(white: 0.15).opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 28)
                    }
                }
                .frame(height: 140)
                .ignoresSafeArea()
            }
            
            //overlayContent()
        }
        .onAppear {
            viewModel.configureCamera()
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        //CameraViewModel에서 촬영 완료 이미지 수신
        .onReceive(viewModel.$capturedImage) { image in
            guard let image else { return }
            capturedImage = image
            showEditView = true // 촬영 완료 시 다음 미션 화면으로 cover
            
//            if missionType == nil {
//                print("missionType이 설정되지 않았습니다.")
//            }
            
        }
        .fullScreenCover(isPresented: $showEditView) {
            if let image = capturedImage, let mission = missionType {
                switch mission {
                case .brightness:
                    EmptyView()
                case .saturation:
                    SaturationView(
                        capturedImage: image,
                        onConfirm: { editedImage, saturationValue in
                            saveEditedPhoto(editedImage) // 편집본 추가저장
                            handleMission(image: editedImage, saturation: saturationValue)
                            missionType = nil
                        },
                        onCancel: {
                            capturedImage = nil
                            missionType = nil
                        }
                    )
                case .crop:
                    CropView(
                        capturedImage: image,
                        onConfirm: { croppedImage in
                            saveEditedPhoto(croppedImage)
                            // 색상 감지 미션 판별
                            //                        let ratio = MissionEvaluator.detectColor(
                            //                            in: croppedImage,
                            //                            target: UIColor.red,    // 감지할 색상
                            //                            tolerance: 0.3
                            //                        )
                            //                        let result = ratio > 0.3 ? "통과" : "실패"
                            //                        print("색상 감지 비율: \(ratio) → \(result)")
                            missionType = nil
                        },
                        onCancel: {
                            capturedImage = nil
                            missionType = nil
                        }
                    )
                case .colorPicker:
                    ColorPickerView(
                        capturedImage: image,
                        onConfirm: { selectedColor in
                            // 선택된 색상으로 미션 판별
//                            let ratio = MissionEvaluator.detectColor(
//                                in: image,
//                                target: selectedColor,
//                                tolerance: 0.3
//                            )
//                            print("색상 일치율: \(ratio)")
                            missionType = nil
                        },
                        onCancel: {
                            capturedImage = nil
                            missionType = nil
                        }
                    )
                }
            }
        }
    }
    
    // ✅ 추가
    private func saveEditedPhoto(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    // ✅ 추가: 미션 판별 로직, 현재는 작동 xxx
    // Model로 빼서 모든 미션에서 사용할 수 있도록 빼서 작업하자
    private func handleMission(image: UIImage, saturation: Float) {
        // 예시: 채도 범위로 미션 통과 여부 판별
        if saturation >= 0.8 && saturation <= 1.2 {
            print("미션 통과 (\(saturation))")
        } else {
            print("미션 실패 (\(saturation))")
        }
    }
    
    private var flashIconName: String {
        switch viewModel.flashMode {
        case .off: return "bolt.slash.fill"
        case .on: return "bolt.fill"
        case .auto: return "bolt.badge.a.fill"
        @unknown default: return "bolt.slash.fill"
        }
    }
}

#Preview {
    CommonCameraView(missionType: .constant(.crop))
}

