//
//  MissionRootView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.

// 앱의 화면을 총괄하는 최상위 뷰(전체 조율) -> 어떤 화면 보여줄지 결정
import SwiftUI

struct MissionRootView: View {
    @StateObject var vm = MissionViewModel()

    var body: some View {
        ZStack {
            if vm.showCompletion {
                MissionCompleteView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading ).combined(with: .opacity)
                    ))
            } else {
                MissionSelectView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading ).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: vm.showCompletion)
        // 앱 시작 시 8/8 완료면 완료 화면으로 바로 이동 -> 고려 필요
        .onAppear {
                    if vm.allCompleted {
                       vm.showCompletion = true
                    }
                }
        .fullScreenCover(isPresented: $vm.showMissionCamera) {
            if let idx = vm.selectedIndex {
                MissionCameraView(
                    mission:   vm.missions[idx],
                    mainColor: vm.mainColor,
                    onResult:  { vm.handleMissionResult(image: $0) }
                )
            }
        }
    }
}
