//
//  RKPathEntity.swift
//  SCNPath+Example
//
//  Created by Grant Jarvis on 3/13/21.
//  Copyright © 2021 Max Cobb. All rights reserved.
//

import SceneKit
import Combine
import RealityKit

public class RKPathEntity : SCNPathNode {
    
    ///The SceneKit scene that this node belongs to.
    public weak var scene : SCNScene?
    
    ///A realityKit entity which represents the generated path.
    public var realityKitPath = Entity()
    
    public var pathColor: UIColor = .blue
    
    ///The number of times we have generated a .usdz file
    ///This is used for changing the file path each time.
    private var entityCount = 0
    
    private var pathEntitiesInScene = [Entity]()
    
    override init(
        path: [SCNVector3], width: Float = 0.5,
        curvePoints: Float = 8, materials: [SCNMaterial] = []
    ) {
        super.init(path: path,
                   width: width,
                   curvePoints: curvePoints,
                   materials: materials)
        //Remove synchronization to save memory.
        self.realityKitPath.visit(using: {$0.synchronization = nil})
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    

    
    func makePathSegment(length: Float, width: Float = 0.35) -> Entity {
        let pivotPoint = Entity()
        let rectangleMesh = MeshResource.generatePlane(width: width, depth: length + width, cornerRadius: width / 2)
        let generatedRectangle = ModelEntity(mesh: rectangleMesh,
                                             materials: [SimpleMaterial.init(color: pathColor, isMetallic: false)])
        pivotPoint.addChild(generatedRectangle)
        
        //This shape can be broken down into 3 parts: 1 rectangle of length length, and 2 ends that are half-circles of radius pathWidth / 2.
        //Put the center of the half-circle at one end of the rectangle at the center of the pivot point; We want each path to overlap on the half-circle tips.
        let zPosition = (-(length + width) / 2) + (width / 2)
        
        
        generatedRectangle.position = [0,0,zPosition]
        return pivotPoint
    }
    
    
    override func recalcGeometry() {
        guard realityKitPath.isAnchored
        else {return}
        
        //Start off with just a circle for the first position.
        if self.path.count == 1 {
            let pathSegment = makePathSegment(length: 0)
            let newPosition = path[0].getSIMD3Float()
            realityKitPath.anchor!.addChild(pathSegment)
            pathEntitiesInScene.append(pathSegment)
            pathSegment.position = newPosition
            return
        }
        //Using a smaller distance between points on a curve will lead to smoother curves.
        
        //Keep all y-values the same so that the ends don't protrude in the y-dimension (looks more like disjointed shapes than one continouous path).
        let currentIndex = (path.count - 1)
        let lastPosition : SIMD3<Float> = [path[currentIndex - 1].getSIMD3Float().x,
                            path[0].y,
                            path[currentIndex - 1].getSIMD3Float().z]
        let newPosition : SIMD3<Float> = [path[currentIndex].getSIMD3Float().x,
                                          lastPosition.y,
                           path[currentIndex].getSIMD3Float().z]
        let length = simd_length(newPosition - lastPosition)
        let pathSegment = makePathSegment(length: length)
        realityKitPath.anchor!.addChild(pathSegment)
        pathEntitiesInScene.append(pathSegment)
        pathSegment.position = lastPosition
        
        //Rotate the rectangle to connect the dots.
        // --(lastPosition is already at one end of the rectangle, rotate to put newPosition at the other end).
        pathSegment.look(at: newPosition, from: lastPosition, relativeTo: realityKitPath.anchor!)
    }
 
    
    
    
    //This implementation is for when we are converting SCNScene to .usdz, Not for when we are generating the path from within RealityKit.
   // override func recalcGeometry() {
        //super.recalcGeometry()

        //if we didn't use a different file path each time, the model would Not change.
        //makeRKGeo(path: "rkPath\(entityCount).usdz")
        //entityCount += 1
        
        //Delete the old usdz files we saved to the device.
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.deleteTemporaryDirectory()
    //}
    
    
    ///Make a .usdz file from the SceneKit scene that includes the SceneKit path so that we can use it in RealitKit.
//    private func makeRKGeo(path : String){
//        let url = FileManager.default.temporaryDirectory
//        let finalURL = url.appendingPathComponent(path)
//        scene?.write(to: finalURL, delegate: nil, progressHandler: {
//            completion,error,unsafe  in
//            print("completion:", completion)
//        })
//        loadEntity(fromURL: finalURL)
//    }
        
    ///Load the .usdz file as a RealityKit Entity
//    private func loadEntity(fromURL url: URL){
//        var cancellable: AnyCancellable? = nil
//        cancellable = Entity.loadAsync(contentsOf: url)
//            .sink(receiveCompletion: { completion in
//                cancellable?.cancel()
//            }, receiveValue: { (loadedEntity: Entity) in
//                self.didLoadNewUSDZModel(model: loadedEntity)
//                cancellable?.cancel()
//            })
//    }
    
    
    ///When the new .usdz file has loaded, update realityKitPath to have the same mesh and material.
//    private func didLoadNewUSDZModel(model: Entity) {
//        print("didLoadNewUSDZModel", model)
//
//        //The mesh and material of the rkPath now update to be the same as the generated SCN geometry.
//        self.realityKitPath.components[ModelComponent.self] = model.findModelEntity()?.model
//    }
    
    
    
    
    
    
    
}


extension SCNVector3 {
    func getSIMD3Float() -> SIMD3<Float>{
        return SIMD3<Float>([self.x,
                             self.y,
                             self.z])
    }
}



extension Entity {
    ///From Reality Composer, the visible ModelEntities are children of nonVisible Entities
    ///Recursively searches through all descendants for a ModelEntity, Not just through the direct children.
    ///Reutrns the first model entity it finds.
    ///Returns the input entity if it is a model entity.
    func findHasModel() -> HasModel? {
        if self is HasModel { return self as? HasModel }
        
        guard let hasModels = self.children.filter({$0 is HasModel}) as? [HasModel] else {return nil}
        
        if !(hasModels.isEmpty) { //it's Not empty. We found at least one modelEntity.
            
            return hasModels[0]
            
        } else { //it is empty. We did Not find a modelEntity.
            //every time we check a child, we also iterate through its children if our result is still nil.
            for child in self.children{
                
                if let result = child.findHasModel(){
                    return result
                }}}
        return nil //default
    }
    
    func visit(using block: (Entity) -> Void) {
        block(self)

        for child in children {
            child.visit(using: block)
        }
    }
}
