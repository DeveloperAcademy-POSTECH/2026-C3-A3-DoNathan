//
//  BrightnessView.swift
//  C3_App
//
//  Created by 최정원 on 5/28/26.
//

import SwiftUI

struct BrightnessView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var missionType: MissionType? = nil

    var onDismiss: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - 기반: 공통 카메라 뷰
            CommonCameraView(viewModel: viewModel, missionType: $missionType, onDismiss: onDismiss)

            // MARK: - 명도 슬라이더 오버레이
            VStack(spacing: 8) {
                BrightnessSlider(brightness: $viewModel.brightness)

                Text(brightnessLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            // 하단 컨트롤 바(140pt) 바로 위에 띄우기
            .padding(.bottom, 160)
        }
    }

    private var brightnessLabel: String {
        let v = viewModel.brightness
        if v > 0 { return "+\(String(format: "%.1f", v * 2))" }
        if v < 0 { return "\(String(format: "%.1f", v * 2))" }
        return "기본값"
    }
}

// MARK: - 명도 슬라이더 컴포넌트
struct BrightnessSlider: View {
    @Binding var brightness: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.min.fill")
                .foregroundColor(.white)
                .font(.system(size: 16))

            Slider(value: $brightness, in: -0.5...0.5)
                .accentColor(.yellow)

            Image(systemName: "sun.max.fill")
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.5))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    BrightnessView()
}
