//
//  SaturationViewModel.swift
//  TestCamera
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Combine

class SaturationViewModel: ObservableObject {
    @Published var saturation: Float = 1.0
    @Published var previewImage: UIImage?   // 슬라이더 드래그 중 저해상도
    @Published var finalImage: UIImage?     // 편집완료 시 고해상도

    private let context = CIContext()
    private var originalImage: UIImage?
    private var previewCIImage: CIImage?    // 다운샘플된 CIImage 캐싱
    private var originalCIImage: CIImage?   // 원본 CIImage 캐싱

    // MARK: - 초기 이미지 세팅
    func setImage(_ image: UIImage) {
        // ✅ 수정: orientation 보정 후 CIImage 생성
            let orientedImage = image.fixedOrientation()
            originalCIImage = CIImage(image: orientedImage)
            previewCIImage = makeDownsampledCIImage(from: orientedImage, scale: 0.25)

        // 초기 렌더링 (원본 그대로 = saturation 1.0)
        applyPreviewFilter()
    }

    // MARK: - 드래그 중 (저해상도 빠른 렌더링)
    func applyPreviewFilter() {
        guard let ciImage = previewCIImage else { return }
        let result = applyColorControls(to: ciImage, saturation: saturation)
        renderAsync(ciImage: result, extent: ciImage.extent) { [weak self] uiImage in
            self?.previewImage = uiImage
        }
    }

    // MARK: - 드래그 종료 시 (원본 해상도 고품질 렌더링)
    func applyHighResFilter() {
        guard let ciImage = originalCIImage else { return }
        let result = applyColorControls(to: ciImage, saturation: saturation)
        renderAsync(ciImage: result, extent: ciImage.extent) { [weak self] uiImage in
            self?.previewImage = uiImage   // 미리보기도 고해상도로 교체
            self?.finalImage = uiImage     // 저장용 최종 이미지
        }
    }

    // MARK: - Core Image 채도 필터
    private func applyColorControls(to ciImage: CIImage, saturation: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = saturation
        filter.brightness = 0
        filter.contrast = 1
        return filter.outputImage ?? ciImage
    }

    // MARK: - 비동기 렌더링 (메인스레드 블로킹 방지)
    private func renderAsync(ciImage: CIImage,
                              extent: CGRect,
                              completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self,
                  let cgImage = self.context.createCGImage(ciImage, from: extent) else { return }
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                completion(uiImage)
            }
        }
    }

    // MARK: - 다운샘플 CIImage 생성
    private func makeDownsampledCIImage(from image: UIImage, scale: CGFloat) -> CIImage? {
        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let downsampled = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return CIImage(image: downsampled)
    }
}

extension UIImage {
    /// CIImage 변환 전 orientation을 픽셀에 직접 반영
    func fixedOrientation() -> UIImage {
        // 이미 정방향이면 그대로 반환
        guard imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}
