//
//  ViewController.swift
//  ARMesuring
//
//  Created by Amol Rai on 18/09/19.
//  Copyright © 2019 Amol Rai. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var startingPosition: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(configuration)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.delegate = self
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let scene = sender.view as? ARSCNView else { return }
        guard let currentFrame = scene.session.currentFrame else { return }
        if startingPosition != nil {
            startingPosition?.removeFromParentNode()
            startingPosition = nil
            return
        }
        let transform = currentFrame.camera.transform
        var fourMatrix = matrix_identity_float4x4
        fourMatrix.columns.3.z = -0.1
        let multiply = simd_mul(transform, fourMatrix)
        
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode.simdTransform = multiply
        startingPosition = sphereNode
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = startingPosition else { return }
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f", xDistance) + "m"
            self.yLabel.text = String(format: "%.2f", yDistance) + "m"
            self.zLabel.text = String(format: "%.2f", zDistance) + "m"
            self.distanceLbl.text = String(format: "%.2f", self.distance(x: xDistance, y: yDistance, z: zDistance)) + "m"
        }
    }
    
    func distance(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(x*x + y*y + z*z))
    }
}
