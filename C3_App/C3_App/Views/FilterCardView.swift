//
//  MissionCardView.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

struct FilterCardView: View {
    let missionColor: MissionColor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Image(missionColor.imageName)
            .resizable()
            .scaledToFill()
            .clipped() 
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(missionColor.color)
                        .frame(width: 80, height: 80)
                    Text(missionColor.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(missionColor.color)
                    Text(missionColor.hexCode)
                        .font(.system(size: 9))
                        .foregroundColor(missionColor.color)
                }
                .padding(10)
                .background(Color.white)
                .padding(.top, 80)
                .padding(.trailing, 60)
            }
            .overlay(alignment: .bottomLeading) {
                Text(missionColor.name)
                    .font(Font.custom("Inria Serif", size: 32).weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 48)
                    .padding(.bottom, 40)
            }
            .onTapGesture {
                guard missionColor.isUnlocked else { return }
                onTap()
            }
    }
}

#Preview {
    FilterCardView(missionColor: MissionColor(name: "Red", assetName: "CustomRed", hexCode: "#940017", imageName: "mission_red", isUnlocked: true), isSelected: true, onTap: {})
}
