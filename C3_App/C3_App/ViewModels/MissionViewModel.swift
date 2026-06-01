//
//  MissionSelectView.swift
//  TestBingoSeparate
//  Created by 이윤진 on 5/29/26.

//미션의 모든 상태와 동작 관리
import SwiftUI
import Combine

class MissionViewModel: ObservableObject {

    private let saveKey = "savedMissions"

    @Published var missions: [Mission] = [] {
        //didSet: 값이 바뀐 직후 자동으로 실행됨 -> missions가 바뀔 때마다 자동 저장
        didSet { save() }
    }

    @Published var selectedIndex: Int?   = nil      // 선택된 미션 번호
    @Published var showMissionCamera     = false    // 카메라 화면 표시 여부
    @Published var showCompletion        = false    // 전체 완료 화면 표시 여부
    @Published var showSuccessToast      = false    // 성공 토스트 표시 여부

    // 메인 컬러
    let mainColor: Color = Color(red: 0.92, green: 0.46, blue: 0.60)

    // 완료된 미션 개수 세기(전체 미션 배열에서 완료된 것만 걸러내서 개수 세기)
    var completedCount: Int { missions.filter { $0.isCompleted }.count }
    // 모든 미션이 완료됐는지 확인(allSatisfy -> 배열 안에 있는 모든 것들이 이 조건을 만족하는지 확인)
    var allCompleted:   Bool { missions.allSatisfy { $0.isCompleted } }

    init() {
        load()
    }

    // MARK: - 저장 / 불러오기
    // 미션 배열을 JSON으로 변환해서 UserDefaults에 저장 **
    // UserDefaults: 앱이 꺼져도 사라지지 않는 작은 저장소
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
        showMissionCamera = false   // 카메라 화면 닫기

        guard let image, let idx = selectedIndex else {
            selectedIndex = nil
            return  // 이미지나 선택된 미션 없으면 종료
        }
        // 찍은 사진 저장
        missions[idx].completedImage = image
        selectedIndex = nil

        // 모든 미션 완료
        if allCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    self.showCompletion = true
                }
            }
            
        // 단일 미션 완료
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
