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
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Text("오늘 도전할 미션을 선택하세요!")
                        .font(.headline).bold()
                        .foregroundStyle(vm.mainColor)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                    GeometryReader { geo in
                        let cellW = (geo.size.width - 40 - 4) / 3
                        let cellH = cellW * 3 / 2 // 4/3

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

                    // 진행도 바
                    VStack(spacing: 8) {
                        HStack {
                            Text("진행도")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vm.completedCount)")
                                .font(.system(size: 13, weight: .semibold))
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
                .navigationBarHidden(true)
            }
            .fullScreenCover(item: $vm.activeDestination) { destination in
                switch destination {
                case .basic:
                    CommonCameraView(viewModel: viewModel,
                                     vm: vm,
                                     destination: destination,
                                     onDismiss: { vm.activeDestination = nil },
                                     cameraOverlay: { EmptyView() }
                    ) {
                        EmptyView()
                    }
                case .brightness:
                    BrightnessView(vm: vm)   // 명도 조절 전용 카메라 뷰 연결
                case .saturation:
                    CommonCameraView(viewModel: viewModel,
                                     vm: vm,
                                     destination: destination,
                                     onDismiss: { vm.activeDestination = nil },
                                     cameraOverlay: { EmptyView() }
                    ) {
                        EmptyView()
                    }
                case .crop:
                    CommonCameraView(viewModel: viewModel,
                                     vm: vm,
                                     destination: destination,
                                     onDismiss: { vm.activeDestination = nil },
                                     cameraOverlay: { EmptyView() }
                    ) {
                        EmptyView()
                    }
                case .colorPicker:
                    CommonCameraView(viewModel: viewModel,
                                     vm: vm,
                                     destination: destination,
                                     onDismiss: { vm.activeDestination = nil },
                                     cameraOverlay: { EmptyView() }
                    ) {
                        EmptyView()
                    }
                }
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
