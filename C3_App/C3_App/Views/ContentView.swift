//
//  ContentView.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

// 테스트카메라 + 채도 편집 + 크롭 까지의 테스트 코드
// missionType를 바꿔서 주면 카메라 촬영 뒤 연결되는 화면이 달라지도록
// 앞선 미션 빙고 화면에서 버튼 클릭 시 missionType을 넘겨주어서 그 값을 뿌려줘야 할 것 같다고 추측
// 근데 실시간 명도 조절은 플로우가 다른데? 암튼..

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var missionType: MissionType? = .colorPicker
    
    var body: some View {
        
        CommonCameraView(missionType: $missionType)
    }
}

#Preview {
    ContentView()
}

