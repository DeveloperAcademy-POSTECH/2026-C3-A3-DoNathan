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
                         overlayHeight: 126,
                         onDismiss: { onDismiss?() },
            cameraOverlay: {
                // 그레인 오버레이 (None 이외의 필터 선택 시)
                if viewModel.selectedFilter != .none {
                    Image("grain_texture")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                }
            },
            missionOverlay: {
                FilterCarouselView(
                    selectedFilter: $viewModel.selectedFilter,
                    filterIntensity: $viewModel.filterIntensity
                )
            }
        )
    }
}

#Preview {
    FilterCameraView(vm: MissionViewModel())
}
