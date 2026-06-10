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

        let width  = cgImage.width
        let height = cgImage.height
        let x = Int(point.x)
        let y = Int(point.y)
        guard x >= 0, y >= 0, x < width, y < height else { return nil }

        // 소스 이미지의 바이트 순서(BGRA/RGBA/와이드감마 등)에 의존하지 않도록,
        // 항상 RGBA8(Big-endian)로 정규화된 1×1 컨텍스트에 해당 픽셀만 다시 그려서 읽는다.
        // JPEG 디코드 이미지(촬영 원본)가 BGRA가 아니어서 R↔B가 뒤바뀌던 문제를 근본 차단.
        var pixel = [UInt8](repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let ctx = CGContext(
            data: &pixel,
            width: 1, height: 1,
            bitsPerComponent: 8, bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        // CG 좌표는 좌하단 원점이라, 위(top)에서 y번째 줄을 집으려면 (height-1-y)로 보정
        ctx.draw(cgImage, in: CGRect(x: -x, y: -(height - 1 - y), width: width, height: height))

        return UIColor(red:   CGFloat(pixel[0]) / 255,
                       green: CGFloat(pixel[1]) / 255,
                       blue:  CGFloat(pixel[2]) / 255,
                       alpha: CGFloat(pixel[3]) / 255)
    }
}
