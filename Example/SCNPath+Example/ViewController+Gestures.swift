//
//  ViewController+Gestures.swift
//  PathVisualiser
//
//  Created by Max Cobb on 12/9/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import UIKit
import SCNPath

extension ViewController: UIGestureRecognizerDelegate {
	func setupGestures() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tapGesture.delegate = self
		self.view.addGestureRecognizer(tapGesture)
	}

	@IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
		guard gestureRecognizer.state == .ended else {
			return
		}
		if self.focusSquare.state != .initializing {
			self.hitPoints.append(self.focusSquare.position)
		}
	}
}
