//
//  CommonCameraView.swift
//  TestCamera
//
//  Created by Noah on 5/29/26.
//

import SwiftUI
import AVFoundation
import Photos // PhotoKit

// MARK: - 카메라 모드
enum CameraMode {
    case mission  // 미션 카메라: X버튼 있음, 플래시 없음
    case filter   // 필터 카메라: X버튼 없음, 플래시 버튼 있음
}

struct CommonCameraView<MissionOverlay: View, CameraOverlay: View>: View {
    @ObservedObject var viewModel: CameraViewModel
    @ObservedObject var vm: MissionViewModel
    @State private var capturedImage: UIImage?
    @State private var zoomLevel: CGFloat = 1.0
    @State private var showGrid: Bool = false

    @State private var showEditView: Bool = false
    @State private var currentDestination: MissionType? = nil
    let destination: MissionType?
    var cameraMode: CameraMode = .mission
    var overlayHeight: CGFloat = 107

    var onDismiss: (() -> Void)? = nil
    @ViewBuilder var cameraOverlay: () -> CameraOverlay // 카메라 위
    @ViewBuilder var missionOverlay: () -> MissionOverlay // 카메라 아래

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - 상단 바
            HStack {
                // 좌상단: 뒤로가기
                Button(action: { onDismiss?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "888888"))
                        .frame(width: 40, height: 40)
                }
                .glassEffect(.regular.interactive(), in: Circle())

                Spacer()

                // 우상단: 그리드 토글
                Button(action: { showGrid.toggle() }) {
                    Image(systemName: "grid")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "888888"))
                        .foregroundColor(showGrid ? .yellow : .primary)
                        .frame(width: 40, height: 40)
                }
                .glassEffect(.regular.interactive(), in: Circle())

                // 우상단: 플래시 (필터 모드 전용)
                if cameraMode == .filter {
                    Button(action: { viewModel.toggleFlash() }) {
                        Image(systemName: viewModel.flashMode == .off ? "bolt.slash" : "bolt.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "888888"))
                            .frame(width: 40, height: 40)
                    }
                    .glassEffect(.regular.interactive(), in: Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 20)
            .background(Color.white)

            // MARK: - 카메라 프리뷰
            let cameraHeight = UIScreen.main.bounds.width * 4 / 3
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    Color.black

                    if let session = viewModel.session {
                        CameraPreview(session: session)
                            .ignoresSafeArea(edges: [])
                    } else {
                        ProgressView()
                            .foregroundStyle(.white)
                    }

                    // 필터 적용된 프레임 오버레이 (필터 선택 시에만)
                    if let frame = viewModel.currentFrame, viewModel.selectedFilter != .none {
                        Image(uiImage: frame)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: cameraHeight)
                            .clipped()
                    }


                    // 셔터 플래시 오버레이
                    if viewModel.showFlashOverlay {
                        Color.white.opacity(0.7)
                    }

                    // 그리드 오버레이
                    if showGrid {
                        GridOverlayView()
                    }

                    cameraOverlay()

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
                    .padding(.bottom, 18)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedFilter)
                }
                .frame(width: geo.size.width, height: cameraHeight)
            }
            .frame(height: cameraHeight)

            // MARK: - 미션 오버레이 슬롯 (항상 126pt 확보)
            ZStack {
                Color.clear
                missionOverlay()
            }
            .frame(height: overlayHeight)
            .frame(maxWidth: .infinity)

            // MARK: - 하단 컨트롤
            HStack(alignment: .center) {
                // 좌하단: X (미션 모드 전용)
                if cameraMode == .mission {
                    Button(action: { onDismiss?() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "888888"))
                            .frame(width: 48, height: 48)
                    }
                    .glassEffect(.regular.interactive(), in: Circle())
                } else {
                    Color.clear.frame(width: 48, height: 48)
                }

                Spacer()

                // 하단 중앙: 셔터
                Button(action: viewModel.takePhoto) {
                    Image("camera_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 68, height: 68)
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
                        .frame(width: 48, height: 48)
                }
                .glassEffect(.regular.interactive(), in: Circle())
            }
            .padding(.horizontal, 32)
        
            .padding(.bottom, 20)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            capturedImage = nil
            showEditView = false
            currentDestination = nil
            viewModel.resetCapturedImage()
            viewModel.configureCamera()
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onReceive(viewModel.$capturedImage) { image in
            guard let image else { return }
            capturedImage = image
            currentDestination = destination ?? vm.activeDestination
            showEditView = true
        }
        .fullScreenCover(isPresented: $showEditView) {
            if let image = capturedImage {
                switch currentDestination {
                case .filter:
                    //showEditView = false
                    EmptyView()
                case .basic:
                    EmptyView()
                    // 여기도 미션 판정 뷰로 연결하도록 수정 필요
                case .brightness:
                    EmptyView()
                    // 여기는 명도 카메라 뷰가 아닌 미션 판정 뷰로 연결하도록 수정 필요!!!
                case .saturation:
                    SaturationView(
                        capturedImage: image,
                        onConfirm: { editedImage, _ in
                            saveEditedPhoto(editedImage)
                            showEditView = false
                        },
                        onCancel: {
                            capturedImage = nil
                            showEditView = false
                        }
                    )
                case .crop:
                    CropView(
                        capturedImage: image,
                        missionColor: vm.mainColor,
                        onConfirm: { croppedImage in
                            saveEditedPhoto(croppedImage)
                            showEditView = false
                        },
                        onCancel: {
                            capturedImage = nil
                            showEditView = false
                        }
                    )
                case .colorPicker:
                    ColorPickerView(
                        capturedImage: image,
                        onConfirm: { _ in
                            showEditView = false
                        },
                        onCancel: {
                            capturedImage = nil
                            showEditView = false
                        }
                    )
                default:
                    EmptyView()
                }
            }
        }
        // 🌟 2. 캡처된 이미지를 감시하는 onChange 추가 (iOS 17+ 기준 문법)
        // (만약 이전 버전이라면 .onChange(of: capturedImage) { newValue in ... } 사용)
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil {
                // 렌즈가 스냅샷을 찍었을 때, 현재 모드가 '필터'라면 편집창을 열지 않고 바로 저장 처리
                if currentDestination == .filter {
                    if let image = newImage {
                        saveEditedPhoto(image) // 바로 사진첩 저장 또는 메인 전송
                    }
                    capturedImage = nil // 상태 초기화
                    showEditView = false // 확정 차단
                } else {
                    // 필터가 아닌 다른 커스텀 미션 모드일 때만 편집 모달을 활성화!
                    showEditView = true
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
     CommonCameraView(viewModel: CameraViewModel(),vm: MissionViewModel(), destination: .basic,
         cameraOverlay: {
            EmptyView()
         },
         missionOverlay: {
             EmptyView()
         }
     )
}
