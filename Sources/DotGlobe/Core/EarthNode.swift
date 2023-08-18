//
//  EarthNode.swift
//  
//
//  Created by GrandSir on 25.05.2023.
//

import Foundation
import SceneKit
import SwiftUI

public class EarthNode: SCNNode {
    public init(radius: CGFloat, earthColor: Color, earthGlow: Color, earthReflection: Color) {
        super.init()
        self.geometry = SCNSphere(radius: radius)
        self.geometry?.firstMaterial?.diffuse.contents = GenericColor(earthColor)
        self.geometry?.firstMaterial?.emission.contents = GenericColor(earthGlow)
        self.geometry?.firstMaterial?.emission.intensity = 0.1
        self.geometry?.firstMaterial?.shininess = 0.7
        self.geometry?.firstMaterial?.reflective.contents = GenericColor(earthReflection)
        self.geometry?.firstMaterial?.reflective.intensity = 1.0
        self.filters = addBloom()
        
        setupLight()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setupLight() {
        self.castsShadow = true
        let lightNode = SCNNode()
        
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 9, z: 1)

        self.addChildNode(lightNode)
    }
    
    
    func addBloom() -> [CIFilter]? {
        let bloomFilter = CIFilter(name:"CIBloom")!
        bloomFilter.setValue(5.0, forKey: "inputIntensity")
        bloomFilter.setValue(10.0, forKey: "inputRadius")
        return [bloomFilter]
    }

}
