//
//  MissionCell.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct MissionCell: View {
    let mission:    Mission
    let isSelected: Bool
    let mainColor:  Color
    let cellHeight: CGFloat
    let onDelete:   () -> Void
    let onTap:      () -> Void

    @State private var showDeleteButton = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(cellBg)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 2))

            if let img = mission.completedImage {
                GeometryReader { geo in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: cellHeight)
                        .clipped()
                }
                .frame(height: cellHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 삭제 버튼 오버레이
                if showDeleteButton {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.4))

                    Button {
                        onDelete()
                        showDeleteButton = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }

            } else {
                VStack(spacing: 8) {
                    Image(systemName: mission.icon)
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(isSelected ? mainColor : Color(.systemGray2))
                    Text(mission.title)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? mainColor : Color(.systemGray))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: cellHeight)
        .scaleEffect(isSelected ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onTapGesture {
            if mission.isCompleted {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDeleteButton.toggle()
                }
            } else {
                onTap()
            }
        }
    }

    private var cellBg: Color {
        mission.isCompleted ? Color(.systemGray6) : (isSelected ? mainColor.opacity(0.15) : Color(.systemGray6))
    }
    private var borderColor: Color {
        mission.isCompleted ? mainColor.opacity(0.5) : (isSelected ? mainColor : Color.clear)
    }
}

#Preview {
    MissionCell(
        mission: Mission(title: "기본 카메라", icon: "camera"),
        isSelected: false,
        mainColor: .pink,
        cellHeight: 150,
        onDelete: {},
        onTap: {}
    )
    .frame(width: 120)
}
