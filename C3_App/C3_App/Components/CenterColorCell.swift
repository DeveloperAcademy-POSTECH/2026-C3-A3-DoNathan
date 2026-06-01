//
//  CenterColorCell.swift
//  TestBingoSeparate
//  Created by 이윤진 on 5/29/26.

// 중앙 미션컬러 셀
import SwiftUI

struct CenterColorCell: View {
    let color:  Color
    let height: CGFloat
    
    // 실제 UI가 그려지는 곳
    var body: some View {
        RoundedRectangle(cornerRadius: 12).fill(color).frame(height: height)
    }
}
