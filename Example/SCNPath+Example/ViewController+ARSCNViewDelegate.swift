//
//  ViewController+ARSCNViewDelegate.swift
//  PathVisualiser
//
//  Created by Max Cobb on 12/9/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		DispatchQueue.main.async {
			self.focusSquare.updateFocusNode()
		}
	}
}
