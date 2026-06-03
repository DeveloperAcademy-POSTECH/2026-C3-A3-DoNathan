//
//  CommonCameraView.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

import SwiftUI
import AVFoundation
import Photos

struct CommonCameraView<MissionOverlay: View>: View {
    @ObservedObject var viewModel: CameraViewModel

    @State private var capturedImage: UIImage?
    @Binding var missionType: MissionType?

    @State private var zoomLevel: CGFloat = 1.0
    @State private var showGrid: Bool = false

    var onDismiss: (() -> Void)? = nil
    @ViewBuilder var missionOverlay: () -> MissionOverlay

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 상단 바
            HStack {
                // 좌상단: 뒤로가기
                Button(action: { onDismiss?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "888888"))
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.regular.interactive(), in: Circle())

                Spacer()

                // 우상단: 그리드 토글
                Button(action: { showGrid.toggle() }) {
                    Image(systemName: "grid")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "888888"))
                        .foregroundColor(showGrid ? .yellow : .primary)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.regular.interactive(), in: Circle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)

            // MARK: - 카메라 프리뷰
            ZStack(alignment: .bottom) {
                Color.black

                if let session = viewModel.session {
                    CameraPreview(session: session)
                        .ignoresSafeArea(edges: [])
                } else {
                    ProgressView()
                        .foregroundStyle(.white)
                }

                // 셔터 플래시 오버레이
                if viewModel.showFlashOverlay {
                    Color.white.opacity(0.7)
                }

                // 필터 적용된 프레임 오버레이 (필터 선택 시에만)
                if let frame = viewModel.currentFrame, viewModel.selectedFilter != .none {
                    Image(uiImage: frame)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: cameraHeight)
                        .clipped()
                }
              
                // 그리드 오버레이
                if showGrid {
                    GridOverlayView()
                }

                // 줌 버튼 (전면 카메라일 때 0.5x 숨김)
//                 HStack(spacing: 6) {
//                     let zoomLevels: [CGFloat] = viewModel.isFrontCamera ? [1.0, 2.0] : [0.5, 1.0, 2.0]
//                     ForEach(zoomLevels, id: \.self) { zoom in
//                         let label = zoom == 0.5 ? "0.5x" : zoom == 1.0 ? "1x" : "2x"
//                         let isSelected = zoomLevel == zoom

//                         Button {
//                             zoomLevel = zoom
//                             viewModel.setZoom(zoom)
//                         } label: {
//                             Text(label)
//                                 .font(.system(size: 13, weight: .semibold))
//                                 .foregroundColor(.white)
//                                 .padding(.horizontal, 14)
//                                 .padding(.vertical, 7)
//                                 .background(
//                                     Capsule()
//                                         .fill(isSelected
//                                               ? Color.white.opacity(0.35)
//                                               : Color.black.opacity(0.4))
//                                 )
//                     cameraOverlay()

                    // 줌 버튼 + 슬라이더 (cameraOverlay 위에 렌더링)
                    VStack(spacing: 8) {
                        // 줌 버튼 (전면 카메라일 때 0.5x 숨김)
                        HStack(spacing: 6) {
                            let zoomLevels: [CGFloat] = viewModel.isFrontCamera ? [1.0, 2.0] : [0.5, 1.0, 2.0]
                            ForEach(zoomLevels, id: \.self) { zoom in
                                let label = zoom == 0.5 ? "0.5x" : zoom == 1.0 ? "1x" : "2x"
                                let isSelected = zoomLevel == zoom

                                Button {
                                    zoomLevel = zoom
                                    viewModel.setZoom(zoom)
                                } label: {
                                    Text(label)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule()
                                                .fill(isSelected
                                                      ? Color.white.opacity(0.35)
                                                      : Color.black.opacity(0.4))
                                        )
                                }
                            }
                        }

                        // 슬라이더 (필터 선택 시) - 렌더링 확인용
                        Color.red
                            .frame(height: 40)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 18)
            }
            .frame(width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.width * 4 / 3)

            // MARK: - 미션 오버레이 슬롯
            missionOverlay()
                .frame(maxWidth: .infinity)

            Spacer()

            // MARK: - 하단 컨트롤
            HStack {
                // 좌하단: X
                Button(action: { onDismiss?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "888888"))
                        .frame(width: 52, height: 52)
                }
                .glassEffect(.regular.interactive(), in: Circle())

                Spacer()

                // 하단 중앙: 셔터
                Button(action: viewModel.takePhoto) {
                    Image("camera_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 76, height: 76)
                }

                Spacer()

                // 우하단: 전후면 전환
                Button(action: {
                    viewModel.toggleFlip()
                    zoomLevel = 1.0
                }) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "888888"))
                        .frame(width: 52, height: 52)
                }
                .glassEffect(.regular.interactive(), in: Circle())
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(Color.white)
        }
        .background(Color.white)
        .onAppear {
            viewModel.configureCamera()
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onReceive(viewModel.$capturedImage) { image in
            guard let image else { return }
            capturedImage = image
            missionType = .saturation
        }
        .fullScreenCover(item: $missionType) { mission in
            if let image = capturedImage {
                switch mission {
                case .brightness:
                    EmptyView()
                case .saturation:
                    SaturationView(
                        capturedImage: image,
                        onConfirm: { editedImage, _ in
                            saveEditedPhoto(editedImage)
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
                        onConfirm: { _ in
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

    private func saveEditedPhoto(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}

// MARK: - Color Hex 익스텐션
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - 3x3 그리드 오버레이
struct GridOverlayView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                // 세로선 2개
                path.move(to: CGPoint(x: w / 3, y: 0))
                path.addLine(to: CGPoint(x: w / 3, y: h))
                path.move(to: CGPoint(x: w * 2 / 3, y: 0))
                path.addLine(to: CGPoint(x: w * 2 / 3, y: h))
                // 가로선 2개
                path.move(to: CGPoint(x: 0, y: h / 3))
                path.addLine(to: CGPoint(x: w, y: h / 3))
                path.move(to: CGPoint(x: 0, y: h * 2 / 3))
                path.addLine(to: CGPoint(x: w, y: h * 2 / 3))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 0.7)
        }
    }
}

#Preview {
    CommonCameraView(viewModel: CameraViewModel(), missionType: .constant(.crop)) {
        EmptyView()
    }
}
