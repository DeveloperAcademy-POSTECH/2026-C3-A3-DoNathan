//
//  FilterCameraView.swift
//  C3_App
//
//  Created by Noah on 6/1/26.
//

import SwiftUI

struct FilterCameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @ObservedObject var vm: MissionViewModel
    var onDismiss: (() -> Void)?

    var body: some View {
        CommonCameraView(viewModel: viewModel,
                         vm: vm,
                         destination: .filter,
                         onDismiss: { onDismiss?() },
            cameraOverlay: {
                // 그레인 오버레이 (None이 아닌 필터 선택 시)
                if viewModel.selectedFilter != .none {
                    Image("grain_texture")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3) // 수치 조정 포인트 (0.0 ~ 1.0)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                }
            },
            missionOverlay: {
                FilterCarouselView(selectedFilter: $viewModel.selectedFilter)
            }
        )
    }
}

#Preview {
    FilterCameraView(vm: MissionViewModel())
}
