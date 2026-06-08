//
//  MissionSelectView.swift
//  TestBingoSeparate
//
//  Created by 이윤진 on 5/29/26.
//

import SwiftUI

struct MissionSelectView: View {
    @ObservedObject var vm: MissionViewModel
    @StateObject private var viewModel = CameraViewModel()
    @State private var missionType: MissionType? = nil
    @State private var showMissionSuccess: Bool = false
    
    var onDismiss: (() -> Void)?
    var onMissionSuccess: (() -> Void)? = nil
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 6) {
                        HStack {
                            Button {
                                onDismiss?()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Circle().fill(Color.white.opacity(0.7)))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        Text("도전할 미션을 선택하세요!")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 23)

                        Text("Media & Camera 기능을 활용해\n미션 컬러를 찾아 빙고를 완성하세요.")
                            .font(.system(size: 15))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 23)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .background(vm.mainColor.opacity(0.15))

                    GeometryReader { geo in
                        let cellW = (geo.size.width - 40 - 4) / 3
                        let cellH = cellW * 3 / 2

                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(0..<9) { gridIndex in
                                if gridIndex == 4 {
                                    CenterColorCell(color: vm.mainColor, height: cellH)
                                } else {
                                    let mi = gridIndex < 4 ? gridIndex : gridIndex - 1
                                    MissionCell(
                                        mission:    vm.missions[mi],
                                        isSelected: vm.selectedIndex == mi,
                                        mainColor:  vm.mainColor,
                                        cellHeight: cellH,
                                        onDelete: {
                                            vm.missions[mi].completedImage = nil
                                        },
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                vm.selectedIndex = (vm.selectedIndex == mi) ? nil : mi
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .frame(height: cellH * 3 + 4)
                    }
                    .frame(height: gridHeight())
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // 진행도 바
                    VStack(spacing: 8) {
                        HStack {
                            Text("진행도")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vm.completedCount)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(vm.mainColor)
                            Text("/  8")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(vm.mainColor)
                                    .frame(width: geo.size.width * CGFloat(vm.completedCount) / 8, height: 6)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.completedCount)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()

                    Button {
                        if let destination = vm.currentMissionDestination {
                            vm.activeDestination = destination
                        }
                    } label: {
                        Text("미션 시작하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(vm.selectedIndex != nil ? vm.mainColor : Color(.systemGray4))
                            .cornerRadius(25)
                            .animation(.easeInOut(duration: 0.2), value: vm.selectedIndex != nil)
                    }
                    .disabled(vm.selectedIndex == nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .fullScreenCover(item: $vm.activeDestination) { destination in
                switch destination {
                case .filter:
                    EmptyView()
                case .basic:
                    CommonCameraView(viewModel: CameraViewModel(),
                                     vm: vm,
                                     destination: destination,
                                     overlayHeight: 100,
                                     onDismiss: { vm.activeDestination = nil },
                                     onMissionSuccess: {
                                         vm.activeDestination = nil
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                             showMissionSuccess = true
                                         }
                                     },
                                     cameraOverlay: { EmptyView() }
                    ) { EmptyView() }
                case .brightness:
                    BrightnessView(
                        vm: vm,
                        onDismiss: { vm.activeDestination = nil },
                        onMissionSuccess: {
                            vm.activeDestination = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showMissionSuccess = true
                            }
                        }
                    )
                case .saturation:
                    CommonCameraView(viewModel: CameraViewModel(),
                                     vm: vm,
                                     destination: destination,
                                     overlayHeight: 100,
                                     onDismiss: { vm.activeDestination = nil },
                                     onMissionSuccess: {
                                         vm.activeDestination = nil
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                             onMissionSuccess?()
                                         }
                                     },
                                     cameraOverlay: { EmptyView() }
                    ) { EmptyView() }
                case .crop:
                    CommonCameraView(viewModel: CameraViewModel(),
                                     vm: vm,
                                     destination: destination,
                                     overlayHeight: 100,
                                     onDismiss: { vm.activeDestination = nil },
                                     onMissionSuccess: {
                                         vm.activeDestination = nil
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                             onMissionSuccess?()
                                         }
                                     },
                                     cameraOverlay: { EmptyView() }
                    ) { EmptyView() }
                case .colorPicker:
                    CommonCameraView(viewModel: CameraViewModel(),
                                     vm: vm,
                                     destination: destination,
                                     overlayHeight: 100,
                                     onDismiss: { vm.activeDestination = nil },
                                     onMissionSuccess: {
                                         vm.activeDestination = nil
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                             onMissionSuccess?()
                                         }
                                     },
                                     cameraOverlay: { EmptyView() }
                    ) { EmptyView() }
                }
            }
            .fullScreenCover(isPresented: $showMissionSuccess) {
                MissionSuccessView(
                    mainColor: vm.mainColor,
                    onDismiss: {
                        showMissionSuccess = false
                    }
                )
            }
        }
    }

    func gridHeight() -> CGFloat {
        let screenW = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
        let cellW = (screenW - 40 - 4) / 3
        let cellH = cellW * 4 / 3
        return cellH * 3 + 4
    }
}

#Preview {
    MissionSelectView(vm: .init())
}
