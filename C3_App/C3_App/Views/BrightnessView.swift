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
    
    enum BrightnessTipStatus {
        case none       // 아무것도 안 보임
        case tooBright  // 너무 밝음
        case tooDark    // 너무 어두움
    }
    
    @State private var tipStatus: BrightnessTipStatus = .none
    @State private var tipTimerTask: Task<Void, Never>? = nil // 기존 타이머를 취소하기 위한 변수

    var onDismiss: (() -> Void)? = nil

    var body: some View {
        CommonCameraView(viewModel: viewModel, vm: vm, destination: nil,  onDismiss: { vm.activeDestination = nil },
             cameraOverlay: {
                // 실시간 명도 값 관한 정보를 띄워주는 부분 .... 조건 걸어서 처리 필요 + 일정 시간만 보이고 사라지도록
                VStack {
                    // tipStatus 상태에 따라 실시간으로 분기 처리
                    switch tipStatus {
                    case .tooBright:
                        ResultBanner(text: "지금은 너무 밝아요 😓\n💡Tip : 명도를 조금만 더 내려보세요!", color: .gray)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.top, 16)
                            
                    case .tooDark:
                        ResultBanner(text: "지금은 너무 어두워요 😓\n💡Tip : 명도를 조금만 더 올려보세요!", color: .gray)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.top, 16)
                            
                    case .none:
                        EmptyView() // 정상 범위일 때는 아무것도 안 띄움
                    }
                    
                    Spacer()
                }
            },
            missionOverlay: {
                // 카메라 아래 슬롯
                BrightnessSlider(brightness: $viewModel.brightness)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .onChange(of: viewModel.brightness) {
                        checkBrightnessAndShowTip(currentValue: viewModel.brightness)
                    }
            }
        )
    }
    
    // 실시간 명도 체크하고 토스트 띄우는 함수.
    // but 기준은 미션 색상과 얼마나 비슷하냐!니까 수정 필요
    // 현재는 그냥 어두운 쪽으로 가면 어둡다고, 밝게 가면 밝다고 뜨는 수준 .. ㅋㅋ
    // 미션 색상을 기준으로 수정할 것. > 색상 인식 로직부터 짭시다
    func checkBrightnessAndShowTip(currentValue: Double) {
        // 1. 기준점 잡기 (예시: 슬라이더 값이 0.0 ~ 1.0 사이라고 가정)
        let darkThreshold: Double = -0.3   // 0.3보다 낮으면 어두움
        let brightThreshold: Double = 0.3 // 0.7보다 높으면 밝음
        
        var newStatus: BrightnessTipStatus = .none
        
        if currentValue > brightThreshold {
            newStatus = .tooBright
        } else if currentValue < darkThreshold {
            newStatus = .tooDark
        } else {
            newStatus = .none
        }
        
        // 상태가 변경되었을 때만 타이머를 새로 구동합니다.
        if tipStatus != newStatus {
            // 🌟 [중요] 기존에 돌고 있던 3초 타이머가 있다면 즉시 취소해서 꼬임 방지
            tipTimerTask?.cancel()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                tipStatus = newStatus
            }
            
            // 만약 정상 범위(.none)가 아니라면, 3초 뒤에 사라지는 타이머 가동
            if newStatus != .none {
                tipTimerTask = Task {
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3초 대기
                    
                    // 타이머가 도는 도중에 취소되지 않았다면 안전하게 닫기
                    if !Task.isCancelled {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            tipStatus = .none
                        }
                    }
                }
            }
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
