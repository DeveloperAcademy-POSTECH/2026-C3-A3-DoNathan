//
//  MissionSelectView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

// Identifiable: 각 미션이 고유한 id를 가짐
// Codable: 데이터를 저장하고 불러올 수 있게 함
struct Mission: Identifiable, Codable {
    let id: UUID // 각 미션의 고유 식별자
    let title: String
    let icon: String
    let missionDescription: String
    var completedImageData: Data? = nil // 완료 사진 데이터 (없으면 nil)

    //이미지 데이터가 있으면 완료, 없으면 미완료
    var isCompleted: Bool { completedImageData != nil }

    var completedImage: UIImage? {
        get { completedImageData.flatMap { UIImage(data: $0) } }
        set { completedImageData = newValue?.jpegData(compressionQuality: 0.8) }
    }

    // 일반 생성자
    init(title: String, icon: String, missionDescription: String) {
        self.id = UUID() // 고유 id 자동 생성
        self.title = title
        self.icon = icon
        self.missionDescription = missionDescription
    }

    // Codable 디코딩 생성자
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try container.decode(UUID.self,   forKey: .id)
        title              = try container.decode(String.self, forKey: .title)
        icon               = try container.decode(String.self, forKey: .icon)
        missionDescription = try container.decode(String.self, forKey: .missionDescription)
        completedImageData = try container.decodeIfPresent(Data.self, forKey: .completedImageData)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, icon, missionDescription, completedImageData
    }
}
