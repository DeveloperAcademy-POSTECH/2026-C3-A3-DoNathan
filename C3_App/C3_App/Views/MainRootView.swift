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
            ZStack(alignment: .bottom) {
                FilterCardView(
                    missionColor: selectedColor,
                    isSelected: true,
                    onTap: { }
                )
                .frame(width: geo.size.width, height: geo.size.height - 160)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // 하단 패널
                VStack(spacing: 16) {
                    ColorPaletteBar(
                        colors: MissionColor.all,
                        selectedColor: selectedColor,
                        onSelect: { selectedColor = $0 }
                    )
                    .padding(.horizontal, 20)

                    HStack(spacing: 12) {
                        Button {
                        } label: {
                            Image(systemName: "camera")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                                .frame(width: 50, height: 50)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }

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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedColor.isUnlocked ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                selectedColor.isUnlocked
                                ? selectedColor.color
                                : Color(.systemGray5)
                            )
                            .cornerRadius(25)
                        }
                        .disabled(!selectedColor.isUnlocked)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .padding(.top, 16)
                .background(Color(.systemGray6))
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showMission) {
            MissionRootView()
        }
    }
}

#Preview {
    MainRootView()
}
