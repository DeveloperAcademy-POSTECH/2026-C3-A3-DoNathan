//
//  MissionEvaluator.swift
//  C3_App
//
//  Created by 최정원 on 6/2/26.
//

import UIKit
import SwiftUI

struct MissionEvaluator {
    
    /// 모든 미션의 이미지 색상이 정답과 일치하는지 종합 판정하는 메인 함수
    static func evaluate(image: UIImage, type: MissionType, targetColor: Color) -> Bool {
        // 1. 이미지의 정중앙 좌표 계산
        let centerX = image.size.width / 2
        let centerY = image.size.height / 2
        let centerPoint = CGPoint(x: centerX, y: centerY)
        
        // 2. 정원님이 만드신 extension으로 중앙 픽셀 색상 추출
        guard let pixelColor = image.pixelColor(at: centerPoint) else { return false }
        
        // 비교를 위해 SwiftUI Color를 UIColor로 안전하게 변환
        let uiTargetColor = UIColor(targetColor)
        
        // 3. 미션 타입에 맞게 고유 알고리즘 가동
        switch type {
        case .basic, .crop, .colorPicker:
            // 🎨 RGB 전체가 유사한지 판정 (기본/크롭/컬러피커)
            // 미션 깐깐도에 따라 허용 오차(Tolerance) 조절 가능 (0.15 = 약 15% 이내 유사도)
            let tolerance: CGFloat = (type == .colorPicker) ? 0.10 : 0.18
            return compareRGB(colorA: pixelColor, colorB: uiTargetColor, maxDifference: tolerance)
            
        case .brightness:
            // ☀️ 명도 미션: 색상은 달라도 정답 색상만큼 '밝은가(명도 단계)' 판정
            return compareHSB(mode: .brightness, colorA: pixelColor, colorB: uiTargetColor, maxDifference: 0.20)
            
        case .saturation:
            // 🧪 채도 미션: 색상은 달라도 정답 색상만큼 '진하고 선명한가(채도)' 판정
            return compareHSB(mode: .saturation, colorA: pixelColor, colorB: uiTargetColor, maxDifference: 0.20)
            
        case .filter:
            // 필터 카메라는 판정 없이 프리패스 처리
            return true
        }
    }
    
    // MARK: - 세부 수학적 판정 알고리즘
    
    /// RGB 차이값을 수학적 거리(Euclidean Distance)로 계산하여 유사도 판정
    private static func compareRGB(colorA: UIColor, colorB: UIColor, maxDifference: CGFloat) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        colorA.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        colorB.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let rDiff = r1 - r2
        let gDiff = g1 - g2
        let bDiff = b1 - b2
        
        // 3차원 RGB 공간에서의 유클리드 거리 공식 계산
        let distance = sqrt((rDiff * rDiff) + (gDiff * gDiff) + (bDiff * bDiff))
        
        // 거리의 평균값이 허용 범위(최대 1.73) 내에 들어오는지 여부 반환
        return distance < maxDifference
    }
    
    private enum HSBMode { case saturation, brightness }
    
    /// HSB(색상, 채도, 명도) 컴포넌트를 추출하여 특정 항목만 저격 비교
    private static func compareHSB(mode: HSBMode, colorA: UIColor, colorB: UIColor, maxDifference: CGFloat) -> Bool {
        var h1: CGFloat = 0, s1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var h2: CGFloat = 0, s2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        colorA.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
        colorB.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
        
        switch mode {
        case .saturation:
            return abs(s1 - s2) < maxDifference
        case .brightness:
            return abs(b1 - b2) < maxDifference
        }
    }
}
