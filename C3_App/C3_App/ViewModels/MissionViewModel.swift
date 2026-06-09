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
            ))
        }
        
        while randomPool.count < 8 {
            if let randomMission = activeMissions.randomElement() {
                randomPool.append(Mission(
                    title: randomMission.title,
                    icon: randomMission.icon,
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
        Mission(title: "기본 카메라", icon: "camera"),
        Mission(title: "명도 조절",   icon: "sun.max"),
        Mission(title: "채도 조절",   icon: "camera.filters"),
        Mission(title: "이미지 크롭", icon: "crop"),
        Mission(title: "컬러피커",   icon: "eyedropper"),
    ]
    
    func handleMissionResult(image: UIImage?) {        
        guard let image, let idx = selectedIndex else {
            selectedIndex = nil
            return
        }
        
        missions[idx].completedImage = image
        selectedIndex = nil

        // 마지막 미션 완료 시 자동으로 MissionCompleteView로 넘기지 않음.
        // MissionCompleteOverlay가 단독으로 뜨고, 오버레이의 X 버튼 또는
        // 필터 카메라 종료 시점에 showCompletion = true 로 전환한다. (CommonCameraView 참고)
    }
}
