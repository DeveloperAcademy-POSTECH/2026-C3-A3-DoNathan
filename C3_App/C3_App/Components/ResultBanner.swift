//
//  ResultBanner.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct ResultBanner: View {
    let text:  String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 28).padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.85)))
            .lineLimit(2)
            .lineSpacing(12)
            .multilineTextAlignment(.center)
            .padding(.bottom, 12)
    }
}

#Preview {
    ResultBanner(text: "지금은 너무 밝아요 😓\n💡Tip : 명도를 조금만 더 내려보세요!", color: .gray)
}
