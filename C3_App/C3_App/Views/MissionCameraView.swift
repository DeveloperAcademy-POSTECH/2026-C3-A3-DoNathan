//
//  MissionCameraView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct MissionCameraView: View {
    let mission:   Mission
    let mainColor: Color
    let onResult:  (UIImage?) -> Void

    @StateObject private var camera = CameraModel()

    @State private var judging       = false
    @State private var resultState: ResultState = .idle
    @State private var capturedImage: UIImage? = nil

    enum ResultState { case idle, success, failure }

    var body: some View {
        ZStack {
            MissionCameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button { onResult(nil) } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.45)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Text(mission.missionDescription)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.black.opacity(0.5)))
                    .padding(.top, 8)

                Spacer()

                if resultState == .success {
                    ResultBanner(text: "✅ 미션 성공!", color: .green)
                        .transition(.scale.combined(with: .opacity))
                } else if resultState == .failure {
                    ResultBanner(text: "❌ 미션 실패! 다시 시도하세요", color: .red)
                        .transition(.scale.combined(with: .opacity))
                }

                ZStack {
                    if judging {
                        ProgressView().scaleEffect(1.6).tint(.white)
                    } else if resultState == .idle || resultState == .failure {
                        ShutterButton(mainColor: mainColor) { takePhoto() }
                    } else if resultState == .success {
                        Button {
                            if let img = capturedImage { onResult(img) }
                        } label: {
                            Text("확인")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Capsule().fill(Color.green))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 90)
                .padding(.bottom, 40)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: resultState)
            }

            if judging {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView().scaleEffect(1.4).tint(.white)
                    Text("미션 판정 중…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear   { camera.start() }
        .onDisappear { camera.stop() }
        .animation(.easeInOut(duration: 0.25), value: judging)
    }

    private func takePhoto() {
        camera.capturePhoto { image in
            guard let image else { return }
            capturedImage = image
            judging = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                judging = false
                let isSuccess = judgeMission(image: image, mission: mission)
                withAnimation { resultState = isSuccess ? .success : .failure }

                if !isSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation { resultState = .idle }
                    }
                }
            }
        }
    }

    private func judgeMission(image: UIImage, mission: Mission) -> Bool {
        return Double.random(in: 0...1) < 0.8
    }
}
