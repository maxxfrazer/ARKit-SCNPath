//
//  SCNVector3+Extensions.swift
//  SCNPath
//
//  Created by Max Cobb on 12/10/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import SceneKit

internal extension SCNVector3 {

	/// Returns the magnitude of the vector
	var length: Float {
		return sqrtf(self.lenSq)
	}

	/// Angle change between two vectors
	///
	/// - Parameter vector: vector to compare
	/// - Returns: angle between the vectors
	func angleChange(to vector: SCNVector3) -> Float {
		let dot = self.normalized().dot(vector: vector.normalized())
		return acos(dot / sqrt(self.lenSq * vector.lenSq))
	}

	/// Returns the squared magnitude of the vector
	var lenSq: Float {
		return x*x + y*y + z*z
	}

	/// Normalizes the SCNVector
	///
	/// - Returns: SCNVector3 of length 1.0
	func normalized() -> SCNVector3 {
		return self / self.length
	}

	/// Sets the magnitude of the vector
	///
	/// - Parameter to: value to set it to
	/// - Returns: A vector pointing in the same direction but set to a fixed magnitude
	func setLength(to vector: Float) -> SCNVector3 {
		return self.normalized() * vector
	}

	/// Scalar distance between two vectors
	///
	/// - Parameter vector: vector to compare
	/// - Returns: Scalar distance
	func distance(vector: SCNVector3) -> Float {
		return (self - vector).length
	}

	/// Dot product of two vectors
	///
	/// - Parameter vector: vector to compare
	/// - Returns: Scalar dot product
	func dot(vector: SCNVector3) -> Float {
		return x * vector.x + y * vector.y + z * vector.z
	}

	/// Given a point and origin, rotate along X/Z plane by radian amount
	///
	/// - parameter origin: Origin for the start point to be rotated about
	/// - parameter by: Value in radians for the point to be rotated by
	///
	/// - returns: New SCNVector3 that has the rotation applied
	func rotate(about origin: SCNVector3, by rotation: Float) -> SCNVector3 {
		let pointRepositionedXY = [self.x - origin.x, self.z - origin.z]
		let sinAngle = sin(rotation)
		let cosAngle = cos(rotation)
		return SCNVector3(
			x: pointRepositionedXY[0] * cosAngle - pointRepositionedXY[1] * sinAngle + origin.x,
			y: self.y,
			z: pointRepositionedXY[0] * sinAngle + pointRepositionedXY[1] * cosAngle + origin.z
		)
	}
}

// SCNVector3 operator functions

internal func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

internal func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

internal func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
	return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

internal func *= (vector: inout SCNVector3, scalar: Float) {
	vector = (vector * scalar)
}

internal func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

internal func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
	return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}
