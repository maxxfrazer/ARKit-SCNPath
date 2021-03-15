//
//  RKViewController+Occlusion.swift
//  PathVisualiser
//
//  Created by Grant Jarvis on 03/13/21.
//  Copyright © 2021 Grant Jarvis. All rights reserved.
//

import ARKit
import RealityKit

extension RKViewController: ARSessionDelegate {
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if let planeAnchor = anchors.first as? ARPlaneAnchor,
           planeAnchor.alignment == .vertical{
            
            //To make the mesh more precise, we could create an SCNScene from this geometry, save it to disk - converting it to usdz
            //and then load it as a RealityKit entity and assign it an occlusion material.
            
            //using generatedPlane didn't work.
            //let mesh = MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.y)
            let mesh = MeshResource.generateBox(size: [planeAnchor.extent.x,
                                                       planeAnchor.extent.y,
                                                       planeAnchor.extent.z])
            let occlusionPlane = ModelEntity(mesh: mesh,
                                             materials: [OcclusionMaterial()])
            let planeAnchor = AnchorEntity(anchor: planeAnchor)
            arView.scene.addAnchor(planeAnchor)
            planeAnchor.addChild(occlusionPlane)
            print("ADDED VERTICAL PLANE")
        }
    }
    
    
    func runLiDARConfiguration(){
        if #available(iOS 13.4, *) {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.sceneReconstruction = .mesh
            self.arView.session.run(configuration)
            
            //Allows objects to be occluded by the sceneMesh.
            self.arView.environment.sceneUnderstanding.options.insert(.occlusion)
            
            //show colored mesh.
            //self.arView.debugOptions.insert(.showSceneUnderstanding)
        }

    }
}
