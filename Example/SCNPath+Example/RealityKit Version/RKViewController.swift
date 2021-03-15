//
//  RKViewController.swift
//  PathVisualiser
//
//  Created by Grant Jarvis on 03/13/21.
//  Copyright © 2021 Grant Jarvis. All rights reserved.
//

import ARKit
import FocusEntity
import RealityKit
// import SCNPath

class RKViewController: UIViewController{


    internal var arView = ARView(frame: .zero)
    

    public let scnScene = SCNScene()
    public var focusEntity : FocusEntity!

    var hitPoints = [SCNVector3]() {
        didSet {
            self.pathNode.path = self.hitPoints
        }
    }

    var pathNode = RKPathEntity(path: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        // If this device is running iOS 13.4 or later and has LiDAR, then allow occlusion with the LiDAR mesh.
        if #available(iOS 13.4, *),
           ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                runLiDARConfiguration()
        } else{
            runNonLiDARConfig()
        }
        
        pathNode.scene = scnScene
        self.arView.session.delegate = self

        self.arView.frame = self.view.bounds
        self.arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.view.addSubview(arView)
        
        let worldAnchor = AnchorEntity() //point 0,0,0
        self.arView.scene.addAnchor(worldAnchor)
        worldAnchor.addChild(pathNode.realityKitPath)


        // the next chunk of lines are just things I've added to make the path look nicer
        let pathMat = SCNMaterial()
        
        //necessary for conversion to RealityKit usdz.
        pathMat.lightingModel = .physicallyBased
        
        self.pathNode.materials = [pathMat]
        self.pathNode.position.y += 0.05
        if Int.random(in: 0...1) == 0 {
            pathMat.diffuse.contents = UIImage(named: "path_seamless")
            self.pathNode.textureRepeats = true
        } else {
            pathMat.diffuse.contents = UIImage(named: "path_with_fade")
        }
        self.pathNode.width = 0.5

        self.scnScene.rootNode.addChildNode(self.pathNode)
        self.setupGestures()
        
        do {
            let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
            let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
            self.focusEntity = FocusEntity(
                on: self.arView,
                style: .colored(
                    onColor: onColor, offColor: offColor,
                    nonTrackingColor: offColor
                )
            )
        } catch {
            self.focusEntity = FocusEntity(on: self.arView, focus: .classic)
            print("Unable to load plane textures")
            print(error.localizedDescription)
        }
    }

    func runNonLiDARConfig(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        arView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
}
