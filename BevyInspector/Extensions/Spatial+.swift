//
//  Spatial+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import Spatial
import RealityKit

extension SIMD2 {
	var components: [Scalar] {
		get { [x, y] }
		set { (x, y) = (newValue[0], newValue[1]) }
	}
}

extension SIMD3 {
	var components: [Scalar] {
		get { [x, y, z] }
		set { (x, y, z) = (newValue[0], newValue[1], newValue[2]) }
	}
}

extension simd_quatf {
	var angles: SIMD3<Float> {
		get { Rotation3DFloat(self).eulerAngles(order: .xyz).angles }
		set { self = Rotation3DFloat(eulerAngles: EulerAnglesFloat(angles: newValue, order: .xyz)).quaternion }
	}
}

extension AffineTransform3DFloat {
	var transform: Transform {
		get {
			Transform(
				scale: scale.vector,
				rotation: rotation?.quaternion ?? .init(),
				translation: translation.vector)
		}
		set {
			self = .init(
				scale: Size3DFloat(newValue.scale),
				rotation: Rotation3DFloat(newValue.rotation),
				translation: Vector3DFloat(newValue.translation))
		}
	}
}
