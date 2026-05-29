//
//  CropViewModel.swift
//  TestCameraAndCrop
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Combine

class CropViewModel: ObservableObject {
    @Published var cropOffset: CGSize = .zero // 크롭 박스 위치 (드래그로 이동)
    @Published var croppedImage: UIImage?
    @Published var actualImageSize: CGSize = .zero // 실제 이미지 표시 크기 저장
    
    private let context = CIContext()
    var cropBoxSize: CGSize = CGSize(width: 260, height: 260)  // onAppear에서 덮어씀
    
    // MARK: - 실제 크롭 실행
    func cropImage(_ image: UIImage, displaySize: CGSize, completion: @escaping () -> Void) {
        guard let ciImage = CIImage(image: image.fixedOrientation()) else { return }
        
        let imageSize = ciImage.extent.size
        
        // scaledToFit 기준 실제 이미지 표시 크기 계산
        let imageAspect = imageSize.width / imageSize.height
        let displayAspect = displaySize.width / displaySize.height
        
        let actualImageSize: CGSize
        if imageAspect < displayAspect {
            // 세로 사진: 높이가 기준
            let height = displaySize.height
            let width = height * imageAspect
            actualImageSize = CGSize(width: width, height: height)
        } else {
            // 가로 사진: 너비가 기준
            let width = displaySize.width
            let height = width / imageAspect
            actualImageSize = CGSize(width: width, height: height)
        }
        
        // 실제 이미지 표시 크기 기준으로 scale 계산
        let scaleX = imageSize.width / actualImageSize.width
        let scaleY = imageSize.height / actualImageSize.height
        
        // 화면상 크롭 박스 중심 → 실제 픽셀 좌표 변환
        let centerX = actualImageSize.width / 2 + cropOffset.width
        let centerY = actualImageSize.height / 2 + cropOffset.height
        
        let cropW = cropBoxSize.width * scaleX
        let cropH = cropBoxSize.height * scaleY
        
        // CIImage 좌표계는 좌하단 기준이라 Y축 반전
        let cropRect = CGRect(
            x: centerX * scaleX - cropW / 2,
            y: imageSize.height - (centerY * scaleY + cropH / 2),
            width: cropW,
            height: cropH
        )
        
        let cropped = ciImage.cropped(to: cropRect)
        guard let cgImage = context.createCGImage(cropped, from: cropped.extent) else { return }
        
        DispatchQueue.main.async {
            self.croppedImage = UIImage(cgImage: cgImage)
            completion() // 이미지 세팅 후 콜백 호출
        }
    }
    
    // 이미지 실제 표시 크기 기반으로 동적 계산
    func calculateCropBoxSize(image: UIImage, displaySize: CGSize) -> CGSize {
        let imageAspect = image.size.width / image.size.height
        let displayAspect = displaySize.width / displaySize.height
        
        // scaledToFit 기준 실제 이미지 표시 크기
        let actualImageSize: CGSize
        if imageAspect < displayAspect {
            // 세로가 기준 (세로 사진인 경우)
            let height = displaySize.height
            let width = height * imageAspect
            actualImageSize = CGSize(width: width, height: height)
        } else {
            let width = displaySize.width
            let height = width / imageAspect
            actualImageSize = CGSize(width: width, height: height)
        }
        
        // 실제 이미지 표시 크기의 60% 를 박스로 사용
        let boxSize = min(actualImageSize.width, actualImageSize.height) * 0.6
        return CGSize(width: boxSize, height: boxSize)
    }
    
    // 실제 이미지 표시 크기 계산 함수
    func calcActualImageSize(image: UIImage, displaySize: CGSize) -> CGSize {
        let imageAspect = image.size.width / image.size.height
        let displayAspect = displaySize.width / displaySize.height
        
        if imageAspect < displayAspect {
            let height = displaySize.height
            let width = height * imageAspect
            return CGSize(width: width, height: height)
        } else {
            let width = displaySize.width
            let height = width / imageAspect
            return CGSize(width: width, height: height)
        }
    }
}
