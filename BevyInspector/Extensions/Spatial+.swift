//
//  Spatial+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import Spatial
import RealityKit

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
