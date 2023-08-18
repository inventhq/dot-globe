//
//  File.swift
//
//
//  Created by Demirhan Mehmet Atabey on 25.05.2023.
//

import Foundation
import SceneKit
import CoreImage
import SwiftUI

#if os(iOS)
public typealias GenericController = UIViewController
public typealias GenericColor = UIColor
public typealias GenericImage = UIImage
#else
public typealias GenericController = NSViewController
public typealias GenericColor = NSColor
public typealias GenericImage = NSImage
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

    convenience init?(named name: String) {
        self.init(named: Name(name))
    }
}
#endif

public class GlobeViewController: GenericController {
    public var earthNode: SCNNode!
    private var sceneView : SCNView!
    private var cameraNode: SCNNode!
    private var worldMapImage : CGImage {
        guard let path = Bundle.main.path(forResource: "earth-dark", ofType: "jpg") else { fatalError("Could not locate world map image.") }
        guard let image = GenericImage(contentsOfFile: path)?.cgImage else { fatalError() }
        return image
    }

    private lazy var imgData: CFData = {
        guard let imgData = worldMapImage.dataProvider?.data else { fatalError("Could not fetch data from world map image.") }
        return imgData
    }()

    private lazy var worldMapWidth: Int = {
        return worldMapImage.width
    }()

    public var earthRadius: Double = 1.0 {
        didSet {
            if let earthNode = earthNode {
                earthNode.removeFromParentNode()
                setupGlobe()
            }
        }
    }
   
    
    public var dotSize: CGFloat = 0.005 {
        didSet {
            if dotSize != oldValue {
                setupDotGeometry()
            }
        }
    }
    
    public var enablesParticles: Bool = true {
        didSet {
            if enablesParticles {
                setupParticles()
            } else {
                sceneView.scene?.rootNode.removeAllParticleSystems()
            }
        }
    }
    
    public var particles: SCNParticleSystem? {
        didSet {
            if let particles = particles {
                sceneView.scene?.rootNode.removeAllParticleSystems()
                sceneView.scene?.rootNode.addParticleSystem(particles)
            }
        }
    }
    
    public var background: Color? {
        didSet {
            if let background = background {
                #if os(iOS)
                view.backgroundColor = GenericColor(background)
                #else
                view.layer?.backgroundColor = GenericColor(background).cgColor
                #endif
            }
        }
    }
    
