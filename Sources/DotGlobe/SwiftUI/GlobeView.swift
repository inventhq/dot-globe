//
//  SwiftUIView.swift
//  
//
//  Created by Demirhan Mehmet Atabey on 25.05.2023.
//

import SwiftUI
import SceneKit

#if os(iOS)
typealias GenericControllerRepresentable = UIViewControllerRepresentable
#else
typealias GenericControllerRepresentable = NSViewControllerRepresentable
#endif

@available(iOS 13.0, *)
private struct GlobeViewControllerRepresentable: GenericControllerRepresentable {
    var dotCount: Int?
    var earthRadius: Double?
    var dotSize: Float?
    var enablesParticles: Bool?
    var particles: SCNParticleSystem?
    var earthColor: Color?
    var glowColor: Color?
    var reflectionColor: Color?
    var glowShininess: CGFloat?
    
    public init(
        dotCount: Int? = nil,
        earthRadius: Double? = nil,
        dotSize: Float? = nil,
        enablesParticles: Bool? = nil,
        particles: SCNParticleSystem? = nil,
        earthColor: Color? = nil,
        glowColor: Color? = nil,
        reflectionColor: Color? = nil,
        glowShininess: CGFloat? = nil
    ) {
        self.dotCount = dotCount
        self.earthRadius = earthRadius
        self.dotSize = dotSize
        self.enablesParticles = enablesParticles
        self.particles = particles
        self.earthColor = earthColor
        self.glowColor = glowColor
        self.reflectionColor = reflectionColor
        self.glowShininess = glowShininess
    }
    
    public init() {
        
    }
    
    #if os(iOS)
    func makeUIViewController(context: Context) -> GlobeViewController {
        let globeController = GlobeViewController(earthRadius: earthRadius ?? 1, dotCount: dotCount ?? 12500)
        updateGlobeController(globeController)
        return globeController
    }
    
    func updateUIViewController(_ uiViewController: GlobeViewController, context: Context) {
        updateGlobeController(uiViewController)
    }
    #else
    func makeNSViewController(context: Context) -> GlobeViewController {
        let globeController = GlobeViewController(earthRadius: earthRadius ?? 1, dotCount: dotCount ?? 12500)
        updateGlobeController(globeController)
        return globeController
    }
    
    func updateNSViewController(_ nsViewController: GlobeViewController, context: Context) {
        updateGlobeController(nsViewController)
    }
    #endif
    
    private func updateGlobeController(_ globeController: GlobeViewController) {
        if let dotSize = dotSize {
            globeController.dotSize = CGFloat(dotSize)
        }
        if let enablesParticles = enablesParticles {
            globeController.enablesParticles = enablesParticles
        }
        if let particles = particles {
            globeController.particles = particles
        }
        if let earthColor = earthColor {
            globeController.earthColor = earthColor
        }
        if let glowColor = glowColor {
            globeController.glowColor = glowColor
        }
        if let reflectionColor = reflectionColor {
            globeController.reflectionColor = reflectionColor
        }
        if let glowShininess = glowShininess {
            globeController.glowShininess = glowShininess
        }
    }
}

@available(iOS 13.0, *)
public struct GlobeView: View {
  public var dotCount: Int?
  public var earthRadius: Double?
  public var dotSize: Float?
  public var enablesParticles: Bool?
  public var particles: SCNParticleSystem?
  public var earthColor: Color?// = Color(red: 0.0, green: 0.482, blue: 0.871)
  public var glowColor: Color?// = Color(red: 0.0, green: 0.22, blue: 0.482)
  public var reflectionColor: Color?// = Color(red: 0.0, green: 0.482, blue: 0.871)
  public var glowShininess: CGFloat?
  
  public init() {
    
  }
  
  public init(
    dotCount: Int? = nil,
    earthRadius: Double? = nil,
    dotSize: Float? = nil,
    enablesParticles: Bool? = nil,
    particles: SCNParticleSystem? = nil,
    earthColor: Color? = nil,
    glowColor: Color? = nil,
    reflectionColor: Color? = nil,
    glowShininess: CGFloat? = nil
  ) {
    self.dotCount = dotCount
    self.earthRadius = earthRadius
    self.dotSize = dotSize
    self.enablesParticles = enablesParticles
    self.particles = particles
    self.earthColor = earthColor
    self.glowColor = glowColor
    self.reflectionColor = reflectionColor
    self.glowShininess = glowShininess
  }
  
  public var body: some View {
    GlobeViewControllerRepresentable(
      dotCount: dotCount,
      earthRadius: earthRadius,
      dotSize: dotSize,
      enablesParticles: enablesParticles,
      particles: particles,
      earthColor: earthColor,
      glowColor: glowColor,
      reflectionColor: reflectionColor,
      glowShininess: glowShininess
    )
  }
}
