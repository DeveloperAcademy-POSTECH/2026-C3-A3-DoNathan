////
////  BrightnessView.swift
////  TestCamera
////
////  Created by 최정원 on 5/28/26.
////
//
//import SwiftUI
//
//// 현재 사용하지 않는 코드
//
//// 📁 Views/BrightnessView.swift
//import SwiftUI
//
//struct BrightnessView: View {
//    @ObservedObject var viewModel: CameraViewModel
//    
//    var body: some View {
//        VStack {
//            Spacer() // 💡 중요: 슬라이더를 화면 맨 아래로 밀어내는 역할!
//            
//            HStack(spacing: 15) {
//                Image(systemName: "sun.max.fill")
//                    .foregroundColor(.yellow)
//                    .font(.title2)
//                
////                Slider(value: $viewModel.brightness, in: -0.5...0.5)
////                    .accentColor(.yellow)
//            }
//            .padding()
//            // 💡 카메라 화면 위에서 잘 보이도록 반투명한 검은색 배경을 깝니다.
//            .background(Color.black.opacity(0.7))
//            .cornerRadius(15)
//            .padding(.horizontal, 24) // 좌우 여백
//            .padding(.bottom, 40)       // 아이폰 하단 홈 바(Safe Area) 위로 띄우기
//        }
//        // 🌟 이 View 자체가 ZStack 안에서 전체 영역을 차지할 수 있도록 가이드라인을 줍니다.
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//#Preview {
//    BrightnessView(viewModel: .init())
//}
