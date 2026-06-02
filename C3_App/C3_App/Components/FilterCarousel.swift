//
//  FilterCarousel.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

struct FilterCarousel: View {
    let colors: [MissionColor]
    let selectedColor: MissionColor?
    let onSelect: (MissionColor) -> Void
    
    let height: CGFloat

    var body: some View {
        HStack(spacing: 8) {
            ForEach(colors) { color in
                let isSelected = selectedColor?.id == color.id
                
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(color.color)
                            .padding(.horizontal, 8)
                            .padding(.top, 10)

                        HStack {
                            Text(color.name)
                                .font(.system(size: height * 0.12, weight: .bold))
                                .foregroundColor(color.color)
                                .lineLimit(2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                    }
                }
                .frame(height: height)
                .onTapGesture { onSelect(color) }
            }
        }
    }
}
