//
//  ContentView.swift
//  TestCamera
//
//  Created by 최정원 on 5/25/26.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var vm: MissionViewModel
    
    var body: some View {
        MainRootView(vm: vm)
    }
}

#Preview {
    ContentView(vm: MissionViewModel())
}
