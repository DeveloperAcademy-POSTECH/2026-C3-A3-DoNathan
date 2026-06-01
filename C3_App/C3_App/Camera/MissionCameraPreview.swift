//
//  MissionCameraPreview.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.

// CameraModel의 세션을 받아서 화면에 카메라 미리보기를 보여줌
import SwiftUI
import AVFoundation

// UIKit 기반의 카메라 미리보기와 SwiftUI를 연결해주는 다리 역할 = UIViewRepresentable
struct MissionCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.setupPreview(session: session)
        return view
    }
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    func setupPreview(session: AVCaptureSession) {
        previewLayer.session      = session
        previewLayer.videoGravity = .resizeAspectFill
    }
}
