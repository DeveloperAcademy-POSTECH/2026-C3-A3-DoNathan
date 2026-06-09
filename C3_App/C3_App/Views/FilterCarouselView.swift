//
//  FilterCarouselView.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

// MARK: - 필터 옵션
enum FilterOption: CaseIterable, Identifiable {
    case none
    case red
    case orange
    case green
    case blue
    case purple

    var id: String { title }

    var title: String {
        switch self {
        case .none:   return "None"
        case .red:    return "Red"
        case .orange: return "Orange"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .purple: return "Purple"
        }
    }

    var isUnlocked: Bool {
        switch self {
        case .none:       return true
        default:          return false
        }
    }

    // 내부 컬러 블록 색상 (Figma 스펙)
    var innerColor: Color {
        switch self {
        case .none:   return Color(hex: "D9D9D9")
        case .red:    return Color(hex: "940017")
        case .orange: return Color(hex: "FF8401")
        case .green:  return Color(hex: "4B911C")
        case .blue:   return Color(hex: "0CA2CF")
        case .purple: return Color(hex: "6A0AD8")
        }
    }

    // 선택 시 테두리·라벨·그림자에 쓰이는 색상
    var selectedColor: Color {
        switch self {
        case .none:   return Color(hex: "3C3C3C")
        case .red:    return Color(hex: "940017")
        case .orange: return Color(hex: "FF8401")
        case .green:  return Color(hex: "4B911C")
        case .blue:   return Color(hex: "0CA2CF")
        case .purple: return Color(hex: "6A0AD8")
        }
    }
}

// MARK: - 필터 캐러셀
struct FilterCarouselView: View {
    @Binding var selectedFilter: FilterOption
    @Binding var filterIntensity: Double
    @ObservedObject private var progress = MissionProgress.shared
    // 데모를 위한 탭 언락 상태, 미션 연결 이후 수정 필요
    //@State private var isBlueUnlocked: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterOption.allCases) { filter in
                    FilterCellView(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        isUnlocked: isUnlocked(filter)
                    )
                    
                    //여기부터
                    .onTapGesture {
//                        if filter == .blue && !isBlueUnlocked {
//                            // 데모를 위한 탭 언락 - 첫 탭은 언락만, 미션 연결 이후 수정 필요
//                            isBlueUnlocked = true
//                        } else if filter.isUnlocked || (filter == .blue && isBlueUnlocked) {
//                            // 언락된 필터 선택
//                            selectedFilter = filter
//                        }
                        if isUnlocked(filter) {
                            selectedFilter = filter
                        }
                    }
                    
                    //여기까지
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
    
    private func isUnlocked(_ filter: FilterOption) -> Bool {
        if filter == .none { return true }
        return MissionProgress.shared.isPassed(colorName: filter.title)
        // filter.title "Red" == missionColor.name "Red" 일치 확인
    }
}

// MARK: - 필터 셀 (Figma 스펙 기반)
struct FilterCellView: View {
    let filter: FilterOption
    let isSelected: Bool
    var isUnlocked: Bool = false

    private let cellWidth: CGFloat  = 64
    private let cellHeight: CGFloat = 86

    // 내부 컬러 블록 스펙 (Figma offset 기준)
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
                            isSelected ? filter.selectedColor : Color(hex: "9A9A9A"),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: isSelected ? filter.selectedColor.opacity(0.3) : Color.clear,
                    radius: 2.5, x: 0, y: 0
                )

            // 내부 컬러 블록
            Rectangle()
                .fill(filter.innerColor)
                .frame(width: innerW, height: innerH)
                .offset(x: innerX, y: innerY)

            // 라벨
            Text(filter.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(
                    isSelected ? filter.selectedColor : Color(hex: "9A9A9A")
                )
                .offset(x: innerX, y: 63.24)

            // 잠금 오버레이
//            let showLock = !filter.isUnlocked && !(filter == .blue && isBlueUnlocked)
            if !isUnlocked {
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

#Preview {
    FilterCarouselView(selectedFilter: .constant(.red), filterIntensity: .constant(1.0))
        .background(Color.white)
        .padding(.vertical)
}
