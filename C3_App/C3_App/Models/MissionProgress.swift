//
//  MissionProgress.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import Foundation
import Combine

// 전역 미션 통과 여부 관리
class MissionProgress: ObservableObject {
    static let shared = MissionProgress()
    
    // [colorName: 통과 여부]
    @Published var results: [String: Bool] = [:]
    
    func setResult(colorName: String, passed: Bool) {
        results[colorName] = passed
    }
    
    func isPassed(colorName: String) -> Bool {
        results[colorName] ?? false
    }
    
    func reset() {
        results = [:]
    }
}
