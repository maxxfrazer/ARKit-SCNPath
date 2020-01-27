//
//  ViewController.swift
//  PathVisualiser
//
//  Created by Max Cobb on 12/9/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import ARKit
import FocusNode
//import SCNPath
import SmartHitTest

extension ARSCNView: ARSmartHitTest {}

class ViewController: UIViewController {

	var sceneView = ARSCNView(frame: .zero)

	let focusSquare = FocusSquare()

	var hitPoints = [SCNVector3]() {
		didSet {
			self.pathNode.path = self.hitPoints
		}
	}

	var pathNode = SCNPathNode(path: [])

	override func viewDidLoad() {
		super.viewDidLoad()

		self.sceneView.frame = self.view.bounds
		self.sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		self.view.addSubview(sceneView)

		// Set the view's delegate
		self.sceneView.delegate = self

		self.focusSquare.viewDelegate = self.sceneView
		self.sceneView.scene.rootNode.addChildNode(self.focusSquare)

		// the next chunk of lines are just things I've added to make the path look nicer
		let pathMat = SCNMaterial()
		self.pathNode.materials = [pathMat]
		self.pathNode.position.y += 0.05
		if Int.random(in: 0...1) == 0 {
			pathMat.diffuse.contents = UIImage(named: "path_seamless")
			self.pathNode.textureRepeats = true
		} else {
			pathMat.diffuse.contents = UIImage(named: "path_with_fade")
		}
		self.pathNode.width = 0.5

		self.sceneView.scene.rootNode.addChildNode(self.pathNode)
		self.setupGestures()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = [.horizontal, .vertical]

		sceneView.session.run(configuration)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneView.session.pause()
	}
}
