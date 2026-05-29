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
        RoundedRectangle(cornerRadius: 12).fill(color).frame(height: height)
    }
}
