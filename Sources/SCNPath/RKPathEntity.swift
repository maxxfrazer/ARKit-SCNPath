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
    
    
    override func recalcGeometry() {
        super.recalcGeometry()

        //if we didn't use a different file path each time, the model would Not change.
        makeRKGeo(path: "rkPath\(entityCount).usdz")
        entityCount += 1
        
        //Delete the old usdz files we saved to the device.
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.deleteTemporaryDirectory()
    }
    
    
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
    }}
