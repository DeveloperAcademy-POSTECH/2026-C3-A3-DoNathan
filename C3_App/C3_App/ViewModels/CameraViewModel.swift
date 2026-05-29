//
//  CameraViewModel.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

import SwiftUI
import AVFoundation
import Photos
import Combine

class CameraViewModel: ObservableObject {
    private let cameraService = CameraService()
    
    @Published var session: AVCaptureSession? = nil
    @Published var isCameraReady: Bool = false
    @Published var thumbnailImage: UIImage? = nil
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var isFrontCamera: Bool = false
    @Published var alertMessage: String? = nil
    @Published var showFlashOverlay: Bool = false
    
    @Published var capturedImage: UIImage? = nil
    @Published var currentFrame: UIImage? = nil

    @Published var brightness: Double = 0.0 {
        didSet { cameraService.brightness = brightness }
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        cameraService.onSessionInitialized = { [weak self] in
            DispatchQueue.main.async {
                self?.session = self?.cameraService.captureSession
                self?.isCameraReady = true // 세션 들어오면 확실하게 켜기
            }
        }
        
        // 사진이 찍히면
        cameraService.onPhotoCaptured = { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnailImage = image // 썸네일 이미지용 빼놓고
                self?.capturedImage = image
                self?.saveToPhotoLibrary(image) // 앨범에 사진 저장
            }
        }
        
        cameraService.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.alertMessage = message
            }
        }

        cameraService.onFrameProcessed = { [weak self] image in
            self?.currentFrame = image
        }
    }
    
    // 카메라 권한 체크
    func configureCamera() {
        cameraService.checkPermissionAndSetup()
    }
    
    func startSession() { cameraService.startSession() }
    func stopSession() { cameraService.stopSession() }
    func setZoom(_ factor: CGFloat) { cameraService.setZoom(factor) }
    
    // 사진 촬영
    func takePhoto() {
        withAnimation(.easeInOut(duration: 0.1)) { showFlashOverlay = true }
        withAnimation(.easeInOut(duration: 0.25).delay(0.1)) { showFlashOverlay = false }
        cameraService.capturePhoto(flashMode: flashMode)
    }
    
    // 전후면 카메라 전환
    func toggleFlip() {
        let currentPos = cameraService.flipCamera()
        isFrontCamera = (currentPos == .front)
        if isFrontCamera { flashMode = .off }
    }
    
    // 플래시
    func toggleFlash() {
        switch flashMode {
        case .off: flashMode = .on
        case .on: flashMode = .auto
        case .auto: flashMode = .off
        @unknown default: flashMode = .off
        }
    }
    
    // 촬영 이미지 저장
    private func saveToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            })
        }
    } 
}

//// Alert을 위한 간단한 구조체
//struct AlertMessage: Identifiable {
//    let id = UUID()
//    let message: String
//}
