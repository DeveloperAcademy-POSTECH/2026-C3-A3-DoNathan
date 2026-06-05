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

    var isJudging: Bool  { state == .judging }
    var showSuccess: Bool { state == .success }
    var showFail: Bool   { state == .failure }
    var isDisabled: Bool  { state != .idle }

    func start(image: UIImage,
               type: MissionType,
               targetColor: Color,
               onPassed: @escaping () -> Void,
               onFailed: @escaping () -> Void) {
        state = .judging

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let isPassed = MissionEvaluator.evaluate(image: image,
                                                     type: type,
                                                     targetColor: targetColor)
            withAnimation {
                self.state = isPassed ? .success : .failure
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

    // MARK: - 임시 오버로드 (CropView·ColorPickerView 팀원 작업 완료 전까지 유지)
    // 팀원 파일 준비되면 위 start(image:type:targetColor:...) 로 교체 후 이 함수 삭제
    func start(onPassed: @escaping () -> Void, onFailed: @escaping () -> Void) {
        state = .judging

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let isPassed = Bool.random()

            withAnimation {
                self.state = isPassed ? .success : .failure
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
