/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import ReplayKit

class ARViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UISearchBarDelegate {

    var storedMap: Any!
    var storedVirtualObjects: Any!
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        return
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50.0, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0)
    }


    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func infoButton_TouchUpInside(_ sender: Any) {

        self.virtualObjectManager.virtualObjects = storedVirtualObjects as! [VirtualObject]
        self.virtualObjectManager.virtualObjects[0].loadModel()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.initialWorldMap = storedMap as? ARWorldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        print("load map")
        
        //        guard let url = URL(string: "https://www.facebook.com/permalink.php?story_fbid=1994510934126550&id=1994508624126781") else {
//            return //be safe
//        }
//
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
}
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let takeScreenshotBlock = {
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
            DispatchQueue.main.async {
                // Briefly flash the screen.
                let flashOverlay = UIView(frame: self.sceneView.frame)
                flashOverlay.backgroundColor = UIColor.white
                self.sceneView.addSubview(flashOverlay)
                UIView.animate(withDuration: 0.25, animations: {
                    flashOverlay.alpha = 0.0
                }, completion: { _ in
                    flashOverlay.removeFromSuperview()
                })
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            takeScreenshotBlock()
        case .restricted, .denied:
            let title = "Photos access denied"
            let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
            textManager.showAlert(title: title, message: message)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    takeScreenshotBlock()
                }
            })
        }
    }

    func reloadCollection() {
        collectionViewOutlet.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewOutlet {
            return availableObjects.count
        }
        
        return objectArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewOutlet {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectorCollectionViewCell", for: indexPath) as! ImageViewCell
            
            let image: UIImage? = UIImage(named: availableObjects[indexPath.row].modelName)
            cell.cellImage.image = image
            
            cell.cellImage.tintColor = UIColor.white
            return cell
        }
            
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subCategoryCollectionViewCell", for: indexPath) as! subCategoryCollectionViewCell
            
            let image: UIImage? = objectArray[indexPath.row]
            cell.subCategoryImageCell.image = image
            cell.tintColor = nil
            
            return cell
        }
        
        
    }
    
    var selectedCategory = 0
   
    func changeObjectList(index: Int) {
        if (index == 0) {
          availableObjects = VirtualObjectManager.shareObjects(index: 0)
        } else if (index == 1) {
            availableObjects = VirtualObjectManager.shareObjects(index: 1)
        } else if (index == 2) {
            availableObjects = VirtualObjectManager.shareObjects(index: 2)
        } else if (index == 3) {
           availableObjects = VirtualObjectManager.shareObjects(index: 3)
        } else {
            availableObjects = VirtualObjectManager.shareObjects(index: 4)
        }
    }
    
    func updateCollectionView() {
        collectionViewOutlet.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionViewOutlet {
        selectedCategory = indexPath.row
        
        guard let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }
        
        let definition = availableObjects[indexPath.row]
        let object = VirtualObject(definition: definition)
        
        let position = focusSquare?.lastPosition ?? float3(0)
        virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
        if object.parent == nil {
            serialQueue.async {
                self.sceneView.scene.rootNode.addChildNode(object)
            }
        }
        } else {
            changeObjectList(index: indexPath.row)
            collectionViewOutlet.reloadData()
        }
    }
    
 // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint?
    var trackingFallbackTimer: Timer?
    
    let session = ARSession()
    let fallbackConfiguration = ARWorldTrackingConfiguration()
    
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Virtual Object Manipulation Properties
    
    var dragOnInfinitePlanesEnabled = false
    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
//                self.settingsButton.isEnabled = !self.isLoadingObject
//                self.addObjectButton.isEnabled = !self.isLoadingObject
                self.restartExperienceButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet weak var subCategoryOverlay: UIView!
    @IBOutlet var sceneView: ARSCNView!
  //  @IBOutlet weak var messagePanel: UIView!
   // @IBOutlet weak var messageLabel: UILabel!
  //  @IBOutlet weak var settingsButton: UIButton!
   // @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var restartExperienceButton: UIButton!
    
   
    
    var availableObjects: [VirtualObjectDefinition] = VirtualObjectManager.shareObjects(index: 0)
    // MARK: - Queues
    
    static let serialQueue = DispatchQueue(label: "com.apple.arkitexample.serialSceneKitQueue")
	// Create instance variable for more readable access inside class
	let serialQueue: DispatchQueue = ARViewController.serialQueue
	
    // MARK: - View Controller Life Cycle
   
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        storedMap = nil
        storedVirtualObjects = nil
        
         Setting.registerDefaults()
		setupUIControls()
        setupScene()
        
        // Register all widgets in view to InstantSearch
       // InstantSearch.shared.registerAllWidgets(in: self.view)
        
