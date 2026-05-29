//
//  CameraPreview.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        // 부모 뷰가 주는 크기에 자연스럽게 맞추기 위해 유연한 UIView 생성
        let view = UIView() // a.k.a. 빈 도화지 공간
        view.backgroundColor = .black
        
        // 프리뷰 레이어 생성 및 세션 연결
        let previewLayer = AVCaptureVideoPreviewLayer(session: session) // a.k.a. 실시간 상영 스크린
        previewLayer.videoGravity = .resizeAspectFill
        
        // 중요: 뷰의 레이어 서브레이어로 추가
        view.layer.addSublayer(previewLayer) // 도화지에 스크린 걸어둠
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 메인 스레드에서 안전하게 레이어의 크기를 현재 뷰의 실제 크기와 동기화
        DispatchQueue.main.async {
            if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                // 부모(SwiftUI)가 결정한 실제 뷰의 크기(bounds)를 레이어에 그대로 주입
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
