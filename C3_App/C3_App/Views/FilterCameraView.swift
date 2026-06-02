//
//  FilterCameraView.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

struct FilterCameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @ObservedObject var vm: MissionViewModel

    var onDismiss: (() -> Void)? = nil

    var body: some View {
        CommonCameraView(
            viewModel: viewModel,
            vm: vm,
            destination: nil,
            cameraMode: .filter,
            onDismiss: onDismiss
        ) {
            FilterCarouselView()
        }
    }
}

#Preview {
    FilterCameraView(vm: MissionViewModel())
}
