//
//  MissionColor.swift
//  C3_App
//
//  Created by 최정원 on 6/1/26.
//

import SwiftUI

struct MissionColor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
    let hexCode: String
    let imageName: String
    let isUnlocked: Bool // 필터 언락 여부?
    
    init(name: String, assetName: String, hexCode: String, imageName: String, isUnlocked: Bool) {
            self.name = name
            self.color = Color(assetName)  
            self.hexCode = hexCode
            self.imageName = imageName
            self.isUnlocked = isUnlocked
        }
}

extension MissionColor {
    static let all: [MissionColor] = [
        MissionColor(name: "Red",    assetName: "CustomRed",    hexCode: "#940017", imageName: "mission_red",    isUnlocked: true),
        MissionColor(name: "Orange", assetName: "CustomOrange", hexCode: "#FF8401", imageName: "mission_orange", isUnlocked: false),
        MissionColor(name: "Green",  assetName: "CustomGreen",  hexCode: "#4B911C", imageName: "mission_green",  isUnlocked: false),
        MissionColor(name: "Blue",   assetName: "CustomBlue",   hexCode: "#0CA2CF", imageName: "mission_blue",   isUnlocked: true),
        MissionColor(name: "Purple", assetName: "CustomPurple", hexCode: "#6A0AD8", imageName: "mission_purple", isUnlocked: false),
    ]
}
