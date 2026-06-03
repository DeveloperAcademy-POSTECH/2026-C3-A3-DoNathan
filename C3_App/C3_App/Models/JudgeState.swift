//
//  JudgeState.swift
//  C3_App
//
//  Created by 최정원 on 6/3/26.
//

import Foundation

// 미션 판정 상태값
enum JudgeState: Equatable {
    case idle
    case judging
    case success
    case failure
}