    public var earthColor: Color = .earthColor {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.diffuse.contents = earthColor
            }
        }
    }
    
    public var glowColor: Color = .earthGlow {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.emission.contents = glowColor
            }
        }
    }
    
    public var reflectionColor: Color = .earthReflection {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.emission.contents = glowColor
            }
        }
    }

    public var glowShininess: CGFloat = 1.0 {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.shininess = glowShininess
            }
        }
    }

    private var dotRadius: CGFloat {
        if dotSize > 0 {
             return dotSize
        }
        else {
            return 0.01 * CGFloat(earthRadius) / 1.0
        }
    }

    private var dotCount = 12500
    
    public init(earthRadius: Double) {
        self.earthRadius = earthRadius
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(earthRadius: Double, dotCount: Int) {
        self.earthRadius = earthRadius
        self.dotCount = dotCount
        super.init(nibName: nil, bundle: nil)
    }
    
    #if os(macOS)
    override public func loadView() {
        self.view = .init()
    }
    #endif
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    public override func viewDidAppear() {
        super.viewDidAppear()
        setupScene()
        if enablesParticles {
            setupParticles()
        }
        setupCamera()
        setupGlobe()
        setupDotGeometry()
        if let background = background {
            setupBackground(color: GenericColor(background))
        }
    }
    #else
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        if enablesParticles {
            setupParticles()
        }
        setupCamera()
        setupGlobe()
        setupDotGeometry()
        if let background = background {
            setupBackground(color: GenericColor(background))
        }
    }
    #endif
    
    private func setupScene() {
        let scene = SCNScene()
        sceneView = SCNView(frame: view.frame)

        sceneView.scene = scene
        
        sceneView.showsStatistics = true
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        
        self.view.addSubview(sceneView)
    }
    
    private func setupParticles() {
        guard let stars = SCNParticleSystem(named: "StarsParticles.scnp", inDirectory: nil) else { return }
        stars.isLightingEnabled = false
        sceneView.scene?.rootNode.addParticleSystem(stars)
    }
    
    private func setupBackground(color: GenericColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [color.cgColor, GenericColor.black.cgColor]
        
        #if os(iOS)
        view.layer.insertSublayer(gradientLayer, at: 0)
        #else
        view.layer?.insertSublayer(gradientLayer, at: 0)
        #endif
        
    }
    
    private func setupCamera() {
        self.cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)

        
        sceneView.scene?.rootNode.addChildNode(cameraNode)
    }
    
    private func setupGlobe() {
        self.earthNode = EarthNode(radius: earthRadius, earthColor: earthColor, earthGlow: glowColor, earthReflection: reflectionColor)
        sceneView.scene?.rootNode.addChildNode(earthNode)
    }
    
    private func setupDotGeometry() {
        self.generateTextureMap(radius: CGFloat(earthRadius)) { textureMap in
            let dotColor = GenericColor(white: 1, alpha: 1)

            // threshold to determine if the pixel in the earth-dark.jpg represents terrain (0.03 represents rgb(7.65,7.65,7.65), which is almost black)
            let threshold: CGFloat = 0.03

            let dotGeometry = SCNSphere(radius: dotRadius)

            dotGeometry.firstMaterial?.diffuse.contents = dotColor
            dotGeometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant

            var positions = [SCNVector3]()
            var dotNodes = [SCNNode]()

            for i in 0...textureMap.count - 1 {
                let u = textureMap[i].x
                let v = textureMap[i].y

                let pixelColor = self.getPixelColor(x: Int(u), y: Int(v))

                if pixelColor.red < threshold && pixelColor.green < threshold && pixelColor.blue < threshold {
                    let dotNode = SCNNode(geometry: dotGeometry)
                    dotNode.position = textureMap[i].position
                    positions.append(dotNode.position)
                    dotNodes.append(dotNode)
                }
            }

            DispatchQueue.main.async {
                let dotPositions = positions as NSArray
                let dotIndices = NSArray()
                let source = SCNGeometrySource(vertices: dotPositions as! [SCNVector3])
                let element = SCNGeometryElement(indices: dotIndices as! [Int32], primitiveType: .point)

                let pointCloud = SCNGeometry(sources: [source], elements: [element])

                let pointCloudNode = SCNNode(geometry: pointCloud)
                for dotNode in dotNodes {
                    pointCloudNode.addChildNode(dotNode)
                }

                self.sceneView.scene?.rootNode.addChildNode(pointCloudNode)
            }
        }
    }

    private func generateTextureMap(radius: CGFloat, completion: ([(position: SCNVector3, x: Int, y: Int)]) -> ()) {
        var textureMap = [(position: SCNVector3, x: Int, y: Int)]()
        textureMap.reserveCapacity(dotCount)
        let doubleDotCount = Double(dotCount)
        let floatWorldMapImageHeight = CGFloat(worldMapImage.height)
        let floatWorldMapImageWidth = CGFloat(worldMapImage.width)
        for i in 0...dotCount {
            let phi = acos(-1 + (2 * Double(i)) / doubleDotCount)
            let theta = sqrt(doubleDotCount * Double.pi) * phi

            let x = sin(phi) * cos(theta)
            let y = sin(phi) * sin(theta)
            let z = cos(phi)

            let u = CGFloat(theta) / (2 * CGFloat.pi)
            let v = CGFloat(phi) / CGFloat.pi

            if u.isNaN || v.isNaN {
                return
            }

            let xPixel = Int(u * floatWorldMapImageWidth)
            let yPixel = Int(v * floatWorldMapImageHeight)

            #if os(iOS)
            textureMap.append((position: SCNVector3(x: Float(x) * Float(radius), y: Float(y) * Float(radius), z: Float(z) * Float(radius)), x: xPixel, y: yPixel))
            #else
            textureMap.append((position: SCNVector3(x: x * radius, y: y * radius, z: z * radius), x: xPixel, y: yPixel))
            #endif
        }
        completion(textureMap)
    }

    private func getPixelColor(x: Int, y: Int) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imgData)
        let pixelInfo: Int = ((worldMapWidth * y) + x) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)

        return (r, g, b, a)
    }
}

private extension Color {
    static var earthColor: Color {
        return Color(red: 0.227, green: 0.133, blue: 0.541)
    }
    
    static var earthGlow: Color {
        Color(red: 0.133, green: 0.0, blue: 0.22)
    }
    
    static var earthReflection: Color {
        Color(red: 0.227, green: 0.133, blue: 0.541)
    }
}
