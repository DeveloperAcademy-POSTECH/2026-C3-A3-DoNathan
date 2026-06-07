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
    private static let hueToleranceDeg: CGFloat = 126.0  // Hue 허용 오차 (°) — 약 30% 유사도
    private static let saturationMin:   CGFloat = 0.03   // 채도 하한 (이하면 무채색 판정)
    private static let valueMin:        CGFloat = 0.03   // 명도 하한 (이하면 너무 어두움)
    private static let kmeansK:         Int     = 5      // K-means 클러스터 수
    private static let minClusterRatio: CGFloat = 0.05   // 선택된 클러스터의 최소 픽셀 비율 (5%)
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
            // K-means: 기준색과 Hue가 가장 가까운 클러스터 추출 → HSV 판정
            let tHSV = toHSV(from: target)
            print("[Judge] targetColor → H:\(String(format:"%.1f",tHSV.h))° S:\(String(format:"%.2f",tHSV.s)) V:\(String(format:"%.2f",tHSV.v))")
            guard let dominant = dominantColor(from: image, target: target) else {
                print("[Judge] dominantColor → nil (클러스터 비율 부족 또는 K-means 실패)")
                return false
            }
            let result = hsvJudge(pixel: dominant, target: target)
            print("[Judge] 최종 결과 → \(result ? "✅ PASS" : "❌ FAIL")")
            return result
        }
    }

    // MARK: - K-means: 기준색과 Hue가 가장 가까운 클러스터 추출
    private static func dominantColor(from image: UIImage, target: UIColor) -> UIColor? {
        guard let ciImage = CIImage(image: image) else { return nil }

        // 1. 다운스케일 (100×100 수준으로 축소 — 성능 최적화)
        let targetSize: CGFloat = 100
        let scale = min(targetSize / ciImage.extent.width,
                        targetSize / ciImage.extent.height)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // 원점을 (0,0)으로 정규화 — CIKMeans inputExtent 오류 방지
        let translated = scaled.transformed(by: CGAffineTransform(
            translationX: -scaled.extent.minX,
            y: -scaled.extent.minY
        ))

        let scaledExtent = translated.extent
        let w = Int(scaledExtent.width)
        let h = Int(scaledExtent.height)
        guard w > 0, h > 0 else { return nil }

        // 2. CIKMeans 실행 — K개 클러스터 중심색 산출
        guard let kmeansFilter = CIFilter(name: "CIKMeans") else { return nil }
        kmeansFilter.setValue(translated,   forKey: kCIInputImageKey)
        kmeansFilter.setValue(kmeansK,      forKey: "inputCount")
        kmeansFilter.setValue(10,           forKey: "inputPasses")
        kmeansFilter.setValue(true,         forKey: "inputPerceptual")
        kmeansFilter.setValue(CIVector(cgRect: scaledExtent), forKey: "inputExtent")
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
        ciContext.render(translated,
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

        // 6. 기준색과 Hue가 가장 가까운 클러스터 선택
        let targetHue = toHSV(from: target).h
        let totalPixels = w * h

        print("[Judge] K-means 클러스터 결과 (K=\(k), 총 \(totalPixels)px):")
        var closestIdx = 0
        var closestHueDiff: CGFloat = .greatestFiniteMagnitude
        for i in 0..<k {
            let c = clusterColors[i]
            let clusterColor = UIColor(red: c.r, green: c.g, blue: c.b, alpha: 1.0)
            let hsv = toHSV(from: clusterColor)
            let diff = min(abs(hsv.h - targetHue), 360 - abs(hsv.h - targetHue))
            let ratio = CGFloat(counts[i]) / CGFloat(totalPixels)
            print("  클러스터[\(i)]: H:\(String(format:"%.1f",hsv.h))° S:\(String(format:"%.2f",hsv.s)) V:\(String(format:"%.2f",hsv.v)) | 픽셀비율:\(String(format:"%.1f",ratio*100))% | 기준색과 Hue차:\(String(format:"%.1f",diff))°")
            if diff < closestHueDiff {
                closestHueDiff = diff
                closestIdx = i
            }
        }

        // 7. 선택된 클러스터가 전체 픽셀의 minClusterRatio 이상인지 확인
        let selectedRatio = CGFloat(counts[closestIdx]) / CGFloat(totalPixels)
        print("[Judge] 선택된 클러스터[\(closestIdx)]: Hue차 \(String(format:"%.1f",closestHueDiff))°, 픽셀비율 \(String(format:"%.1f",selectedRatio*100))% (최소 \(Int(minClusterRatio*100))% 필요)")
        guard selectedRatio >= minClusterRatio else {
            print("[Judge] → 픽셀 비율 부족으로 nil 반환")
            return nil
        }

        let c = clusterColors[closestIdx]
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

        print("[Judge] hsvJudge → 픽셀 H:\(String(format:"%.1f",p.h))° S:\(String(format:"%.2f",p.s)) V:\(String(format:"%.2f",p.v))")
        print("[Judge]           기준 H:\(String(format:"%.1f",t.h))°")

        // 채도 하한: 무채색에 가까우면 Hue 자체가 불안정 → 즉시 재도전
        guard p.s >= saturationMin else {
            print("[Judge] → 채도 부족(\(String(format:"%.2f",p.s)) < \(saturationMin)) FAIL")
            return false
        }

        // 명도 하한: 너무 어두우면 색 판별 불가 → 즉시 재도전
        guard p.v >= valueMin else {
            print("[Judge] → 명도 부족(\(String(format:"%.2f",p.v)) < \(valueMin)) FAIL")
            return false
        }

        // Hue 원형 거리 (0°와 360°는 같은 색이므로 min 처리)
        let delta   = abs(p.h - t.h)
        let hueDiff = min(delta, 360 - delta)
        print("[Judge] → Hue차 \(String(format:"%.1f",hueDiff))° (허용 \(hueToleranceDeg)°) \(hueDiff <= hueToleranceDeg ? "✅ PASS" : "❌ FAIL")")
        return hueDiff <= hueToleranceDeg
    }
}
