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

	/// The centre points of the path to be drawn
	public var path: [SCNVector3] {
		// later this will be a little smarter, calculating the diff from the oldValue
		didSet {
			self.recalcGeometry()
		}
	}
	/// The length of the path with the curvature of any turning points
	public private(set) var pathLength: CGFloat = 0

	/// Width of the path in meters
	public var width: Float {
		didSet {
			if self.geometry != nil {
				self.recalcGeometry()
			}
		}
	}

	/// Whenever a curve is met, how many segments are wanted to curve the corner.
	/// This will be a maximum in a later version, so slight bends don't create unecessary vertices.
	public var curvePoints: Float {
		didSet {
			if self.geometry != nil {
				self.recalcGeometry()
			}
		}
	}

	/// An array of SCNMaterial objects that determine the geometry’s appearance when rendered.
	public var materials: [SCNMaterial] {
		didSet {
			if let geom = self.geometry {
				geom.materials = materials
			}
		}
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
		(self.geometry, self.pathLength) = SCNGeometry.path(
			path: path, width: self.width,
			curvePoints: curvePoints, materials: self.materials
		)
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
