//
//  FilterCarousel.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

// 캐러셀로 수정 필요
struct ColorPaletteBar: View {
    let colors: [MissionColor]
    let selectedColor: MissionColor?
    let onSelect: (MissionColor) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(colors) { color in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(selectedColor?.id == color.id ? Color.white : Color.clear, lineWidth: 2)
                        )
                    Text(color.name)
                        .font(.system(size: 10))
                        .foregroundColor(selectedColor?.id == color.id ? color.color : .secondary)
                        .fontWeight(selectedColor?.id == color.id ? .bold : .regular)
                }
                .onTapGesture { onSelect(color) }
            }
        }
    }
}
