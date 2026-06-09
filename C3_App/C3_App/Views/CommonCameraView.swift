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
    @StateObject private var judgeVM = JudgeViewModel()
    
    @State private var capturedImage: UIImage?
    @State private var zoomLevel: CGFloat = 1.0
    @State private var showGrid: Bool = false
    @State private var showEditView: Bool = false
    @State private var currentDestination: MissionType? = nil
    @State private var showPicker = false
    @State private var showFilterCamera = false      // 미션 완료 후 필터 카메라로 이동
    @State private var showCompleteOverlay = false   // 편집 미션(채도/크롭/컬러피커)의 마지막 미션 완료 오버레이
    
    let destination: MissionType?
    var cameraMode: CameraMode = .mission
    var overlayHeight: CGFloat = 107
    
    var onDismiss: (() -> Void)? = nil
    var onMissionSuccess: (() -> Void)? = nil
    
    @ViewBuilder var cameraOverlay: () -> CameraOverlay // 카메라 위
    @ViewBuilder var missionOverlay: () -> MissionOverlay // 카메라 아래

    var body: some View {
        ZStack {
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
                            
                            // 슬라이더 (필터 선택 시)
                            if viewModel.selectedFilter != FilterOption.none {
                                HStack(spacing: 12) {
                                    Slider(value: $viewModel.filterIntensity, in: 0.0...1.0)
                                        .tint(Color(hex: "888888"))
                                }
                                .padding(.horizontal, 120)
                                .transition(.opacity)
                            }
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
                    // 좌하단: X (미션 모드 전용) -> 삭제 -> 썸네일 추가
                    // 미션 카메라 내 썸네일은 삭제(cameraMode로 분기 완료)
//                    Color.clear.frame(width: 48, height: 48)
//                    Spacer()
                    if cameraMode == .filter {
                        Button(action: {
                            showPicker = true
                        }) {
                            if let thumbnail = viewModel.thumbnailImage {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .sheet(isPresented: $showPicker) {
                            PhotoPickerView()
                        }
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
                
            MissionJudgeOverlay(isShowing: judgeVM.isJudging)
            MissionSuccessOverlay(isShowing: judgeVM.showSuccess)
            MissionFailOverlay(isShowing: judgeVM.showFail)
        
            MissionCompleteOverlay(
                isShowing: judgeVM.showCompleteSuccess || showCompleteOverlay,
                missionColor: vm.mainColor,
                onTapFilter: { showFilterCamera = true },
                onClose: {
                    // X 버튼: 미션 카메라를 닫고 MissionCompleteView로 전환
                    vm.showCompletion = true
                    onDismiss?()
                }
            )
        }
        .onAppear {
            capturedImage = nil
            showEditView = false
            currentDestination = nil
            viewModel.brightness = 0.0
            viewModel.resetAll()
            viewModel.configureCamera()
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onReceive(viewModel.$capturedImage) { (incomingImage: UIImage?) in
            guard let image = incomingImage else { return }
            capturedImage = image
            currentDestination = destination ?? vm.activeDestination

            print("[Complete] completedCount:\(vm.completedCount) / missions.count:\(vm.missions.count) / destination:\(String(describing: currentDestination))")
            switch currentDestination {
            case .basic, .brightness:
                let isLastMission = vm.completedCount == vm.missions.count - 1
                print("[Complete] isLastMission: \(isLastMission)")
                judgeVM.start(
                    image: image,
                    type: currentDestination ?? .basic,
                    targetColor: vm.mainColor,
                    isLastMission: isLastMission,
                    onPassed: {
                        vm.handleMissionResult(image: image)
                        if !isLastMission { onMissionSuccess?() }
                    },
                    onFailed: {
                        viewModel.resetAll()
                        capturedImage = nil
                    }
                )
            default:
                showEditView = true
            }
        }
        .fullScreenCover(isPresented: $showEditView) {
            if let image = capturedImage {
                switch currentDestination {
                case .saturation:
                    SaturationView(
                        capturedImage: image,
                        missionColor: vm.mainColor,
                        onConfirm: { editedImage, _ in
                            saveEditedPhoto(editedImage)
                            vm.handleMissionResult(image: editedImage)
                            showEditView = false
                            if vm.allCompleted {
                                showCompleteOverlay = true
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onMissionSuccess?()
                                }
                            }
                        },
                        onCancel: {
                            capturedImage = nil
                            showEditView = false
                        }
                    )
                case .crop:
                    CropView(
                        vm: vm,
                        capturedImage: image,
                        onConfirm: { croppedImage in
                            saveEditedPhoto(croppedImage)
                            vm.handleMissionResult(image: croppedImage)
                            showEditView = false
                            if vm.allCompleted {
                                showCompleteOverlay = true
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onMissionSuccess?()
                                }
                            }
                        },
                        onCancel: {
                            capturedImage = nil
                            showEditView = false
                        }
                    )
                case .colorPicker:
                    ColorPickerView(
                        capturedImage: image,
                        missionColor: vm.mainColor,
                        onConfirm: { selectedColor in
                            vm.handleMissionResult(image: image)
                            showEditView = false
                            if vm.allCompleted {
                                showCompleteOverlay = true
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onMissionSuccess?()
                                }
                            }
                        },
                        onCancel: {
                            capturedImage = nil
                            showEditView = false
                        }
                    )
                default: // .filter, .basic, .brightness
                    EmptyView()
                }
            }
        }
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil {
                if currentDestination == .filter {
                    if let image = newImage {
                        saveEditedPhoto(image)
                    }
                    capturedImage = nil
                    showEditView = false
                }
            }
        }
        .fullScreenCover(isPresented: $showFilterCamera) {
            // MissionColor → FilterOption 매핑
            let filter: FilterOption = {
                switch vm.missionColor.name {
                case "Red":    return .red
                case "Orange": return .orange
                case "Green":  return .green
                case "Blue":   return .blue
                case "Purple": return .purple
                default:       return .none
                }
            }()
            FilterCameraView(
                vm: vm,
                onDismiss: {
                    // 필터 카메라를 닫으면 바로 MissionCompleteView로 (B)
                    showFilterCamera = false
                    vm.showCompletion = true
                    onDismiss?()
                },
                initialFilter: filter
            )
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
