//
//  ViewController+Occlusions.swift
//  PathVisualiser
//
//  Created by Max Cobb on 12/12/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import ARKit

extension ViewController {
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical, let geom = ARSCNPlaneGeometry(device: MTLCreateSystemDefaultDevice()!) {
			geom.update(from: planeAnchor.geometry)
			geom.firstMaterial?.colorBufferWriteMask = .alpha
			node.geometry = geom
		}
	}

	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical, let geom = node.geometry as? ARSCNPlaneGeometry {
			geom.update(from: planeAnchor.geometry)
		}
	}
}
