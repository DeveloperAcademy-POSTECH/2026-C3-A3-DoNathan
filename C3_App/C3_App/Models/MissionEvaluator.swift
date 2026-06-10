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
    private static let valueMin:        CGFloat = 0.2    // 명도 하한 (이하면 너무 어두워 색 판별 불가)
    private static let matchRatioMin:   CGFloat = 0.06   // 기준색 픽셀이 전체에서 차지해야 하는 최소 비율 (6%)
    private static let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    // MARK: - 색상별 Hue 밴드 (중심 Hue°, 허용 오차°, 채도 하한)
    // ① 에셋 기준색 Hue가 실제 인지색과 어긋나는 문제(특히 블루=시안 194°)를 중심값으로 보정.
    // ② 인접 미션색과 겹치지 않도록 허용 오차를 색마다 다르게 (빨강·주황은 40°차 → 좁게).
    // ③ 채도 하한도 색마다 다르게: 빨강은 연한 핑크를 막으려 높게(0.6), 블루는 실제 파랑이
    //    카메라에서 채도 낮게 찍히므로 낮게(0.35). 단일 채도 게이트로는 둘을 동시에 만족 못 함.
    private struct HueBand { let center: CGFloat; let tolerance: CGFloat; let satMin: CGFloat }
    private static let hueBands: [HueBand] = [
        HueBand(center: 353, tolerance: 18, satMin: 0.6),   // Red    (에셋 350.7°) — 핑크 배제
        HueBand(center: 31,  tolerance: 18, satMin: 0.55),  // Orange (에셋 31°)
        HueBand(center: 110, tolerance: 40, satMin: 0.4),   // Green  (에셋 96° → 110°)
        HueBand(center: 212, tolerance: 32, satMin: 0.35),  // Blue   (에셋 194° 시안 → 212°) — 채도 완화
        HueBand(center: 270, tolerance: 26, satMin: 0.45),  // Purple (에셋 268°)
    ]

    // Hue 원형 거리 (0°와 360°는 같은 색)
    private static func circularHueDiff(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        let d = abs(a - b)
        return min(d, 360 - d)
    }

    // 기준색 Hue에 가장 가까운 밴드를 찾아 (보정된 중심, 허용 오차, 채도 하한) 반환
    private static func band(for targetHue: CGFloat) -> HueBand {
        hueBands.min { circularHueDiff($0.center, targetHue) < circularHueDiff($1.center, targetHue) }
            ?? HueBand(center: targetHue, tolerance: 30, satMin: 0.5)
    }

    // MARK: - 메인 판정 함수
    static func evaluate(image: UIImage, type: MissionType, targetColor: Color) -> Bool {
        let target = UIColor(targetColor)

        switch type {
        case .filter:
            // 필터 카메라는 판정 없이 프리패스
            return true

        case .colorPicker:
            // 사용자가 집은 색(중앙 픽셀) → HSV 단일 판정
            let center = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
            guard let pixel = image.pixelColor(at: center) else { return false }
            return hsvJudge(pixel: pixel, target: target)

        default:
            // 기준색 픽셀이 화면에서 충분한 비율을 차지하는지 직접 카운트
            let tHSV = toHSV(from: target)
            print("[Judge] targetColor → H:\(String(format:"%.1f",tHSV.h))° S:\(String(format:"%.2f",tHSV.s)) V:\(String(format:"%.2f",tHSV.v))")
            let ratio = targetColorRatio(from: image, target: target)
            let result = ratio >= matchRatioMin
            print("[Judge] 최종 결과 → \(result ? "✅ PASS" : "❌ FAIL") (기준색 \(String(format:"%.1f",ratio*100))% / 최소 \(String(format:"%.1f",matchRatioMin*100))%)")
            return result
        }
    }

    // MARK: - 컬러피커 전용: 선택한 색을 직접 판정
    // 1×1 이미지로 렌더 후 다시 읽는 왕복(BGRA/RGBA 바이트순서 불일치로 R↔B가 뒤바뀜)을 피하기 위해
    // 이미 올바른 UIColor인 selectedUIColor를 바로 HSV 판정한다.
    static func evaluate(pickedColor: UIColor, targetColor: Color) -> Bool {
        hsvJudge(pixel: pickedColor, target: UIColor(targetColor))
    }

    // MARK: - 기준색 픽셀 비율 (직접 카운트)
    // 다운스케일된 전체 픽셀 중, 채도·명도 게이트를 통과하고
    // 기준색과 Hue 차이가 허용 오차 이내인 픽셀의 비율을 반환.
    // 클러스터링 없이 픽셀을 직접 세므로 작은 영역도 흡수되지 않고 잡힌다.
    private static func targetColorRatio(from image: UIImage, target: UIColor) -> CGFloat {
        guard let ciImage = CIImage(image: image) else { return 0 }

        // 1. 다운스케일 (100×100 수준) + 원점 (0,0) 정규화
        let targetSize: CGFloat = 100
        let scale = min(targetSize / ciImage.extent.width,
                        targetSize / ciImage.extent.height)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let translated = scaled.transformed(by: CGAffineTransform(
            translationX: -scaled.extent.minX,
            y: -scaled.extent.minY
        ))

        let extent = translated.extent
        let w = Int(extent.width)
        let h = Int(extent.height)
        guard w > 0, h > 0 else { return 0 }

        // 2. 픽셀 비트맵으로 읽기
        var pixelRaw = [UInt8](repeating: 0, count: w * h * 4)
        ciContext.render(translated,
                         toBitmap: &pixelRaw,
                         rowBytes: w * 4,
                         bounds: extent,
                         format: .RGBA8,
                         colorSpace: CGColorSpaceCreateDeviceRGB())

        // 3. 기준색 밴드(중심 Hue ± 허용오차) + 채도/명도 게이트를 통과하는 픽셀 카운트
        let b = band(for: toHSV(from: target).h)
        let total = w * h
        var match = 0

        for px in 0..<total {
            let r = CGFloat(pixelRaw[px * 4 + 0]) / 255.0
            let g = CGFloat(pixelRaw[px * 4 + 1]) / 255.0
            let bl = CGFloat(pixelRaw[px * 4 + 2]) / 255.0
            let hsv = toHSV(from: UIColor(red: r, green: g, blue: bl, alpha: 1.0))

            // 선명하고(채도) 충분히 밝은(명도) 픽셀만 색으로 인정
            guard hsv.s >= b.satMin, hsv.v >= valueMin else { continue }

            if circularHueDiff(hsv.h, b.center) <= b.tolerance { match += 1 }
        }

        let ratio = CGFloat(match) / CGFloat(total)
        print("[Judge] 기준색 매칭 픽셀: \(match)/\(total) = \(String(format:"%.1f",ratio*100))% (조건: Hue \(Int(b.center))°±\(Int(b.tolerance))°, S≥\(b.satMin), V≥\(valueMin))")
        return ratio
    }

    // MARK: - HSV 변환
    private static func toHSV(from color: UIColor) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        return (h * 360, s, v)   // Hue를 0~360° 로 변환
    }

    // MARK: - HSV 단일 판정 (컬러피커용)
    // 채도 게이트 → 명도 게이트 → Hue 원형 거리 순서로 판정
    private static func hsvJudge(pixel: UIColor, target: UIColor) -> Bool {
        let p = toHSV(from: pixel)
        let t = toHSV(from: target)

        // 색상별 밴드(보정된 중심 Hue ± 허용오차, 채도 하한)
        let b = band(for: t.h)

        print("[Judge] hsvJudge → 픽셀 H:\(String(format:"%.1f",p.h))° S:\(String(format:"%.2f",p.s)) V:\(String(format:"%.2f",p.v))")
        print("[Judge]           기준 H:\(String(format:"%.1f",t.h))° (밴드 \(Int(b.center))°±\(Int(b.tolerance))°, S≥\(b.satMin))")

        // 채도 하한: 무채색/연한 색에 가까우면 Hue 자체가 불안정 → 즉시 재도전
        guard p.s >= b.satMin else {
            print("[Judge] → 채도 부족(\(String(format:"%.2f",p.s)) < \(b.satMin)) FAIL")
            return false
        }

        // 명도 하한: 너무 어두우면 색 판별 불가 → 즉시 재도전
        guard p.v >= valueMin else {
            print("[Judge] → 명도 부족(\(String(format:"%.2f",p.v)) < \(valueMin)) FAIL")
            return false
        }

        let hueDiff = circularHueDiff(p.h, b.center)
        print("[Judge] → Hue차 \(String(format:"%.1f",hueDiff))° (기준 \(Int(b.center))°±\(Int(b.tolerance))°) \(hueDiff <= b.tolerance ? "✅ PASS" : "❌ FAIL")")
        return hueDiff <= b.tolerance
    }
}
