//
//  ShutterButton.swift
//  TestBingoSeparate
//  Created by 이윤진 on 5/29/26.

// 카메라 셔터 버튼 컴포넌트
import SwiftUI

struct ShutterButton: View {
    let mainColor: Color
    let action:    () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.white).frame(width: 72, height: 72)
                Circle().stroke(mainColor, lineWidth: 4).frame(width: 84, height: 84)
            }
        }
    }
}
