////
////  CameraModel.swift
////  TestBingoSeparate
////
////  Created by 이윤진 on 5/29/26.
////
//
//// 현재 사용하지 않음. 아마 사용하지 않을 예정
//
//import AVFoundation
//import UIKit
//import Combine
//
//class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    let session     = AVCaptureSession()
//    private let output  = AVCapturePhotoOutput()
//    private var completion: ((UIImage?) -> Void)?
//
//    func start() {
//        guard session.inputs.isEmpty else { session.startRunning(); return }
//        session.sessionPreset = .photo
//
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//              let input  = try? AVCaptureDeviceInput(device: device) else { return }
//
//        if session.canAddInput(input)   { session.addInput(input) }
//        if session.canAddOutput(output) { session.addOutput(output) }
//
//        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
//    }
//
//    func stop() { session.stopRunning() }
//
//    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
//        self.completion = completion
//        let settings = AVCapturePhotoSettings()
//        output.capturePhoto(with: settings, delegate: self)
//    }
//
//    func photoOutput(_ output: AVCapturePhotoOutput,
//                     didFinishProcessingPhoto photo: AVCapturePhoto,
//                     error: Error?) {
//        guard let data = photo.fileDataRepresentation(),
//              let img  = UIImage(data: data) else {
//            completion?(nil); return
//        }
//        DispatchQueue.main.async { self.completion?(img) }
//    }
//}
