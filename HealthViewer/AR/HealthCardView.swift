//
//  HealthCardView.swift
//  HealthViewer
//
//  Created by Isaac on 03/08/2025.
//

import SwiftUI

struct HealthCardView: View {
    var heartRate: Double
    var steps: Double

    var body: some View {
        VStack(spacing: 12) {
            Text("Health Overview")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Text("\(Int(heartRate)) bpm")
                Spacer()
                Text("\(Int(steps)) steps")
            }
            .foregroundColor(.white)
            .padding(.horizontal)

        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(width: 250)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.2)))
        .shadow(radius: 10)
    }
}
