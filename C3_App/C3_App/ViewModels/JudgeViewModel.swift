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
    
    var isJudging: Bool { state == .judging }
    var showSuccess: Bool { state == .success }
    var showFail: Bool { state == .failure }
    var isDisabled: Bool { state != .idle }
    
    func start(onPassed: @escaping () -> Void, onFailed: @escaping () -> Void) {
        state = .judging
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let isPassed = Bool.random()  // ✅ 나중에 MissionEvaluator로 교체
            
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
