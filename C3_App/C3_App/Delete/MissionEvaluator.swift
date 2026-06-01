//
//  MissionEvaluator.swift
//  TestCameraAndCrop
//
//  Created by 최정원 on 5/28/26.
//



// 미션 성공/실패 판정 로직
// 아직 연결 xxx
// 이 코드도 우리의 기능과는 맞지 않을 겁니다 대대적 수정 필요

import UIKit

struct MissionEvaluator {
    
    // 미션 종류 확장 대비 enum
    enum MissionType {
        case saturation(target: Float, tolerance: Float)
        case brightness(target: Float, tolerance: Float)
        // 추후 다른 미션 추가 가능
    }
    
    enum MissionResult {
        case pass
        case fail(reason: String)
    }
    
    // MARK: - 미션 판별
    static func evaluate(type: MissionType, value: Float) -> MissionResult {
        switch type {
        case .saturation(let target, let tolerance):
            return checkRange(value: value, target: target,
                              tolerance: tolerance, label: "채도")
            
        case .brightness(let target, let tolerance):
            return checkRange(value: value, target: target,
                              tolerance: tolerance, label: "명도")
        }
    }
    
    private static func checkRange(value: Float, target: Float,
                                   tolerance: Float, label: String) -> MissionResult {
        let lower = target - tolerance
        let upper = target + tolerance
        if value >= lower && value <= upper {
            return .pass
        } else {
            return .fail(reason: "\(label) 범위 초과 (현재: \(String(format: "%.2f", value)), 목표: \(target)±\(tolerance))")
        }
    }
}

// 기존 MissionEvaluator에 추가, z크롭 부분
extension MissionEvaluator {
    
    // 크롭 이미지 내 특정 색상 비율 감지
    static func detectColor(in image: UIImage,
                             target: UIColor,
                             tolerance: CGFloat = 0.3) -> Float {
        guard let ciImage = CIImage(image: image) else { return 0 }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return 0 }
        
        let width = cgImage.width
        let height = cgImage.height
        guard let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return 0 }
        
        var matchCount = 0
        let totalPixels = width * height
        
        var tR: CGFloat = 0, tG: CGFloat = 0, tB: CGFloat = 0, tA: CGFloat = 0
        target.getRed(&tR, green: &tG, blue: &tB, alpha: &tA)
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = CGFloat(bytes[offset])     / 255
                let g = CGFloat(bytes[offset + 1]) / 255
                let b = CGFloat(bytes[offset + 2]) / 255
                
                // 각 채널 차이가 tolerance 이내면 해당 색상으로 판별
                if abs(r - tR) < tolerance &&
                   abs(g - tG) < tolerance &&
                   abs(b - tB) < tolerance {
                    matchCount += 1
                }
            }
        }
        
        return Float(matchCount) / Float(totalPixels)
    }
}