//        var nib = UINib(nibName: "UICollectionElementKindCell", bundle:nil)
//        self.collectionView.register(nib, forCellWithReuseIdentifier: "SelectorCollectionViewCell")
        
        self.collectionViewOutlet.dataSource = self
        self.collectionViewOutlet.delegate = self
        
        self.collectionViewOutlet.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        
       // self.subCategoryCollectionViewOutlet.dataSource = self
      //  self.subCategoryCollectionViewOutlet.delegate = self
        
        self.view.addSubview(collectionViewOutlet)
       // self.view.addSubview(subCategoryCollectionViewOutlet)
        
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.up
//        self.view.addGestureRecognizer(swipeRight)
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeDown.direction = UISwipeGestureRecognizerDirection.down
//        self.view.addGestureRecognizer(swipeDown)
       
    }
    

    var menuIsVisible: Bool = true

//    func disappearCollectionView () {
//        DispatchQueue.main.async {
//            self.collectionViewOutlet.isHidden = true
//         //   self.subCategoryCollectionViewOutlet.isHidden = true
//        //    self.subCategoryOverlay.isHidden = true
//         //   self.refreshBackground.isHidden = true
//            self.horizLineSeperator.isHidden = true
//            self.collectionViewFiller1.isHidden = true
//          //  self.collectionViewFiller2.isHidden = true
//           // self.cancelButton.isHidden = true
//        }
//
//
//
//    }
    
//    func appearCollectionView () {
//        DispatchQueue.main.async {
//        self.collectionViewOutlet.isHidden = false
//        //self.subCategoryCollectionViewOutlet.isHidden = false
//       //     self.subCategoryOverlay.isHidden = false
//     //   self.refreshBackground.isHidden = false
//      //  self.horizLineSeperator.isHidden = false
//        self.collectionViewFiller1.isHidden = false
//       // self.collectionViewFiller2.isHidden = false
//       //     self.cancelButton.isHidden = false
//
//        }
//    }
    
    // MARK: UICollectionViewDataSource
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
		if ARWorldTrackingConfiguration.isSupported {
			// Start the ARSession.
			resetTracking()
		} else {
			// This device does not support 6DOF world tracking.
			let sessionErrorMsg = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. " +
			"Please quit the application."
			displayErrorMessage(title: "Unsupported platform", message: sessionErrorMsg, allowRestart: false)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
	}
	
    // MARK: - Setup
    
	func setupScene() {
        
        sceneView.setup()
        sceneView.delegate = self
        sceneView.session = session

		virtualObjectManager = VirtualObjectManager()
        virtualObjectManager.delegate = self
//        var configuration = URLSessionConfiguration.default
//        var manager = AFURLSessionManager(sessionConfiguration: configuration)
//        var url =  URL(string: "https://firebasestorage.googleapis.com/v0/b/son-of-database.appspot.com/o/test%2Fmissile1.dae?alt=media&token=ea28d59c-015a-4c49-9e16-a02e0d12b5d2")
//        var url2 =  URL(string: "https://firebasestorage.googleapis.com/v0/b/son-of-database.appspot.com/o/test%2FTexture.png?alt=media&token=aaefc7cd-f697-4395-a271-473050de5787")
//        var request = URLRequest(url: url!)
//        var downloadTask: URLSessionDownloadTask = manager!.downloadTask(with: request, progress: nil, destination: {(_ targetPath: URL?, _ response: URLResponse?) -> URL? in
//            var documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            return documentsDirectoryURL?.appendingPathComponent((response?.suggestedFilename!)!)
//        }, completionHandler: {(_ response: URLResponse?, _ filePath: URL?, _ error: Error?) -> Void in
//            //  print("File downloaded to: \(filePath)")
//            guard let node = SCNReferenceNode(url: filePath!)
//                else { fatalError("can't find expected virtual object bundle resources") }
//            node.position = SCNVector3(0, 0, -2)
//
//            let referenceNode = node
//            self.sceneView.scene.rootNode.addChildNode(node)
//
        
            
//        })

		// set up scene view
			// sceneView.showsStatistics = true
		
		sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: serialQueue)
		
		setupFocusSquare()
		
		DispatchQueue.main.async {
			self.screenCenter = self.sceneView.bounds.mid
		}
	}
