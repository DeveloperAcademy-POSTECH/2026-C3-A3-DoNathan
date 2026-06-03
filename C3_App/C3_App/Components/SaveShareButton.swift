//
//  SaveShareButton.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct SaveShareButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().stroke(Color(.systemGray3), lineWidth: 1.5).frame(width: 56, height: 56)
                    Image(systemName: icon).font(.system(size: 22, weight: .light)).foregroundColor(.primary)
                }
                Text(label).font(.system(size: 12)).foregroundColor(.primary)
            }
        }
    }
}
