//
//  SaveShareButton.swift
//  TestBingoSeparate
//  Created by 이윤진 on 5/29/26.

// 저장/공유 버튼 컴포넌트
import SwiftUI

struct SaveShareButton: View {
    let icon: String
    let label: String // 버튼 아래 텍스트
    let action: () -> Void // 버튼 눌렸을 때 실행할 함수 (콜백)
    var body: some View {
        // 버튼 탭하면 외부에서 받은 action 콜백 실행
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().stroke(Color(.systemGray3), lineWidth: 1.5).frame(width: 56, height: 56)
                    Image(systemName: icon).font(.system(size: 22, weight: .light)).foregroundColor(.primary)
                }
                Text(label).font(.system(size: 12)).foregroundColor(.primary)
            }
        }
    }
}
