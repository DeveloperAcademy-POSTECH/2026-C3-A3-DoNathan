//
//  MissionViewModel.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI
import Combine

class MissionViewModel: ObservableObject {
    @Published var missions: [Mission] = [] {
        didSet { save() }
    }

    @Published var selectedIndex: Int?   = nil
    @Published var activeDestination: MissionType? = nil
    @Published var showCompletion = false
    @Published var showMissionSuccess: Bool = false

    let missionColor: MissionColor
    var mainColor: Color { missionColor.color }
    lazy var saveKey: String = "savedMissions_\(missionColor.name)"

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
        case "필터 카메라": return .filter
        default:            return .basic
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
            generateRandomMissions()
        }
    }

    private func generateRandomMissions() {
        var randomPool: [Mission] = []
        let activeMissions = Self.defaultMissions

        for mission in activeMissions {
            randomPool.append(Mission(
                title: mission.title,
                icon: mission.icon,
                missionDescription: mission.missionDescription
            ))
        }

        while randomPool.count < 8 {
            if let randomMission = activeMissions.randomElement() {
                randomPool.append(Mission(
                    title: randomMission.title,
                    icon: randomMission.icon,
                    missionDescription: randomMission.missionDescription
                ))
            }
        }

        self.missions = randomPool.shuffled()
    }

    func resetMissions() {
        UserDefaults.standard.removeObject(forKey: saveKey)
        generateRandomMissions()
    }

    // MARK: - 기본 미션 목록
    static let defaultMissions: [Mission] = [
        Mission(title: "기본 카메라", icon: "camera",          missionDescription: "주변의 아무 사진이나 찍어보세요!"),
        Mission(title: "명도 조절",   icon: "sun.max",         missionDescription: "밝은 빛이 있는 장면을 찍어보세요!"),
        Mission(title: "채도 조절",   icon: "camera.filters",  missionDescription: "선명한 색깔의 물체를 찍어보세요!"),
        Mission(title: "이미지 크롭", icon: "crop",             missionDescription: "정사각형 구도로 사진을 찍어보세요!"),
        Mission(title: "컬러피커",   icon: "eyedropper",       missionDescription: "주변에서 핑크/빨간 계열 물체를 찍어보세요!"),
    ]
    
    func handleMissionResult(image: UIImage?) {
        activeDestination = nil
        
        guard let image, let idx = selectedIndex else {
            selectedIndex = nil
            return
        }
        
        missions[idx].completedImage = image
        selectedIndex = nil
        
        if allCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { self.showCompletion = true }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { self.showMissionSuccess = true }  // ✅ 성공 화면으로
            }
        }
    }

    // MARK: - 미션 결과 처리
//    func handleMissionResult(image: UIImage?) {
//        activeDestination = nil
//
//        guard let image, let idx = selectedIndex else {
//            selectedIndex = nil
//            return
//        }
//
//        missions[idx].completedImage = image
//        selectedIndex = nil
//
//        if allCompleted {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
//                    self.showCompletion = true
//                }
//            }
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                withAnimation { self.showSuccessToast = true }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
//                    withAnimation { self.showSuccessToast = false }
//                }
//            }
//        }
//    }
    // MARK: - 미션 결과 처리
//        func handleMissionResult(image: UIImage?) {
//            activeDestination = nil
//
//            // 사진이 정상적으로 들어왔고, 선택된 빙고 칸 인덱스가 유효한지 1차 필터링
//            guard let image, let idx = selectedIndex else {
//                selectedIndex = nil
//                return
//            }
//
//            // 🌟 2차 필터링: 현재 어떤 카메라 미션 모드인지 가져옵니다. (.basic, .brightness 등)
//            guard let currentType = currentMissionDestination else {
//                selectedIndex = nil
//                return
//            }
//
//            // 🌟 3차 필터링: 우리가 만든 만능 색상 판정기 가동!
//            // (촬영한 사진, 현재 미션 종류, 이 뷰모델이 보유한 고유 메인 정답 색상 주입)
//            let isColorMatched = MissionEvaluator.evaluate(
//                image: image,
//                type: currentType,
//                targetColor: self.mainColor
//            )
//            
//            if isColorMatched {
//                // 🎉 색상 일치 및 조건 충족 성공 시에만 데이터 반영 및 저장 처리
//                missions[idx].completedImage = image
//                selectedIndex = nil
//
//                if allCompleted {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
//                            self.showCompletion = true
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        withAnimation { self.showSuccessToast = true }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
//                            withAnimation { self.showSuccessToast = false }
//                        }
//                    }
//                }
//            } else {
//                // 😭 색상이 일치하지 않는 경우 후처리 구역
//                selectedIndex = nil
//                print("❌ 미션 실패: 촬영된 사진의 색상이 정답 색상과 일치하지 않습니다.")
//                
//                // TODO: 정원님의 필요에 따라 "색상이 맞지 않습니다! 다시 촬영해주세요" 등의 Custom Alert 플래그를 여기에 켜주시면 유저 경험이 훨씬 좋아집니다!
//            }
//        }
}
