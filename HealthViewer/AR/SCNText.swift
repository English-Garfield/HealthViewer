//
//  SCNText.swift
//  HealthViewer
//
//  Created by Isaac on 03/08/2025.
//

import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var healthManager: HealthManager

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.autoenablesDefaultLighting = true

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = []
        sceneView.session.run(config)

        // Display metric in AR
        let textNode = createTextNode()
        textNode.position = SCNVector3(0, 0, -0.5) // half meter in front of camera
        sceneView.scene.rootNode.addChildNode(textNode)

        context.coordinator.textNode = textNode
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.updateText(heartRate: healthManager.heartRate,
                                       steps: healthManager.stepCount)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func createTextNode() -> SCNNode {
        let text = SCNText(string: "Loading...", extrusionDepth: 1)
        text.font = .systemFont(ofSize: 10)
        text.firstMaterial?.diffuse.contents = UIColor.systemTeal

        let node = SCNNode(geometry: text)
        node.scale = SCNVector3(0.005, 0.005, 0.005)
        return node
    }

    class Coordinator {
        var textNode: SCNNode?

        func updateText(heartRate: Double, steps: Double) {
            let text = SCNText(string: "❤️ \(Int(heartRate)) bpm\n👣 \(Int(steps)) steps", extrusionDepth: 1)
            text.font = .systemFont(ofSize: 10)
            text.firstMaterial?.diffuse.contents = UIColor.white
            text.flatness = 0.2

            textNode?.geometry = text
        }
    }
}
