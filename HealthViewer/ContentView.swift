//
//  ContentView.swift
//  HealthViewer
//
//  Created by Isaac on 03/08/2025.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var healthManager = HealthManager()

    var body: some View {
        ZStack {
            ARViewContainer(healthManager: healthManager)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            healthManager.requestAuthorization()
        }
    }
}
