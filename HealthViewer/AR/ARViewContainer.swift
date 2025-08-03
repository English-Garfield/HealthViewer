import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var healthManager: HealthManager

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.autoenablesDefaultLighting = true

        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)

        // Create SwiftUI view → image → plane
        let hostingController = UIHostingController(rootView:
            HealthCardView(
                heartRate: healthManager.heartRate,
                steps: healthManager.stepCount
            )
        )

        hostingController.view.bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        hostingController.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: hostingController.view.bounds.size)
        let image = renderer.image { ctx in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }

        let material = SCNMaterial()
        material.diffuse.contents = image
        material.isDoubleSided = true

        let plane = SCNPlane(width: 0.2, height: 0.13)
        plane.materials = [material]

        let node = SCNNode(geometry: plane)
        node.position = SCNVector3(0, 0, -0.5) // Half meter in front of camera

        sceneView.scene.rootNode.addChildNode(node)

        context.coordinator.panelNode = node
        context.coordinator.healthManager = healthManager
        context.coordinator.hostingController = hostingController

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Trigger view re-rendering
        context.coordinator.updatePanel()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var panelNode: SCNNode?
        var hostingController: UIHostingController<HealthCardView>?
        var healthManager: HealthManager?

        func updatePanel() {
            guard let node = panelNode,
                  let manager = healthManager else { return }

            let newView = HealthCardView(
                heartRate: manager.heartRate,
                steps: manager.stepCount
            )
            hostingController?.rootView = newView

            guard let view = hostingController?.view else { return }

            let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
            let image = renderer.image { ctx in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }

            let material = SCNMaterial()
            material.diffuse.contents = image
            material.isDoubleSided = true

            if let plane = node.geometry as? SCNPlane {
                plane.materials = [material]
            }
        }
    }
}
