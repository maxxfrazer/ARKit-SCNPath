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

public class RKPathEntity: SCNPathNode {

    /// The SceneKit scene that this node belongs to.
    public weak var scene: SCNScene?

    /// A realityKit entity which represents the generated path.
    public var realityKitPath = Entity()

    public var pathColor: UIColor = .blue

    /// The number of times we have generated a .usdz file
    /// This is used for changing the file path each time.
    private var entityCount = 0

    private var pathEntitiesInScene = [Entity]()

    /// Create a new
    /// - Parameters:
    ///   - path: Points from which to make the path.
    ///   - width: Width of your path (default 0.5).
    ///   - curvePoints: Number of points to make the curve at any turn in the path, default to 8. 0 will make sharp corners.
    ///   - materials: Materials to be used on the geometry. Only the first will be used.
    override init(
        path: [SCNVector3], width: Float = 0.5,
        curvePoints: Float = 8, materials: [SCNMaterial] = []
    ) {
        super.init(path: path,
                   width: width,
                   curvePoints: curvePoints,
                   materials: materials)
        // Remove synchronization to save memory.
        self.realityKitPath.visit(using: { $0.synchronization = nil })
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func recalcGeometry() {
        super.recalcGeometry()

        /// Delete the old usdz files we saved to the device.
        // let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // appDelegate.deleteTemporaryDirectory()

        // if we didn't use a different file path each time, the model would Not change.
        makeRKGeo(path: "rkPath\(entityCount).usdz")
        entityCount += 1
    }

    // Make a .usdz file from the SceneKit scene that includes the SceneKit path so that we can use it in RealitKit.
    private func makeRKGeo(path: String) {
        let url = FileManager.default.temporaryDirectory
        let finalURL = url.appendingPathComponent(path)
        // If the file already exists, we must delete it first
        if FileManager.default.fileExists(atPath: finalURL.path) {
            try? FileManager.default.removeItem(at: finalURL)
        }
        scene?.write(
            to: finalURL, delegate: nil,
            progressHandler: { completion, _, _  in
                print("completion:", completion)
            }
        )
        loadEntity(fromURL: finalURL)
    }

    // Load the .usdz file as a RealityKit Entity
    private func loadEntity(fromURL url: URL) {
        var cancellable: AnyCancellable?
        cancellable = Entity.loadAsync(
            contentsOf: url
        ).sink(receiveCompletion: { _ in
            cancellable?.cancel()
        }, receiveValue: { (loadedEntity: Entity) in
            self.didLoadNewUSDZModel(model: loadedEntity)
            cancellable?.cancel()
        })
    }

    // When the new .usdz file has loaded, update realityKitPath to have the same mesh and material.
    private func didLoadNewUSDZModel(model: Entity) {
        print("didLoadNewUSDZModel", model)

        // The mesh and material of the rkPath now update to be the same as the generated SCN geometry.
        // This should work without needing to search through for a model.
        self.realityKitPath.children.forEach { $0.removeFromParent() }
        self.realityKitPath.addChild(model)
//        self.realityKitPath.components[ModelComponent.self] = model.findHasModel()?.model
    }
}

extension Entity {
    /// From Reality Composer, the visible ModelEntities are children of nonVisible Entities
    /// Recursively searches through all descendants for a HasModel Entity, Not just through the direct children.
    /// Reutrns the first model entity it finds.
    /// Returns the input entity if it is a model entity. (DFS)
    func findHasModel() -> HasModel? {
        if self is HasModel { return self as? HasModel }

        for child in self.children {
            if let childModel = child.findHasModel() {
                return childModel
            }
        }
        return nil
    }

    func visit(using block: (Entity) -> Void) {
        block(self)

        for child in children {
            child.visit(using: block)
        }
    }
}
