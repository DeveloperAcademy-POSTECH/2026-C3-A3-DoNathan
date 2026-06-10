//
//  JudgeViewModel.swift
//  C3_App
//
//  Created by 최정원 on 6/3/26.
//

import SwiftUI
import Combine

class JudgeViewModel: ObservableObject {
    @Published var state: JudgeState = .idle

    var isJudging:         Bool { state == .judging }
    var showSuccess:       Bool { state == .success }
    var showFail:          Bool { state == .failure }
    var showCompleteSuccess: Bool { state == .completeSuccess }
    var isDisabled:        Bool { state != .idle }

    func start(image: UIImage,
               type: MissionType,
               targetColor: Color,
               isLastMission: Bool = false,
               onPassed: @escaping () -> Void,
               onFailed: @escaping () -> Void) {
        run(isLastMission: isLastMission, onPassed: onPassed, onFailed: onFailed) {
            MissionEvaluator.evaluate(image: image, type: type, targetColor: targetColor)
        }
    }

    // 컬러피커 전용: 선택한 색(UIColor)을 직접 판정 (1×1 이미지 왕복 없이)
    func start(pickedColor: UIColor,
               targetColor: Color,
               isLastMission: Bool = false,
               onPassed: @escaping () -> Void,
               onFailed: @escaping () -> Void) {
        run(isLastMission: isLastMission, onPassed: onPassed, onFailed: onFailed) {
            MissionEvaluator.evaluate(pickedColor: pickedColor, targetColor: targetColor)
        }
    }

    // 판정 연출(1.5초 judging → 결과 → 1.5초 후 콜백) 공통 처리
    private func run(isLastMission: Bool,
                     onPassed: @escaping () -> Void,
                     onFailed: @escaping () -> Void,
                     evaluate: @escaping () -> Bool) {
        state = .judging

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let isPassed = evaluate()
            withAnimation {
                // 마지막 미션이면 completeSuccess, 아니면 success
                self.state = isPassed ? (isLastMission ? .completeSuccess : .success) : .failure
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if isPassed {
                    onPassed()
                } else {
                    withAnimation { self.state = .idle }
                    onFailed()
                }
            }
        }
    }

    func reset() {
        state = .idle
    }
}
