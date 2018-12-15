//
//  SCNPathNode.swift
//  SCNPath
//
//  Created by Max Cobb on 12/10/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit

/// Subclass of SCNNode, when created holds a geometry representing the path.
public class SCNPathNode: SCNNode {
	public var path: [SCNVector3] {
		didSet {
			self.recalcGeometry()
		}
	}
	public private(set) var pathLength: CGFloat = 0
	public var width: Float {
		didSet {
			if self.geometry != nil {
				self.recalcGeometry()
			}
		}
	}
	private var textureRepeating: Float = 0
	public var curvePoints: Float {
		didSet {
			if self.geometry != nil {
				self.recalcGeometry()
			}
		}
	}
	public var materials: [SCNMaterial] {
		didSet {
			if let geom = self.geometry {
				let img = self.materials.first?.diffuse.contents
				geom.materials = materials
			}
		}
	}

	/// Create the SCNPathNode with the geometry and materials applied.
	///
	/// - Parameters:
	///   - path: Point from which to make the path.
	///   - width: Width of your path (default 0.5).
	///   - curvePoints: Number of points to make the curve at any turn in the path,
	///       default to 8. 0 will make sharp corners.
	///   - materials: Materials to be used on the geometry. Only the first will be read.
	public init(
		path: [SCNVector3], width: Float = 0.5,
		curvePoints: Float = 8, materials: [SCNMaterial] = []
	) {
		self.path = path
		self.width = width
		self.curvePoints = curvePoints
		self.materials = materials
		super.init()
		self.recalcGeometry()
	}

	/// If the texture is a seamless repeating image use this to say how tall the image should
	/// be if the width = 1.
	///
	/// - Parameter meters: meters tall the image would be if the width = 1m.
	public var textureRepeats = false {
		didSet {
			if textureRepeats != oldValue {
				if textureRepeats {
					self.recalcTextureScale()
				} else {
					self.resetTextureScale()
				}
			}
		}
	}

	private func resetTextureScale() {
		let contentsTransform = SCNMatrix4Scale(SCNMatrix4Identity, 1, 1, 1)
		self.materials.first?.diffuse.contentsTransform = contentsTransform
	}

	private func recalcTextureScale() {
		if let contents = self.materials.first?.diffuse.contents,
		let img = contents as? UIImage {
			let contentsTransform = SCNMatrix4Scale(
				SCNMatrix4Identity,
				1, Float(self.pathLength / (CGFloat(self.width) * img.size.width / img.size.height)), 1)
			self.materials.first?.diffuse.wrapT = .repeat
			self.materials.first?.diffuse.contentsTransform = contentsTransform
		} else {
			self.textureRepeats = false
		}
	}

	private func recalcGeometry() {
		let (geom, length) = SCNGeometry.path(
			path: path, width: self.width,
			curvePoints: curvePoints, materials: self.materials
		)
		self.geometry = geom
		self.pathLength = length
		if self.textureRepeats {
			self.recalcTextureScale()
		} else {
			self.resetTextureScale()
		}
	}

	private override init() {
		self.path = []
		self.width = 0.5
		self.curvePoints = 8
		self.materials = []
		super.init()
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
