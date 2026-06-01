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
    //@Published var showMissionCamera     = false
    @Published var activeDestination: MissionType? = nil
    @Published var showCompletion        = false
    @Published var showSuccessToast      = false

    let missionColor: MissionColor
    var mainColor: Color { missionColor.color }

    init(missionColor: MissionColor = MissionColor.all[0]) {
        self.missionColor = missionColor
        load()
    }

    var completedCount: Int { missions.filter { $0.isCompleted }.count }
    var allCompleted:   Bool { missions.allSatisfy { $0.isCompleted } }
    
    var currentMissionDestination: MissionType? {
            guard let idx = selectedIndex else { return nil }
            let currentTitle = missions[idx].title
            
            switch currentTitle {
            case "기본 카메라": return .basic
            case "명도 조절":   return .brightness
            case "채도 조절":   return .saturation
            case "이미지 크롭": return .crop
            case "컬러피커":   return .colorPicker
            default:
                return .basic
            }
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
            self.missions = decoded
        } else {
            //missions = Self.defaultMissions.shuffled()
            generateRandomMissions()
        }
    }
    
    private func generateRandomMissions() {
        var randomPool: [Mission] = []
        let activeMissions = Self.defaultMissions
        
        // Step 1: 현재 주석 안 된 5가지 필수 미션을 '우선 한 번씩' 무조건 다 넣습니다.
        for mission in activeMissions {
            randomPool.append(Mission(
                title: mission.title,
                icon: mission.icon,
                missionDescription: mission.missionDescription
            ))
        }
        
        // Step 2: 이제 5개는 꽉 찼으니, 남은 3칸(총 8칸이 될 때까지)만 랜덤으로 추가 수급합니다.
        while randomPool.count < 8 {
            if let randomMission = activeMissions.randomElement() {
                randomPool.append(Mission(
                    title: randomMission.title,
                    icon: randomMission.icon,
                    missionDescription: randomMission.missionDescription
                ))
            }
        }
        
        // Step 3: 이대로 두면 앞의 5개 순서가 맨날 똑같으니, 전체 리스트를 완전 불규칙하게 섞어버립니다.
        self.missions = randomPool.shuffled()
    }

    func resetMissions() {
        //missions = Self.defaultMissions
        UserDefaults.standard.removeObject(forKey: saveKey)
        generateRandomMissions()
    }

    // MARK: - 기본 미션 목록

    static let defaultMissions: [Mission] = [
        Mission(title: "기본 카메라", icon: "camera",                  missionDescription: "주변의 아무 사진이나 찍어보세요!"),
        Mission(title: "명도 조절",  icon: "sun.max",                  missionDescription: "밝은 빛이 있는 장면을 찍어보세요!"),
        Mission(title: "채도 조절",   icon: "camera.filters",      missionDescription: "선명한 색깔의 물체를 찍어보세요!"),
        Mission(title: "이미지 크롭", icon: "crop",                    missionDescription: "정사각형 구도로 사진을 찍어보세요!"),
        Mission(title: "컬러피커",   icon: "eyedropper",              missionDescription: "주변에서 핑크/빨간 계열 물체를 찍어보세요!"),

    ]

    // MARK: - 미션 결과 처리
    func handleMissionResult(image: UIImage?) {
        //showMissionCamera = false
        activeDestination = nil

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
