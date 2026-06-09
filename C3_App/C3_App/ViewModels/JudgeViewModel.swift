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
        state = .judging

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let isPassed = MissionEvaluator.evaluate(image: image,
                                                     type: type,
                                                     targetColor: targetColor)
            withAnimation {
                if isPassed {
                    // 마지막 미션이면 completeSuccess, 아니면 success
                    self.state = isLastMission ? .completeSuccess : .success
                } else {
                    self.state = .failure
                }
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
