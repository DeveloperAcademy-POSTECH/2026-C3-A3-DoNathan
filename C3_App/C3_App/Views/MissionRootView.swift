//
//  MissionRootView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct MissionRootView: View {
    let missionColor: MissionColor
    var onDismiss: (() -> Void)?

    @StateObject var vm: MissionViewModel
    @Environment(\.dismiss) private var dismiss

    init(missionColor: MissionColor, onDismiss: (() -> Void)? = nil) {
        self.missionColor = missionColor
        self.onDismiss = onDismiss
        self._vm = StateObject(wrappedValue: MissionViewModel(missionColor: missionColor))
    }

    var body: some View {
        ZStack {
            if vm.showCompletion {
                MissionCompleteView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading ).combined(with: .opacity)
                    )) // 화면 전환 시 애니메이션 방향
            } else {
                MissionSelectView(vm: vm, onDismiss: onDismiss)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading ).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    )) // 화면 전환 시 애니메이션 방향
            }
        }
        .animation(.easeInOut(duration: 0.35), value: vm.showCompletion)
        // 앱 시작 시 8/8 완료면 완료 화면으로 바로 이동 -> 고려 필요
        .onAppear {
            if vm.allCompleted {
                vm.showCompletion = true
            }
        }
//        .fullScreenCover(isPresented: $vm.showMissionCamera) {
//            if let idx = vm.selectedIndex {
//                MissionCameraView(
//                    mission:   vm.missions[idx], // 선택된 미션 데이터
//                    mainColor: vm.mainColor, // 테마 색상
//                    onResult:  { vm.handleMissionResult(image: $0) } // 촬영 완료 콜백
//                )
//            }
//        }
    }
}

#Preview {
    MissionRootView(missionColor: MissionColor.all[0])
}
