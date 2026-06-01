//
//  BrightnessView.swift
//  C3_App
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI

struct BrightnessView: View {
    @StateObject private var viewModel = CameraViewModel()
    @ObservedObject var vm: MissionViewModel
    @State private var missionType: MissionType? = nil

    var onDismiss: (() -> Void)? = nil

    var body: some View {
        CommonCameraView(viewModel: viewModel, vm: vm, destination: nil,  onDismiss: { vm.activeDestination = nil }) {
            BrightnessSlider(brightness: $viewModel.brightness)
                .padding(.horizontal, 24)
                .padding(.top, 24)
        }
    }
}

// MARK: - 명도 슬라이더 컴포넌트
struct BrightnessSlider: View {
    @Binding var brightness: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.min.fill")
                .foregroundColor(Color(hex: "888888"))
                .font(.system(size: 16))

            Slider(value: $brightness, in: -0.5...0.5)
                .tint(Color(hex: "888888"))

            Image(systemName: "sun.max.fill")
                .foregroundColor(Color(hex: "888888"))
                .font(.system(size: 22))
        }
    }
}

#Preview {
    BrightnessView(vm: MissionViewModel())
}
