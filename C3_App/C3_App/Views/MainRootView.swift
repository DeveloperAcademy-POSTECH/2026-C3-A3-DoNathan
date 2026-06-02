//
//  MainRootView.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

struct MainRootView: View {
    @StateObject private var progress = MissionProgress.shared
    @State private var selectedColor: MissionColor = MissionColor.all[0]
    @State private var showMission: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {

                // MARK: - 흰색 배경 (이미지 하단)
                Color.white
                    .frame(width: geo.size.width, height: geo.size.height)

                // MARK: - 이미지 (403×611, 상단 고정)
                Image(selectedColor.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 403, height: 611)
                    .clipped()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .position(x: geo.size.width / 2, y: 611 / 2)

                // MARK: - 하단 그라디언트 오버레이
                LinearGradient(
                    stops: [
                        .init(color: Color.black.opacity(0), location: 0),
                        .init(color: Color.black.opacity(0.6), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: 209)
                .position(x: geo.size.width / 2, y: 611 - 209 / 2)

                // MARK: - 우상단 컬러 정보 카드
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(selectedColor.color)
                        .frame(width: 90, height: 92)
                        .padding(.top, 0)

                    Text(selectedColor.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selectedColor.color)
                        .padding(.top, 4)

                    Text(selectedColor.hexCode)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(selectedColor.color)
                    
                }
                .frame(width: 103, height: 136)
                .background(Color(hex: "FDFCF9"))
                .position(x: 258 + 103 / 2, y: 75 + 136 / 2)

                // MARK: - 컬러 이름 (대형 서체)
                Text(selectedColor.name)
                    .font(Font.custom("InriaSerif-Bold", size: 32))
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                    .padding(.top, 557)



                // MARK: - 컬러 버튼 캐러셀
                FilterCarousel(
                    colors: MissionColor.all,
                    selectedColor: selectedColor,
                    onSelect: { selectedColor = $0 },
                    height: 86,
                    ignoreUnlock: true
                )
                .frame(width: geo.size.width)
                .position(x: geo.size.width / 2, y: 645 + 86 / 2)

                // MARK: - 하단 버튼
                HStack(spacing: 39) {
                    // 뒤로가기 버튼
                    Button {
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "919191"))
                            .frame(width: 48, height: 48)
                    }
                    .glassEffect(.regular.interactive(), in: Circle())

                    // 미션 시작 버튼
                    Button {
                        guard selectedColor.isUnlocked else { return }
                        showMission = true
                    } label: {
                        HStack {
                            if selectedColor.isUnlocked {
                                Text("미션으로 이동하기 →")
                            } else {
                                Image(systemName: "lock.fill")
                                Text("준비중")
                            }
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 274, height: 48)
                        .background(
                            selectedColor.isUnlocked
                            ? selectedColor.color
                            : Color(.systemGray4)
                        )
                        .cornerRadius(1000)
                    }
                    .disabled(!selectedColor.isUnlocked)
                }
                .position(x: 20 + (48 + 39 + 274) / 2, y: 765 + 48 / 2)
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showMission) {
            MissionRootView(
                missionColor: selectedColor,
                onDismiss: { showMission = false }
            )
        }
    }
}

#Preview {
    MainRootView()
}
