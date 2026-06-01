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
            .background(Capsule().fill(color.opacity(0.85)))
            .padding(.bottom, 12)
    }
}
