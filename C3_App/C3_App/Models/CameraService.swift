////
////  CameraService.swift
////  TestCamera
////
////  Created by 최정원 on 5/25/26.
////
//


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
    var brightness: Double = 0.0
    var onFrameProcessed: ((UIImage) -> Void)?

    // ViewModel로 이미지를 넘겨주기 위한 콜백 클로저
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onError: ((String) -> Void)?
    var onSessionInitialized: (() -> Void)?

    func checkPermissionAndSetup() {
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
                session.addOutput(videoOutput)
                videoOutput.alwaysDiscardsLateVideoFrames = true
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




//import AVFoundation
//import UIKit
//import Photos
//import UIKit
//
//// 오직 카메라의 '기능'만 담당하는 비즈니스 로직 클래스
//// , AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
//class CameraService: NSObject {
//    var captureSession: AVCaptureSession?
//    private var photoOutput: AVCapturePhotoOutput?
//    private var currentDevice: AVCaptureDevice?
//    private var currentPosition: AVCaptureDevice.Position = .back
//    
//    // 🌟 2. 실시간 필터 처리를 위해 새로 추가할 변수들
//        private let videoOutput = AVCaptureVideoDataOutput()
//        private let context = CIContext()
//        var brightness: Double = 0.0 // 뷰모델이 실시간으로 조절할 수치
//        var onFrameProcessed: ((UIImage) -> Void)? // 뷰모델로 완성된 프레임 보내는 통로
//    
//    
//    // ViewModel로 이미지를 넘겨주기 위한 콜백 클로저
//    var onPhotoCaptured: ((UIImage) -> Void)?
//    var onError: ((String) -> Void)?
//    var onSessionInitialized: (() -> Void)?
//
//    func checkPermissionAndSetup() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            setupCaptureSession()
//        case .notDetermined: // 권한 요청을 이제 해야 함
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                if granted { self?.setupCaptureSession() }
//            }
//        default:
//            onError?("카메라 권한이 필요합니다.")
//        }
//    }
//
//    private func setupCaptureSession() {
//        let session = AVCaptureSession()
//        session.sessionPreset = .photo
//
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            onError?("카메라를 찾을 수 없습니다.")
//            return
//        }
//        currentDevice = device
//
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            if session.canAddInput(input) { session.addInput(input) }
//            
//            let output = AVCapturePhotoOutput()
//            if session.canAddOutput(output) { session.addOutput(output) }
//            
//            // 🌟 3. 실시간 프레임 가로채기용 Output 새로 추가!
////            if session.canAddOutput(videoOutput) {
////                session.addOutput(videoOutput)
////                
////                videoOutput.alwaysDiscardsLateVideoFrames = true
////                
////                // 백그라운드 큐에서 실시간 프레임 처리하도록 설정
////                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue", qos: .userInteractive))
////            }
//            
//            self.captureSession = session
//            self.photoOutput = output
//            
//            
//            onSessionInitialized?()
//            startSession()
//        } catch {
//            onError?("입력 오류: \(error.localizedDescription)")
//        }
//    }
//
//    func startSession() {
//        guard let session = captureSession, !session.isRunning else { return }
//        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
//        // startRunning, 시스템 리소스를 많이 잡아먹는 무거운 작업. 그래서 DispatchQueue로!
//    }
//
//    func stopSession() {
//        guard let session = captureSession, session.isRunning else { return }
//        session.stopRunning() // 화면이 닫힐 때 즉시 꺼져야 안전
//    }
//
//    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) {
//        guard let photoOutput = photoOutput else { return }
//        
//        let settings = AVCapturePhotoSettings()
//        settings.flashMode = flashMode
//        
//        if #available(iOS 16.0, *) {
//            photoOutput.maxPhotoDimensions = photoOutput.maxPhotoDimensions
//        } else {
//            settings.isHighResolutionPhotoEnabled = true
//        }
//        
//        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//
//    func flipCamera() -> AVCaptureDevice.Position {
//        guard let session = captureSession else { return currentPosition }
//        let newPos: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
//        
//        // 전환하는 그 새로운 하드웨어 및 input 준비
//        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPos),
//              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return currentPosition }
//        
//        session.beginConfiguration()
//        session.inputs.forEach { session.removeInput($0) } // 현재 세션에서 쓰던 input들 다 삭제
//        if session.canAddInput(newInput) {
//            session.addInput(newInput)
//            currentDevice = newDevice
//            currentPosition = newPos
//        } // 갈아끼움 input
//        session.commitConfiguration()
//        
//        return currentPosition
//    }
//}
//
//// MARK: - AVCapturePhotoCaptureDelegate
//extension CameraService: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        
//        // 🌟 1. 이 프린트문을 맨 위에 복사해서 넣어보세요!
//                print("📸 프레임 엔진 가동 중! 현재 명도 수치: \(self.brightness)")
//        
//        if let error = error {
//            onError?("촬영 오류: \(error.localizedDescription)")
//            return
//        }
//        
//        // 막 찍힌 이진 데이터 > UIImage 객체로 변환
//        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
//            onError?("이미지 변환 실패")
//            return
//        }
//        
//        // 성공적으로 찍힌 이미지를 바깥(ViewModel)으로 던져줌
//        onPhotoCaptured?(image)
//    }
//}

// MARK: - 실시간 프레임 가로채는 구역 (오타 수정 버전)
//extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
//    // 💡 매개변수 타입이 AVCaptureVideoDataOutput 이어야 합니다! (중간에 Data 확인)
//    func videoOutput(_ output: AVCaptureVideoDataOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        
//        // 1. 카메라 실시간 원본 버퍼 가져오기
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        // 2. Core Image용 이미지로 변환
//        let sourceImage = CIImage(cvImageBuffer: imageBuffer)
//        
//        // 3. CIFilter 장착 (명도/채도 조절 필터)
//        guard let filter = CIFilter(name: "CIColorControls") else { return }
//        filter.setValue(sourceImage, forKey: kCIInputImageKey)
//        filter.setValue(brightness, forKey: kCIInputBrightnessKey) // 뷰모델에서 설정한 명도 수치 주입
//        
//        // 4. 필터가 적용된 결과물 추출
//        guard let outputImage = filter.outputImage,
//              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
//        
//        // 5. UIKit 이미지로 변환 후 메인 스레드에서 뷰모델로 던지기
//        let filteredImage = UIImage(cgImage: cgImage)
//        DispatchQueue.main.async {
//            self.onFrameProcessed?(filteredImage)
//        }
//    }
//}

//import AVFoundation
//import UIKit
//import Photos
//
//// 💡 수정 포인트 1: 실시간 비디오 프레임 델리게이트 자격증(AVCaptureVideoDataOutputSampleBufferDelegate)을 클래스 선언부에 직접 명시해 줍니다.
//class CameraService: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    var captureSession: AVCaptureSession?
//    private var photoOutput: AVCapturePhotoOutput?
//    private var currentDevice: AVCaptureDevice?
//    private var currentPosition: AVCaptureDevice.Position = .back
//    
//    // 실시간 필터 처리를 위한 변수들
//    private let videoOutput = AVCaptureVideoDataOutput()
//    private let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false]) // 성능 최적화 옵션 추가
//    var brightness: Double = 0.0 // 뷰모델이 실시간으로 조절할 수치
//    var onFrameProcessed: ((UIImage) -> Void)? // 뷰모델로 완성된 프레임 보내는 통로
//    
//    // ViewModel로 이미지를 넘겨주기 위한 콜백 클로저
//    var onPhotoCaptured: ((UIImage) -> Void)?
//    var onError: ((String) -> Void)?
//    var onSessionInitialized: (() -> Void)?
//
//    func checkPermissionAndSetup() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            setupCaptureSession()
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                if granted { self?.setupCaptureSession() }
//            }
//        default:
//            onError?("카메라 권한이 필요합니다.")
//        }
//    }
//
//    private func setupCaptureSession() {
//        let session = AVCaptureSession()
//        session.sessionPreset = .high //.photo
//
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            onError?("카메라를 찾을 수 없습니다.")
//            return
//        }
//        currentDevice = device
//
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            if session.canAddInput(input) { session.addInput(input) }
//            
//            let output = AVCapturePhotoOutput()
//            if session.canAddOutput(output) { session.addOutput(output) }
//            
//            // 실시간 프레임 가로채기용 Output 추가
//            if session.canAddOutput(videoOutput) {
//                session.addOutput(videoOutput)
//                
//                videoOutput.alwaysDiscardsLateVideoFrames = true
//                // 백그라운드 큐에서 실시간 프레임 처리하도록 설정
//                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue", qos: .userInteractive))
//            }
//            
//            // 💡 수정 포인트 2: 실시간 화면이 90도 회전해서 누워 나오는 현상 방지 코드 추가
////            if let connection = videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
////                connection.videoOrientation = .portrait
////            }
//            
//            self.captureSession = session
//            self.photoOutput = output
//            
//            onSessionInitialized?()
//            startSession()
//        } catch {
//            onError?("입력 오류: \(error.localizedDescription)")
//        }
//    }
//
//    func startSession() {
//        guard let session = captureSession, !session.isRunning else { return }
//        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
//    }
//
//    func stopSession() {
//        guard let session = captureSession, session.isRunning else { return }
//        session.stopRunning()
//    }
//
//    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) {
//        guard let photoOutput = photoOutput else { return }
//        
//        let settings = AVCapturePhotoSettings()
//        settings.flashMode = flashMode
//        
//        if #available(iOS 16.0, *) {
//            photoOutput.maxPhotoDimensions = photoOutput.maxPhotoDimensions
//        } else {
//            settings.isHighResolutionPhotoEnabled = true
//        }
//        
//        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//
//    func flipCamera() -> AVCaptureDevice.Position {
//        guard let session = captureSession else { return currentPosition }
//        let newPos: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
//        
//        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPos),
//              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return currentPosition }
//        
//        session.beginConfiguration()
//        session.inputs.forEach { session.removeInput($0) }
//        if session.canAddInput(newInput) {
//            session.addInput(newInput)
//            currentDevice = newDevice
//            currentPosition = newPos
//            
//            // 💡 카메라 전/후면 전환 시에도 실시간 프레임 방향을 정방향으로 재설정해 줍니다.
//            if let connection = videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
//                connection.videoOrientation = .portrait
//                // 전면 카메라일 경우 거울 모드(좌우 반전) 활성화
//                if connection.isVideoMirroringSupported {
//                    connection.isVideoMirrored = (newPos == .front)
//                }
//            }
//        }
//        session.commitConfiguration()
//        
//        return currentPosition
//    }
//    
//    // MARK: - AVCapturePhotoCaptureDelegate (사진 찍혔을 때 구역)
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            onError?("촬영 오류: \(error.localizedDescription)")
//            return
//        }
//        
//        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
//            onError?("이미지 변환 실패")
//            return
//        }
//        
//        onPhotoCaptured?(image)
//    }
//
//    // MARK: - 실시간 프레임 가로채는 구역 (진짜 델리게이트 함수)
//    func videoOutput(_ output: AVCaptureVideoDataOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        
//        // 💡 수정 포인트 3: 진짜 실시간 프레임이 통과하는 이곳 맨 위에 프린트문을 배치해야 합니다!
//        print("📸 프레임 엔진 가동 중! 현재 명도 수치: \(self.brightness)")
//        
//        // 1. 카메라 실시간 원본 버퍼 가져오기
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        // 2. Core Image용 이미지로 변환
//        let sourceImage = CIImage(cvImageBuffer: imageBuffer)
//        
//        // 3. CIFilter 장착 (명도/채도 조절 필터)
//        guard let filter = CIFilter(name: "CIColorControls") else { return }
//        filter.setValue(sourceImage, forKey: kCIInputImageKey)
//        filter.setValue(brightness, forKey: kCIInputBrightnessKey) // 뷰모델에서 설정한 명도 수치 주입
//        
//        // 4. 필터가 적용된 결과물 추출
//        guard let outputImage = filter.outputImage,
//              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
//        
//        // 5. UIKit 이미지로 변환 후 메인 스레드에서 뷰모델로 던지기
//        let filteredImage = UIImage(cgImage: cgImage)
//        DispatchQueue.main.async {
//            self.onFrameProcessed?(filteredImage)
//        }
//    }
//}
