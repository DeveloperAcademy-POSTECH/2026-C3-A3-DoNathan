//
//  MissionCell.swift
//  TestBingoSeparate
//  Created by 이윤진 on 5/29/26.

// 미션 완료 전엔 아이콘+텍스트, 완료 후엔 찍은 사진, 탭하면 삭제 버튼
import SwiftUI

struct MissionCell: View {
    let mission:    Mission // 이 셀이 표시할 미션 데이터
    let isSelected: Bool // 현재 선택된 셀인지, 아닌지
    let mainColor:  Color // 앱 메인컬러
    let cellHeight: CGFloat // 셀 높이
    let onDelete:   () -> Void  // 삭제 버튼 눌렀을 때 실행할 함수(콜백)
                                // Int에 숫자 넣듯이 () -> Void에는 함수를 넣음

    @State private var showDeleteButton = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(cellBg)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 2))

            // 미션 완료 이미지가 있으면 이 블록 실행 (Optional Binding - 값이 있으면 꺼내서 쓰고, 없으면 무시)
            if let img = mission.completedImage {
                GeometryReader { geo in //부모 뷰의 크기 정보를 geo로 받아옴. 이미지를 정확한 크기로 맞추기 위해 씀, 기기마다 크기가 다른데 geo 쓰면 항상 칸에 꽉 맞게 이미지 채울 수 있음
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: cellHeight)
                        .clipped() // 셀 밖으로 삐져나온 부분 자르기
                }
                .frame(height: cellHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 삭제 버튼 오버레이: 한 번 클릭하여 삭제 버튼 표시 상태가 되면 이미지 위에 어둡게 배경이 덮힘
                if showDeleteButton {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.4))

                    Button {
                        onDelete()
                        showDeleteButton = false // 버튼 숨기기
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
        .scaleEffect(isSelected ? 0.96 : 1.0) // 선택되었을 때 살짝 작아지게 하는 효과 (눌린 느낌)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onTapGesture {
            if mission.isCompleted {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDeleteButton.toggle() // 탭할 때마다 삭제버튼 토글
                }
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
