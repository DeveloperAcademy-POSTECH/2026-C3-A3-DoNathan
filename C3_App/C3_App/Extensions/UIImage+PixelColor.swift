//
//  UIImage+PixelColor.swift
//  C3_App
//
//  Created by 최정원 on 5/29/26.
//

import UIKit

// 이미지에서 특정 좌표의 픽셀 색상을 뽑아내는 확장 함수
extension UIImage {
    func pixelColor(at point: CGPoint) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return nil }
        
        let x = Int(point.x)
        let y = Int(point.y)
        
        guard x >= 0, y >= 0, x < width, y < height else { return nil }
        
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
        
        // 이미지 포맷은 BGRA, 코드는 RGBA라서 순서 수정함
        let r = CGFloat(bytes[offset + 2]) / 255
        let g = CGFloat(bytes[offset + 1]) / 255
        let b = CGFloat(bytes[offset])     / 255
        let a = CGFloat(bytes[offset + 3]) / 255
    
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
