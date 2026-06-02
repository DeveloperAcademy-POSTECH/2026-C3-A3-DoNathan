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
    var ignoreUnlock: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colors) { color in
                    let isSelected = selectedColor?.id == color.id
                    FilterCarouselCell(color: color, isSelected: isSelected, ignoreUnlock: ignoreUnlock)
                        .onTapGesture {
                            guard color.isUnlocked || ignoreUnlock else { return }
                            onSelect(color)
                        }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - 필터 셀 (Figma 스펙 기반, MissionColor 데이터)
struct FilterCarouselCell: View {
    let color: MissionColor
    let isSelected: Bool
    var ignoreUnlock: Bool = false

    private let cellWidth: CGFloat  = 64
    private let cellHeight: CGFloat = 86

    private let innerX: CGFloat     = 4.35
    private let innerY: CGFloat     = 3.79
    private let innerW: CGFloat     = 55.92
    private let innerH: CGFloat     = 58.18

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 배경
            Rectangle()
                .fill(Color(hex: "FDFCF9"))
                .overlay(
                    Rectangle()
                        .strokeBorder(
                            isSelected ? color.color : Color(hex: "9A9A9A"),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: isSelected ? color.color.opacity(0.3) : Color.clear,
                    radius: 2.5, x: 0, y: 0
                )

            // 내부 컬러 블록
            Rectangle()
                .fill(color.color)
                .frame(width: innerW, height: innerH)
                .offset(x: innerX, y: innerY)

            // 라벨
            Text(color.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? color.color : Color(hex: "9A9A9A"))
                .offset(x: innerX, y: 63.24)

            // 잠금 오버레이
            if !color.isUnlocked && !ignoreUnlock {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: cellWidth, height: cellHeight)

                Image(systemName: "lock.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: cellWidth, height: cellHeight)
            }
        }
        .frame(width: cellWidth, height: cellHeight)
    }
}
