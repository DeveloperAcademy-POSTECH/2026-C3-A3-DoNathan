//
//  MissionCameraPreview.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

// 현재 사용하지 않음. 아마 사용하지 않을 예정

import SwiftUI
import AVFoundation

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
