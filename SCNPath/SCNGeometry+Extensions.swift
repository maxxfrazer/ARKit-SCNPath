//
//  SCNGeometry+Extensions.swift
//  SCNPath
//
//  Created by Max Cobb on 12/10/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit
import os

private func addTriangleIndices(indices: inout [UInt32], at index: UInt32) {
	indices.append(contentsOf: [
		index - 2, index - 1, index,
		index, index - 1, index + 1
	])
}

private func addTriangleStripIndices(indices: inout [UInt32], at index: UInt32) {
	indices.append(contentsOf: [index, index + 1])
}

private func distancesBetweenValues(of arr: [SCNVector3]) -> ([CGFloat], CGFloat) {
	var totalDistance: CGFloat = 0
	let myarr = Array(0...Int(arr.count / 2 - 1))
	let vals = myarr.map { (val) -> CGFloat in
		if val == 0 {
			return 0
		}
		let count = val * 2 + 1
		let lCenter = (arr[count] + arr[count - 1]) / 2
		let llCenter = (arr[count - 2] + arr[count - 3]) / 2
		let newDistance = lCenter.distance(vector: llCenter)
		totalDistance += CGFloat(newDistance)
		return totalDistance
	}
	return (vals, totalDistance)
}

private func newTurning(points: [SCNVector3]) -> Float {
	guard points.count == 3 else {
		return 0
	}
	let vec1 = points[1] - points[0]
	let vec2 = points[2] - points[1]
	return atan2(vec1.x * vec2.z - vec1.z * vec2.x, vec1.x * vec2.x + vec1.z * vec2.z)
}

private extension SCNVector3 {
	/// As I'm assuming the path is mostly flat for now, needed this to make the rotations easier
	///
	/// - Returns: the same vector with the y value set to 0
	func flattened() -> SCNVector3 {
		return SCNVector3(self.x, 0, self.z)
	}

}

public extension SCNGeometry {

	private static var defaultSCNPathMaterial: SCNMaterial {
		let mat = SCNMaterial()
		mat.diffuse.contents = UIColor.blue
		return mat
	}
	/// Create your path (triangle strip) from a series of `SCNVector3` points
	///
	/// This path is assumed all normals facing directly up
	/// in the positive Y axis for now.
	///
	/// - Parameters:
	///   - path: Point from which to make the path.
	///   - width: Width of your path (default 0.5).
	///   - curvePoints: Number of points to make the curve at any turn in the path,
	///       default to 8. 0 will make sharp corners.
	///   - materials: Materials to be used on the geometry. Only the first will be read.
	/// - Returns: A new SCNGeometry representing the path for use with any SceneKit Application.
	public class func path(
		path: [SCNVector3], width: Float = 0.5,
		curvePoints: Float = 8, materials: [SCNMaterial] = [],
		curveDistance: Float = 1.5
	) -> (SCNGeometry?, CGFloat) {
		if path.count < 2 {
			return (nil, 0)
		}
		var materials = materials
		if materials.isEmpty {
			materials.append(SCNGeometry.defaultSCNPathMaterial)
		}
		let verts = path
		if curveDistance < 1 {
			os_log(.error, "curve distance is too low, minimum value is 1")
		}
		let curveDistance = max(curveDistance, 1)
		var vertices: [SCNVector3] = []
		var indices: [UInt32] = []
		var texutreCoords: [CGPoint] = []
		let maxIndex = path.count - 1
		var directionV = SCNVector3Zero
		//		var addToPoint: SCNVector3
		var angleBent: Float?
		for (index, vert) in path.enumerated() {
			if index == 0 {
				// first point
				directionV = SCNVector3(verts[index + 1].z - vert.z, 0, verts[index + 1].x - vert.x)
			} else if index < maxIndex {
				let toThis = (vert - verts[index - 1]).flattened().normalized()
				let fromThis = (verts[index + 1] - vert).flattened().normalized()
				angleBent = fromThis.angleChange(to: toThis)
				let resultant = (toThis + fromThis) / 2
				directionV = SCNVector3(resultant.z, 0, resultant.x)
			} else {
				// last point
				directionV = SCNVector3(vert.z - verts[index - 1].z, 0, vert.x - verts[index - 1].x)
			}
			let addToPoint = directionV.normalized() * (width / 2)
			if curvePoints > 0, path.count >= index + 2, var bentBy = angleBent {
				let curvePoints = curvePoints
				let edge1 = SCNVector3(vert.x - addToPoint.x, vert.y, vert.z + addToPoint.z)
				let edge2 = SCNVector3(vert.x + addToPoint.x, vert.y, vert.z - addToPoint.z)
				var bendAround: SCNVector3!

				if newTurning(points: Array(verts[(index-1)...(index+1)])) < 0 { // left turn
					bendAround = SCNVector3(vert.x + addToPoint.x * curveDistance, vert.y, vert.z - addToPoint.z * curveDistance)
					bentBy *= -1
				} else { // right turn
					bendAround = SCNVector3(vert.x - addToPoint.x * curveDistance, vert.y, vert.z + addToPoint.z * curveDistance)
				}
				for val in 0...Int(curvePoints) {
					vertices.append(
						edge2.rotate(about: bendAround, by: (-0.5 + Float(val) / curvePoints) * bentBy)
					)
					vertices.append(
						edge1.rotate(about: bendAround, by: (-0.5 + Float(val) / curvePoints) * bentBy)
					)
					addTriangleIndices(indices: &indices, at: UInt32(vertices.count - 2))
				}
			} else {
				vertices.append(SCNVector3(vert.x + addToPoint.x, vert.y, vert.z - addToPoint.z))
				vertices.append(SCNVector3(vert.x - addToPoint.x, vert.y, vert.z + addToPoint.z))
				if index > 0 {
					addTriangleIndices(indices: &indices, at: UInt32(vertices.count - 2))
				}
			}
		}
		let (arr, pathLength) = distancesBetweenValues(of: vertices)

		for val in arr {
			texutreCoords.append(CGPoint(x: 0, y: val / pathLength))
			texutreCoords.append(CGPoint(x: 1, y: val / pathLength))
		}

		let src = SCNGeometrySource(vertices: vertices)
		let textureMap = SCNGeometrySource(textureCoordinates: texutreCoords)

		// assuming the path is just flat for now, even though it can be angled
		let norm = SCNGeometrySource(normals: [SCNVector3](
			repeating: SCNVector3(0, 1, 0),
			count: vertices.count
		))

		// using triangles instead of triangleStrip for better normals
		let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
		let geo = SCNGeometry(sources: [src, norm, textureMap], elements: [element])
		geo.materials = materials
		return (geo, pathLength)
	}
}
