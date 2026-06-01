//
//  CameraModel.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.

// 카메라 관련 모든 기능 담당 (카메라 on/off, 사진 촬영, 사진 데이터 처리)
import AVFoundation
import UIKit
import Combine

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    // 카메라 세션 : 입력(카메라)이랑 출력(사진)을 연결해주는 중앙관리자
    let session     = AVCaptureSession()
    // 사진 찍는 출구, private으로 외부 접근 막음
    private let output  = AVCapturePhotoOutput()
    private var completion: ((UIImage?) -> Void)?

    func start() {
        guard session.inputs.isEmpty else { session.startRunning(); return }
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input  = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input)   { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }

        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }

    func stop() { session.stopRunning() }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let img  = UIImage(data: data) else {
            completion?(nil); return
        }
        DispatchQueue.main.async { self.completion?(img) }
    }
}
