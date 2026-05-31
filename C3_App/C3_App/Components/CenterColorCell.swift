//
//  CenterColorCell.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct CenterColorCell: View {
    let color:  Color
    let height: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(color)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)

                HStack {
                    Text("Mission\nColor")
                        .font(.system(size: height * 0.1, weight: .bold))
                        .foregroundColor(color)
                        .lineLimit(2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    Spacer()
                }
            }
        }
        .frame(height: height)
    }
}
