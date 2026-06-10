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
    private let saveKey = "missionProgress()"
    
    // [colorName: 통과 여부]
    @Published var results: [String: Bool] = [:] {
        didSet { save() }
    }
    
    init() {
        load()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            results = decoded
        }
    }
    
    func setResult(colorName: String, passed: Bool) {
        results[colorName] = passed
    }
    
    func isPassed(colorName: String) -> Bool {
        results[colorName] ?? false
    }
    
    func reset() {
        results = [:]
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
}
