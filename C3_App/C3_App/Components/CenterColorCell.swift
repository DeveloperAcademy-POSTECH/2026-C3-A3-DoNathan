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
                    .frame(height: height * 0.65) // 👈 65% 비율로 조정
                    .padding(.horizontal, 10)
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Mission")
                        .font(.system(size: height * 0.09, weight: .bold))
                        .foregroundColor(color)
                        .lineLimit(1)
                    
                    Text("Color")
                        .font(.system(size: height * 0.09, weight: .bold))
                        .foregroundColor(color)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                Spacer(minLength: 0)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    CenterColorCell(color: .red, height: 120)
}
