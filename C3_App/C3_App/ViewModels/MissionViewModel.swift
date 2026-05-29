//
//  MissionSelectView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI
import Combine

class MissionViewModel: ObservableObject {

    private let saveKey = "savedMissions"

    @Published var missions: [Mission] = [] {
        didSet { save() }
    }

    @Published var selectedIndex: Int?   = nil
    @Published var showMissionCamera     = false
    @Published var showCompletion        = false
    @Published var showSuccessToast      = false

    let mainColor: Color = Color(red: 0.92, green: 0.46, blue: 0.60)

    var completedCount: Int { missions.filter { $0.isCompleted }.count }
    var allCompleted:   Bool { missions.allSatisfy { $0.isCompleted } }

    init() {
        load()
    }

    // MARK: - 저장 / 불러오기

    private func save() {
        if let encoded = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Mission].self, from: data) {
            missions = decoded
        } else {
            missions = Self.defaultMissions
        }
    }

    func resetMissions() {
        missions = Self.defaultMissions
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    // MARK: - 기본 미션 목록

    static let defaultMissions: [Mission] = [
        Mission(title: "컬러피커",   icon: "eyedropper",              missionDescription: "주변에서 핑크/빨간 계열 물체를 찍어보세요!"),
        Mission(title: "채도조절",   icon: "circle.hexagongrid",      missionDescription: "선명한 색깔의 물체를 찍어보세요!"),
        Mission(title: "기본 카메라", icon: "camera",                  missionDescription: "주변의 아무 사진이나 찍어보세요!"),
        Mission(title: "이미지 크롭", icon: "crop",                    missionDescription: "정사각형 구도로 사진을 찍어보세요!"),
        Mission(title: "컬러피커",   icon: "eyedropper.halffull",     missionDescription: "파란 하늘이나 바다를 찍어보세요!"),
        Mission(title: "명도 조절",  icon: "sun.max",                  missionDescription: "밝은 빛이 있는 장면을 찍어보세요!"),
        Mission(title: "기본 카메라", icon: "camera.fill",             missionDescription: "자연물(나무, 꽃 등)을 찍어보세요!"),
        Mission(title: "채도조절",   icon: "circle.hexagongrid.fill", missionDescription: "음식 사진을 찍어보세요!"),
    ]

    // MARK: - 미션 결과 처리

    func handleMissionResult(image: UIImage?) {
        showMissionCamera = false

        guard let image, let idx = selectedIndex else {
            selectedIndex = nil
            return
        }

        missions[idx].completedImage = image
        selectedIndex = nil

        if allCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    self.showCompletion = true
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { self.showSuccessToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation { self.showSuccessToast = false }
                }
            }
        }
    }
}
