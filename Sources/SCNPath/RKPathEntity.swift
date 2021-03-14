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

public class RealityKitPathEntity : SCNPathNode {
    
    ///The SceneKit scene that this node belongs to.
    public weak var scene : SCNScene?
    
    ///A realityKit entity which represents the generated path.
    public var realityKitPath = Entity()
    
    ///The number of times we have generated a .usdz file
    ///This is used for changing the file path each time.
    private var entityCount = 0
    
    private var circleEntity : Entity?
    
    private var rectangleEntity : Entity?
    
    private var pathEntitiesInScene = [Entity]()
    
    override init(
        path: [SCNVector3], width: Float = 0.5,
        curvePoints: Float = 8, materials: [SCNMaterial] = []
    ) {
        super.init(path: path,
                   width: width,
                   curvePoints: curvePoints,
                   materials: materials)
        do {
            let shapesScene = try ShapesProj.loadShapesScene()
            loadShapes(scene: shapesScene)
        } catch {
            print(error.localizedDescription)
            return
        }
        //Remove synchronization to save memory.
        self.realityKitPath.visit(using: {$0.synchronization = nil})
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func loadShapes(scene: ShapesProj.ShapesScene){
        
        //Change pivot point.
        rectangleEntity = Entity()
        rectangleEntity?.addChild(scene.rectangle!)
        
        circleEntity = scene.circle
        
        //Then we can use custom materials (even with transparency) and video materials.
        //We could also smooth the points ourselves. They are all on the 2D X-Z plane.
    }
    
    override func recalcGeometry() {
        guard realityKitPath.isAnchored,
              circleEntity != nil,
              rectangleEntity != nil
        else {return}
        
        //Start off with just a circle for the first position,
        //Then every position after that gets a rectangle and a circle.
        //This way, every rectangle has a circle on both ends.
        if self.path.count == 1 {
            let circleLocal = circleEntity!.clone(recursive: true)
            realityKitPath.anchor!.addChild(circleLocal)
            circleLocal.setPosition(self.path[0].getSIMD3Float(), relativeTo: nil)
            pathEntitiesInScene.append(circleLocal)
            return
        }
        
        //Using a smaller distance between points on a curve will lead to smoother curves.
        
        //Keep all y-values the same so that the edges of the circles don't stick out.
        let currentIndex = (path.count - 1)
        let newPosition : SIMD3<Float> = [path[currentIndex].getSIMD3Float().x,
                           path[0].y,
                           path[currentIndex].getSIMD3Float().z]
        let lastPosition : SIMD3<Float> = [path[currentIndex - 1].getSIMD3Float().x,
                            path[0].y,
                            path[currentIndex - 1].getSIMD3Float().z]
        let length = simd_length(newPosition - lastPosition)
        let rectangleLocal = rectangleEntity!.clone(recursive: true)
        realityKitPath.anchor!.addChild(rectangleLocal)
        pathEntitiesInScene.append(rectangleLocal)
        rectangleLocal.position = lastPosition
        rectangleLocal.position.y = newPosition.y

        //The rectangle is already 1 meter long, so settings its scale in the Z-Dimension with the difference between the points (in meters) will leave it at the correct length, which is the distance between the points.
        rectangleLocal.setScale([1, 1, length], relativeTo: nil)
        //Rotate the rectangle to connect the dots.
        // --(lastPosition is already at one end of the rectangle, rotate to put newPosition at the other end).
        rectangleLocal.look(at: newPosition, from: lastPosition, relativeTo: realityKitPath.anchor!)
        
        //Put a circle at the tip of the rectangle.
        let circleLocal = circleEntity!.clone(recursive: true)
        realityKitPath.anchor!.addChild(circleLocal)
        circleLocal.setPosition(newPosition, relativeTo: nil)
        pathEntitiesInScene.append(circleLocal)
        

    }
        
        
        
        
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
    private func makeRKGeo(path : String){
        let url = FileManager.default.temporaryDirectory
        let finalURL = url.appendingPathComponent(path)
        scene?.write(to: finalURL, delegate: nil, progressHandler: {
            completion,error,unsafe  in
            print("completion:", completion)
        })
        loadEntity(fromURL: finalURL)
    }
        
    ///Load the .usdz file as a RealityKit Entity
    private func loadEntity(fromURL url: URL){
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadAsync(contentsOf: url)
            .sink(receiveCompletion: { completion in
                cancellable?.cancel()
            }, receiveValue: { (loadedEntity: Entity) in
                self.didLoadNewUSDZModel(model: loadedEntity)
                cancellable?.cancel()
            })
    }
    
    
    ///When the new .usdz file has loaded, update realityKitPath to have the same mesh and material.
    private func didLoadNewUSDZModel(model: Entity) {
        print("didLoadNewUSDZModel", model)
        
        //The mesh and material of the rkPath now update to be the same as the generated SCN geometry.
        self.realityKitPath.components[ModelComponent.self] = model.findModelEntity()?.model
    }
    
    
    
    
    
    
    
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
    func findModelEntity() -> ModelEntity? {
        if self is HasModel { return self as? ModelEntity }
        
        guard let modelEntities = self.children.filter({$0 is HasModel}) as? [ModelEntity] else {return nil}
        
        if !(modelEntities.isEmpty) { //it's Not empty. We found at least one modelEntity.
            
            return modelEntities[0]
            
        } else { //it is empty. We did Not find a modelEntity.
            //every time we check a child, we also iterate through its children if our result is still nil.
            for child in self.children{
                
                if let result = child.findModelEntity(){
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
