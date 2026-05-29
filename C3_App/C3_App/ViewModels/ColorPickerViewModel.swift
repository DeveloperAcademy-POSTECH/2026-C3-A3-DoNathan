//
//  ColorPickerViewModel.swift
//  C3_App
//
//  Created by 최정원 on 5/29/26.
//

import SwiftUI
import CoreImage
import Combine

class ColorPickerViewModel: ObservableObject {
    @Published var pickerPosition: CGPoint = .zero   // 화면상 피커 위치
    @Published var selectedColor: Color = .clear     // 선택된 색상 (UI용)
    @Published var selectedUIColor: UIColor = .clear // 선택된 색상 (저장/비교용)
    @Published var isDragging: Bool = false
    
    // MARK: - 이미지에서 특정 좌표의 픽셀 색상 추출
    func pickColor(from image: UIImage, at point: CGPoint, imageFrame: CGRect) {
        // 화면 좌표 → 이미지 픽셀 좌표 변환
        let scaleX = image.size.width / imageFrame.width
        let scaleY = image.size.height / imageFrame.height
        
        let pixelX = (point.x - imageFrame.minX) * scaleX
        let pixelY = (point.y - imageFrame.minY) * scaleY
        
        guard pixelX >= 0, pixelY >= 0,
              pixelX < image.size.width,
              pixelY < image.size.height else { return }
        
        guard let color = image.pixelColor(at: CGPoint(x: pixelX, y: pixelY)) else { return }
        
        DispatchQueue.main.async {
            self.selectedUIColor = color
            self.selectedColor = Color(color)
        }
    }
}
