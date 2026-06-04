//
//  MissionSelectView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct Mission: Identifiable, Codable {
    let id: UUID
    let title: String
    let icon: String
    var completedImageData: Data? = nil

    var isCompleted: Bool { completedImageData != nil }

    var completedImage: UIImage? {
        get { completedImageData.flatMap { UIImage(data: $0) } }
        set { completedImageData = newValue?.jpegData(compressionQuality: 0.8) }
    }

    // 일반 생성용
    init(title: String, icon: String) {
        self.id = UUID()
        self.title = title
        self.icon = icon
    }

    // Codable 디코딩용
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try container.decode(UUID.self,   forKey: .id)
        title              = try container.decode(String.self, forKey: .title)
        icon               = try container.decode(String.self, forKey: .icon)
        completedImageData = try container.decodeIfPresent(Data.self, forKey: .completedImageData)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, icon, completedImageData
    }
}
