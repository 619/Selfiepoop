/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wrapper SceneKit node for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit
import Firebase

struct RemoteVirtualObjectDefinition: Codable, Equatable {
    
    let id: String
    
    lazy var thumbImage: UIImage = UIImage(named: "test")!
    
    init(id:String) {
        self.id = id
        
    }
    
    static func ==(lhs: RemoteVirtualObjectDefinition, rhs: RemoteVirtualObjectDefinition) -> Bool {
//        return lhs.modelName == rhs.modelName
//            && lhs.displayName == rhs.displayName
//            && lhs.particleScaleInfo == rhs.particleScaleInfo
        return true
    }
}

class RemoteVirtualObject: SCNNode, ReactsToScale {
    let definition: RemoteVirtualObjectDefinition
    let referenceNode: SCNReferenceNode
    
    init(definition: RemoteVirtualObjectDefinition) {
        self.definition = definition
       let ref = Database.database().reference()

//        let holoref1 = ref.child("holograms").child(definition.id).child("durl").dictionaryWithValues(forKeys: ["ao","diffuse","normal","metalness", "roughness", "shadow"])
        // 7 requests is so many! should be one!!!
        let ref_ao = ref.child("holograms").child(definition.id).child("durl").child("ao")
        let ref_diffuse = ref.child("holograms").child(definition.id).child("durl").child("diffuse")
        let ref_metalness = ref.child("holograms").child(definition.id).child("durl").child("metalness")
        let ref_roughness = ref.child("holograms").child(definition.id).child("durl").child("roughness")
        let ref_shadow = ref.child("holograms").child(definition.id).child("durl").child("shadow")
        let ref_particle = ref.child("holograms").child(definition.id).child("durl").child("particle")
        let ref_dae1 = ref.child("holograms").child(definition.id).child("durl").child("dae_1")
        let ref_dae2 = ref.child("holograms").child(definition.id).child("durl").child("dae_2")
        let ref_dae3 = ref.child("holograms").child(definition.id).child("durl").child("dae_3")
        let attr_array = [ref_ao, ref_diffuse, ref_metalness, ref_roughness, ref_shadow, ref_particle, ref_dae1, ]

        var configuration = URLSessionConfiguration.default
        var manager = AFURLSessionManager(sessionConfiguration: configuration)
        var url =  URL(string: "https://firebasestorage.googleapis.com/v0/b/son-of-database.appspot.com/o/test%2Fmissile1.dae?alt=media&token=ea28d59c-015a-4c49-9e16-a02e0d12b5d2")
        var url2 =  URL(string: "https://firebasestorage.googleapis.com/v0/b/son-of-database.appspot.com/o/test%2FTexture.png?alt=media&token=aaefc7cd-f697-4395-a271-473050de5787")
        var request = URLRequest(url: url!)
        var downloadTask: URLSessionDownloadTask = manager!.downloadTask(with: request, progress: nil, destination: {(_ targetPath: URL?, _ response: URLResponse?) -> URL? in
            var documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsDirectoryURL?.appendingPathComponent((response?.suggestedFilename!)!)
        }, completionHandler: {(_ response: URLResponse?, _ filePath: URL?, _ error: Error?) -> Void in
          //  print("File downloaded to: \(filePath)")
            guard let node = SCNReferenceNode(url: filePath!)
            else { fatalError("can't find expected virtual object bundle resources") }
            node.position = SCNVector3(0, 0, -2)
        
           let referenceNode = node
           super.init()
            self.addChildNode(node)
            


        })

            }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadModel() {
        referenceNode.load()
    }
    func unloadModel() {
        referenceNode.unload()
    }
    var modelLoaded: Bool {
        return referenceNode.isLoaded
    }
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
    func reactToScale() {
        //particleScale stuff
//        for (nodeName, particleSize) in definition.particleScaleInfo {
//            guard let node = self.childNode(withName: nodeName, recursively: true), let particleSystem = node.particleSystems?.first
//                else { continue }
//            particleSystem.reset()
//            particleSystem.particleSize = CGFloat(scale.x * particleSize)
//        }
    }
}

extension RemoteVirtualObject {
	
	static func isNodePartOfVirtualObject(_ node: SCNNode) -> RemoteVirtualObject? {
		if let virtualObjectRoot = node as? RemoteVirtualObject {
			return virtualObjectRoot
		}
		
		if node.parent != nil {
			return isNodePartOfVirtualObject(node.parent!)
		}
		
		return nil
	}
    
}

// MARK: - Protocols for Virtual Objects

protocol RemoteReactsToScale {
	func reactToScale()
}

extension SCNNode {
	
	func remoteReactsToScale() -> ReactsToScale? {
		if let canReact = self as? ReactsToScale {
			return canReact
		}
		
		if parent != nil {
			return parent!.reactsToScale()
		}
		
		return nil
	}
}
