//
//  RKViewController+Gestures.swift
//  PathVisualiser
//
//  Created by Grant Jarvis on 03/13/21.
//  Copyright © 2021 Grant Jarvis. All rights reserved.
//


import RealityKit
import SceneKit


extension RKViewController: UIGestureRecognizerDelegate {
	func setupGestures() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tapGesture.delegate = self
		self.view.addGestureRecognizer(tapGesture)
	}

	@IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
		guard gestureRecognizer.state == .ended else {
			return
		}
		if self.focusEntity.state != .initializing,
           self.focusEntity.onPlane {
            
            self.hitPoints.append(self.focusEntity.position(relativeTo: nil).makeSCNVector3())
		}
	}
}



extension simd_float3 {
    func makeSCNVector3() -> SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }
    
    
}
