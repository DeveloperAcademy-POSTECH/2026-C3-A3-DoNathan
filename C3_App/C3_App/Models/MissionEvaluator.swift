//
//  MissionEvaluator.swift
//  C3_App
//
//  Created by 최정원 on 6/2/26.
//

import UIKit
import SwiftUI
import CoreImage

struct MissionEvaluator {

    // MARK: - 판정 파라미터 (실기기 테스트 후 튜닝)
    private static let hueToleranceDeg: CGFloat = 20.0   // Hue 허용 오차 (°)
    private static let saturationMin:   CGFloat = 0.3    // 채도 하한 (이하면 무채색 판정)
    private static let valueMin:        CGFloat = 0.2    // 명도 하한 (이하면 너무 어두움)
    private static let kmeansK:         Int     = 5      // K-means 클러스터 수
    private static let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    // MARK: - 메인 판정 함수
    static func evaluate(image: UIImage, type: MissionType, targetColor: Color) -> Bool {
        let target = UIColor(targetColor)

        switch type {
        case .filter:
            // 필터 카메라는 판정 없이 프리패스
            return true

        case .colorPicker:
            // 지점(중앙 픽셀) 추출 → HSV 판정
            let center = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
            guard let pixel = image.pixelColor(at: center) else { return false }
            return hsvJudge(pixel: pixel, target: target)

        default:
            // K-means 지배색 추출 → HSV 판정
            guard let dominant = dominantColor(from: image) else { return false }
            return hsvJudge(pixel: dominant, target: target)
        }
    }

    // MARK: - K-means 지배색 추출
    private static func dominantColor(from image: UIImage) -> UIColor? {
        guard let ciImage = CIImage(image: image) else { return nil }

        // 1. 다운스케일 (100×100 수준으로 축소 — 성능 최적화)
        let targetSize: CGFloat = 100
        let scale = min(targetSize / ciImage.extent.width,
                        targetSize / ciImage.extent.height)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let scaledExtent = scaled.extent
        let w = Int(scaledExtent.width)
        let h = Int(scaledExtent.height)
        guard w > 0, h > 0 else { return nil }

        // 2. CIKMeans 실행 — K개 클러스터 중심색 산출
        guard let kmeansFilter = CIFilter(name: "CIKMeans") else { return nil }
        kmeansFilter.setValue(scaled,    forKey: kCIInputImageKey)
        kmeansFilter.setValue(kmeansK,   forKey: "inputCount")
        kmeansFilter.setValue(10,        forKey: "inputPasses")
        kmeansFilter.setValue(true,      forKey: "inputPerceptual")
        guard let meansImage = kmeansFilter.outputImage else { return nil }

        // 3. K개 중심색을 비트맵으로 읽기 (meansImage = K×1 픽셀)
        let k = kmeansK
        var meansRaw = [UInt8](repeating: 0, count: k * 4)
        ciContext.render(meansImage,
                         toBitmap: &meansRaw,
                         rowBytes: k * 4,
                         bounds: CGRect(x: meansImage.extent.minX,
                                        y: meansImage.extent.minY,
                                        width: CGFloat(k),
                                        height: 1),
                         format: .RGBA8,
                         colorSpace: CGColorSpaceCreateDeviceRGB())

        var clusterColors: [(r: CGFloat, g: CGFloat, b: CGFloat)] = []
        for i in 0..<k {
            clusterColors.append((
                r: CGFloat(meansRaw[i * 4 + 0]) / 255.0,
                g: CGFloat(meansRaw[i * 4 + 1]) / 255.0,
                b: CGFloat(meansRaw[i * 4 + 2]) / 255.0
            ))
        }

        // 4. 다운스케일 이미지 픽셀을 비트맵으로 읽기
        var pixelRaw = [UInt8](repeating: 0, count: w * h * 4)
        ciContext.render(scaled,
                         toBitmap: &pixelRaw,
                         rowBytes: w * 4,
                         bounds: scaledExtent,
                         format: .RGBA8,
                         colorSpace: CGColorSpaceCreateDeviceRGB())

        // 5. 각 픽셀을 가장 가까운 클러스터에 배정 → 클러스터별 카운트
        var counts = [Int](repeating: 0, count: k)
        for px in 0..<(w * h) {
            let r = CGFloat(pixelRaw[px * 4 + 0]) / 255.0
            let g = CGFloat(pixelRaw[px * 4 + 1]) / 255.0
            let b = CGFloat(pixelRaw[px * 4 + 2]) / 255.0

            var minDist: CGFloat = .greatestFiniteMagnitude
            var minIdx  = 0
            for i in 0..<k {
                let dr = r - clusterColors[i].r
                let dg = g - clusterColors[i].g
                let db = b - clusterColors[i].b
                let dist = dr*dr + dg*dg + db*db
                if dist < minDist {
                    minDist = dist
                    minIdx  = i
                }
            }
            counts[minIdx] += 1
        }

        // 6. 가장 큰 클러스터의 중심색 반환 → 지배색
        guard let maxIdx = counts.indices.max(by: { counts[$0] < counts[$1] }) else { return nil }
        let c = clusterColors[maxIdx]
        return UIColor(red: c.r, green: c.g, blue: c.b, alpha: 1.0)
    }

    // MARK: - HSV 변환
    private static func toHSV(from color: UIColor) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        return (h * 360, s, v)   // Hue를 0~360° 로 변환
    }

    // MARK: - HSV 판정
    // 채도 게이트 → 명도 게이트 → Hue 원형 거리 순서로 판정
    private static func hsvJudge(pixel: UIColor, target: UIColor) -> Bool {
        let p = toHSV(from: pixel)
        let t = toHSV(from: target)

        // 채도 하한: 무채색에 가까우면 Hue 자체가 불안정 → 즉시 재도전
        guard p.s >= saturationMin else { return false }

        // 명도 하한: 너무 어두우면 색 판별 불가 → 즉시 재도전
        guard p.v >= valueMin else { return false }

        // Hue 원형 거리 (0°와 360°는 같은 색이므로 min 처리)
        let delta   = abs(p.h - t.h)
        let hueDiff = min(delta, 360 - delta)
        return hueDiff <= hueToleranceDeg
    }
}
