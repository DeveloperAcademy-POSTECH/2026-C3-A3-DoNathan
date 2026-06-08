//
//  MissionCompleteView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI
import Photos

struct MissionCompleteView: View {
    @ObservedObject var vm: MissionViewModel
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

    @State private var appeared = false
    @State private var showPermissionAlert = false
    @State private var showSaveToast = false

    var cellHeight: CGFloat {
        let screenW = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
        let w = (screenW - 32 - 6) / 3
        return w * 4 / 3
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("미션 완료!")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20).padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : -10)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(0..<9) { gi in
                        if gi == 4 {
                            CenterColorCell(color: vm.mainColor, height: cellHeight)
                        } else {
                            let mi = gi < 4 ? gi : gi - 1
                            if let img = vm.missions[mi].completedImage {
                                Image(uiImage: img).resizable().scaledToFill()
                                    .frame(height: cellHeight).clipped()
                                    .opacity(appeared ? 1 : 0).scaleEffect(appeared ? 1 : 0.85)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(gi) * 0.07), value: appeared)
                            } else {
                                Color(.systemGray5).frame(height: cellHeight)
                            }
                        }
                    }
                }
                .cornerRadius(16).padding(.horizontal, 16)

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("새로운 필터가 잠금 해제되었습니다!")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(vm.mainColor)
                .padding(.vertical, 12).padding(.horizontal, 20)
                .background(vm.mainColor.opacity(0.1)).cornerRadius(20)
                .padding(.bottom, 16)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.75), value: appeared)

                HStack(spacing: 48) {
                    SaveShareButton(icon: "arrow.down.to.line", label: "저장하기") { saveCollage() }
                    SaveShareButton(icon: "square.and.arrow.up",  label: "공유하기") { shareCollage() }
                }
                .padding(.bottom, 36)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.9), value: appeared)
            }
            .navigationTitle("").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { withAnimation { vm.showCompletion = false } } label: {
                        Image(systemName: "chevron.left").foregroundColor(.primary)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showSaveToast {
                    Text("앨범에 저장되었어요!")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color.black.opacity(0.75)).cornerRadius(20)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSaveToast)
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { appeared = true } }
        .alert("갤러리 접근 권한 필요", isPresented: $showPermissionAlert) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("갤러리 저장을 위해 설정에서 사진 접근을 허용해주세요.")
        }
    }

    func saveCollage() {
        guard let img = makeCollageImage() else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                    showSaveToast = true          // ← authorized 안에만 있음
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSaveToast = false
                    }
                case .denied, .restricted:
                    showPermissionAlert = true    // ← 거부하면 알럿만 뜸
                default:
                    break
                }
            }
        }
    }

    func shareCollage() {
            guard let img = makeCollageImage() else { return }
            let av = UIActivityViewController(activityItems: [img], applicationActivities: nil)
            
            if let topVC = getTopViewController() {
                if let popoverController = av.popoverPresentationController {
                    popoverController.sourceView = topVC.view
                    popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                topVC.present(av, animated: true, completion: nil)
            }
        }
    
    // MARK: - 현재 화면에 띄워진 가장 최상위의 뷰 컨트롤러를 찾아주는 함수
    private func getTopViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        var topVC = windowScene?.windows.first { $0.isKeyWindow }?.rootViewController
        
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }

    func makeCollageImage() -> UIImage? {
        let size: CGFloat = 1200
        let cw = size / 3
        let ch = cw * 4 / 3
        let totalH = ch * 3 //+ 6
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: totalH), false, 1)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        for row in 0..<3 {
            for col in 0..<3 {
                let gi   = row * 3 + col
                let rect = CGRect(x: CGFloat(col) * cw,
                                  y: CGFloat(row) * ch,
                                  width: cw, height: ch)
                if gi == 4 {
                    //UIColor(vm.mainColor).setFill(); ctx.fill(rect)
                    let centerView = CenterColorCell(color: vm.mainColor, height: ch)
                            .frame(width: cw, height: ch) // 캔버스 칸 크기에 딱 맞추기
                        
                    if let centerImage = centerView.toImage(size: rect.size) {
                        centerImage.draw(in: rect)
                    } else {
                        UIColor(vm.mainColor).setFill()
                        ctx.fill(rect)
                    }
                } else {
                    let mi = gi < 4 ? gi : gi - 1
                    if let img = vm.missions[mi].completedImage { img.draw(in: rect) }
                    else { UIColor.systemGray5.setFill(); ctx.fill(rect) }
                }
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

// MARK: - SwiftUI View를 UIImage로 구워내는 핵심 익스텐션
extension View {
    func toImage(size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

#Preview {
    MissionCompleteView(vm: MissionViewModel())
}
