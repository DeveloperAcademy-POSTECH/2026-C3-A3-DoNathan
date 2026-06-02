////
////  CameraService.swift
////  TestCamera
////
////  Created by 최정원 on 5/25/26.
////

import AVFoundation
import UIKit
import Photos

// 오직 카메라의 '기능'(사진 촬영 및 전후면 전환)만 담당하는 비즈니스 로직 클래스
class CameraService: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?
    private var currentPosition: AVCaptureDevice.Position = .back

    // 실시간 프레임 처리
    private let videoOutput = AVCaptureVideoDataOutput()
    private let frameQueue = DispatchQueue(label: "camera.frame.queue", qos: .userInteractive)
    private let frameContext = CIContext(options: [.useSoftwareRenderer: false])
    var brightness: Double = 0.0 {
        didSet { applyExposureBias() }
    }
    var onFrameProcessed: ((UIImage) -> Void)?

    // ViewModel로 이미지를 넘겨주기 위한 콜백 클로저
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onError: ((String) -> Void)?
    var onSessionInitialized: (() -> Void)?

    func checkPermissionAndSetup() {
        if captureSession != nil { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined: // 권한 요청을 처음 해야 하는 경우
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
        default:
            onError?("카메라 권한이 필요합니다.")
        }
    }

    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo // 사진 촬영 최적화 모드로 복구

        // 기본값: 1x 광각 카메라로 시작
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            onError?("카메라를 찾을 수 없습니다.")
            return
        }
        currentDevice = device

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }

            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) { session.addOutput(output) }

            // 실시간 프레임 출력 추가
            if session.canAddOutput(videoOutput) {
                videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                videoOutput.alwaysDiscardsLateVideoFrames = true
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: frameQueue)
                setVideoOrientation()
            }

            self.captureSession = session
            self.photoOutput = output

            onSessionInitialized?()
            startSession()
        } catch {
            onError?("입력 오류: \(error.localizedDescription)")
        }
    }

    func startSession() {
        guard let session = captureSession, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
    }

    func stopSession() {
        guard let session = captureSession, session.isRunning else { return }
        session.stopRunning()
    }

    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) {
        guard let photoOutput = photoOutput else { return }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode

        if #available(iOS 16.0, *) {
            photoOutput.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        } else {
            settings.isHighResolutionPhotoEnabled = true
        }

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func setZoom(_ displayFactor: CGFloat) {
        guard let session = captureSession else { return }

        // 0.5x → 초광각, 나머지 → 광각 + zoomFactor
        let targetType: AVCaptureDevice.DeviceType = displayFactor == 0.5
            ? .builtInUltraWideCamera
            : .builtInWideAngleCamera
        let targetZoomFactor: CGFloat = displayFactor == 0.5 ? 1.0 : displayFactor

        // 같은 디바이스면 줌 팩터만 변경
        if currentDevice?.deviceType == targetType {
            applyZoomFactor(targetZoomFactor)
            return
        }

        // 다른 디바이스면 세션 입력 교체 (즉각적인 컷 전환)
        guard let newDevice = AVCaptureDevice.default(targetType, for: .video, position: currentPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentDevice = newDevice
        }
        session.commitConfiguration()

        applyZoomFactor(targetZoomFactor)
    }

    private func applyExposureBias() {
        guard let device = currentDevice else { return }
        let bias = Float(brightness * 4)
        let clamped = max(device.minExposureTargetBias, min(device.maxExposureTargetBias, bias))
        DispatchQueue.global(qos: .userInteractive).async {
            try? device.lockForConfiguration()
            device.setExposureTargetBias(clamped, completionHandler: nil)
            device.unlockForConfiguration()
        }
    }

    private func applyZoomFactor(_ factor: CGFloat) {
        guard let device = currentDevice else { return }
        let clamped = max(device.minAvailableVideoZoomFactor,
                          min(factor, device.maxAvailableVideoZoomFactor))
        try? device.lockForConfiguration()
        device.videoZoomFactor = clamped
        device.unlockForConfiguration()
    }

    func flipCamera() -> AVCaptureDevice.Position {
        guard let session = captureSession else { return currentPosition }
        let newPos: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPos),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return currentPosition }
        
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentDevice = newDevice
            currentPosition = newPos
            applyZoomFactor(1.0)
            setVideoOrientation()
        }
        session.commitConfiguration()

        return currentPosition
    }
}

// MARK: - 비디오 방향 설정
extension CameraService {
    func setVideoOrientation() {
        guard let connection = videoOutput.connection(with: .video) else { return }
        if #available(iOS 17.0, *) {
            connection.videoRotationAngle = 90
        } else {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        // 전면 카메라 좌우 반전
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = (currentPosition == .front)
        }
    }
}

// MARK: - 실시간 프레임 처리
extension CameraService {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        var ciImage = CIImage(cvImageBuffer: imageBuffer)

        // 명도 필터 적용
        if brightness != 0.0 {
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.brightness = Float(brightness)
            filter.saturation = 1.0
            filter.contrast = 1.0
            ciImage = filter.outputImage ?? ciImage
        }


        guard let cgImage = frameContext.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)

        DispatchQueue.main.async { [weak self] in
            self?.onFrameProcessed?(uiImage)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate (사진 촬영 완료 처리)
extension CameraService {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            onError?("촬영 오류: \(error.localizedDescription)")
            return
        }
        
        // 촬영된 바이너리 데이터를 UIImage 객체로 변환
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            onError?("이미지 변환 실패")
            return
        }
        
        // 성공적으로 찍힌 이미지를 바깥(ViewModel)으로 전달
        onPhotoCaptured?(image)
    }
}
