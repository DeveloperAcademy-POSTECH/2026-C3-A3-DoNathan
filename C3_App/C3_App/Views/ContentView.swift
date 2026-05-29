//
//  ContentView.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var missionType: MissionType? = nil

    var body: some View {
        
        //CommonCameraView(missionType: $missionType)
        MissionRootView()

    }
}

#Preview {
    ContentView()
}
