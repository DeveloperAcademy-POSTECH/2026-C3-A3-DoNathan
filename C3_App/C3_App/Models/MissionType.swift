//
//  MissionType.swift
//  TestCameraAndCrop
//
//  Created by 최정원 on 5/28/26.
//

enum MissionType: Identifiable {
    case basic // 기본 카메라
    case brightness // 명도
    case saturation // 채도
    case crop // 크롭
    case colorPicker // 컬러피커
    case filter // 필터 카메라
    
    var id: String {
        switch self {
        case .basic:
            return "basic"
        case .brightness:
            return "brightness"
        case .saturation:
            return "saturation"
        case .crop:
            return "crop"
        case .colorPicker:
            return "colorPicker"
        case .filter:
            return "filter"
        }
    }
}