//    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
//        //textView.deleteBackward()
//    }
//    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
//       // textView.insertText(emoji)
//    }
        

    
    func setupUIControls() {
        textManager = TextManager(ARViewController: self)
        
        // Set appearance of message output panel
       // messagePanel.layer.cornerRadius = 3.0
       // messagePanel.clipsToBounds = true
      //  messagePanel.isHidden = true
        //messageLabel.text = ""
    }
	
    // MARK: - ARSCNViewDelegate
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		updateFocusSquare()
		
		// If light estimation is enabled, update the intensity of the model's lights and the environment map
		if let lightEstimate = self.session.currentFrame?.lightEstimate {
			self.sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: serialQueue)
		} else {
			self.sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: serialQueue)
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor {
			serialQueue.async {
				self.addPlane(node: node, anchor: planeAnchor)
				self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
			}
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor {
			serialQueue.async {
				self.updatePlane(anchor: planeAnchor)
				self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
			}
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor {
			serialQueue.async {
				self.removePlane(anchor: planeAnchor)
			}
		}
	}
    
	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
      //  textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)

        switch camera.trackingState {
        case .notAvailable:
            return
           // textManager.escalateFeedback(for: camera.trackingState, inSeconds: 5.0)
        case .limited:
            // After 10 seconds of limited quality, fall back to 3DOF mode.
            trackingFallbackTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
                self.session.run(self.fallbackConfiguration)
              //  self.textManager.showMessage("Falling back to 3DOF tracking.")
                self.trackingFallbackTimer?.invalidate()
                self.trackingFallbackTimer = nil
            })
        case .normal:
           textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
            if trackingFallbackTimer != nil {
                trackingFallbackTimer!.invalidate()
                trackingFallbackTimer = nil
            }
        }
	}
	
    func session(_ session: ARSession, didFailWithError error: Error) {

        guard let arError = error as? ARError else { return }

        let nsError = error as NSError
		var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
		if let recoveryOptions = nsError.localizedRecoveryOptions {
			for option in recoveryOptions {
				sessionErrorMsg.append("\(option).")
			}
		}

        let isRecoverable = (arError.code == .worldTrackingFailed)
		if isRecoverable {
			sessionErrorMsg += "\nYou can try resetting the session or quit the application."
		} else {
			sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
		}
		
		displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
	}
	
	func sessionWasInterrupted(_ session: ARSession) {
		textManager.blurBackground()
		textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
	}
		
	func sessionInterruptionEnded(_ session: ARSession) {
		textManager.unblurBackground()
		session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
		restartExperience(self)
		textManager.showMessage("RESETTING SESSION")
	}
	
    // MARK: - Gesture Recognizers
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch: UITouch? = touches.first
//        //location is relative to the current view
//        // do something with the touched point
//        if touch?.view == sceneView {
//            menuButton.tintColor = UIColor.white
//            disappearCollectionView()
//            
//        }
		virtualObjectManager.reactToTouchesBegan(touches, with: event, in: self.sceneView)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjectManager.virtualObjects.isEmpty {
			//chooseObject(addObjectButton)
			return
		}
		virtualObjectManager.reactToTouchesEnded(touches, with: event)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesCancelled(touches, with: event)
	}
	
    // MARK: - Planes
	
	var planes = [ARPlaneAnchor: Plane]()
	
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
		let plane = Plane(anchor)
		planes[anchor] = plane
		node.addChildNode(plane)
		
		textManager.cancelScheduledMessage(forType: .planeEstimation)
		//textManager.showMessage("SURFACE DETECTED")
		if virtualObjectManager.virtualObjects.isEmpty {
            return
			//textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
		}
	}
		
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
			plane.update(anchor)
		}
	}
			
    func removePlane(anchor: ARPlaneAnchor) {
		if let plane = planes.removeValue(forKey: anchor) {
			plane.removeFromParentNode()
        }
    }
	
	func resetTracking() {
		session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
		
		// reset timer
		if trackingFallbackTimer != nil {
			trackingFallbackTimer!.invalidate()
			trackingFallbackTimer = nil
		}
		
//        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
//                                    inSeconds: 7.5,
//                                    messageType: .planeEstimation)
	}

    // MARK: - Focus Square
    
    var focusSquare: FocusSquare?
	
    func setupFocusSquare() {
		serialQueue.async {
			self.focusSquare?.isHidden = true
			self.focusSquare?.removeFromParentNode()
			self.focusSquare = FocusSquare()
			self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
		}
		
	//	textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
	
	func updateFocusSquare() {
		guard let screenCenter = screenCenter else { return }
		
		DispatchQueue.main.async {
			var objectVisible = false
			for object in self.virtualObjectManager.virtualObjects {
				if self.sceneView.isNode(object, insideFrustumOf: self.sceneView.pointOfView!) {
					objectVisible = true
					break
				}
			}
			
			if objectVisible {
				self.focusSquare?.hide()
			} else {
				self.focusSquare?.unhide()
			}
			
            let (worldPos, planeAnchor, _) = self.virtualObjectManager.worldPositionFromScreenPosition(screenCenter,
                                                                                                       in: self.sceneView,
                                                                                                       objectPos: self.focusSquare?.simdPosition)
			if let worldPos = worldPos {
				self.serialQueue.async {
					self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
				}
				self.textManager.cancelScheduledMessage(forType: .focusSquare)
			}
		}
	}
    
	// MARK: - Error handling
	
	func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
		// Blur the background.
		textManager.blurBackground()
		
		if allowRestart {
			// Present an alert informing about the error that has occurred.
			let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
				self.textManager.unblurBackground()
				self.restartExperience(self)
			}
			textManager.showAlert(title: title, message: message, actions: [restartAction])
		} else {
			textManager.showAlert(title: title, message: message, actions: [])
		}
	}
    
}
