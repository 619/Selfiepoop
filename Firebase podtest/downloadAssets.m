//
//  GameViewController.m changed to downloadAssets.m
//  PrototypeSceneKit
//
//  Created by Frederik Jacques on 07/11/14.
//  Copyright (c) 2014 Frederik Jacques. All rights reserved.
//

#import "downloadAssets.h"
#import "AFURLSessionManager.h"
//#import "SSZipArchive.h"

@implementation downloadAssets
- (instancetype)init
{
    self = [super init];
    if (self) {
         [self downloadZip];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Download zipfile
    [self downloadZip];
    
}
//-------------------STUFF UNDER NSLog(@"File downloaded to: %@", filePath); -----------------------
//  filePath    NSURL *    @"file:///var/mobile/Containers/Data/Application/C1EFA899-6955-49D0-B687-BF5129BEE09B/Documents/lamp.scn"    0x00000001c00adec0
// Load the downloaded scene

//        // Get reference to the cube node
//        SCNNode *theCube = [sceneSource entryWithIdentifier:@"Eyeball" withClass:[SCNNode class]];
//
//        // Create a new scene
//        SCNScene *scene = [SCNScene scene];
//
//        // create and add a camera to the scene
//        SCNNode *cameraNode = [SCNNode node];
//        cameraNode.camera = [SCNCamera camera];
//        [scene.rootNode addChildNode:cameraNode];
//
//        // place the camera
//        cameraNode.position = SCNVector3Make(0, 0, 15);
//
//        // create and add a light to the scene
//        SCNNode *lightNode = [SCNNode node];
//        lightNode.light = [SCNLight light];
//        lightNode.light.type = SCNLightTypeOmni;
//        lightNode.position = SCNVector3Make(0, 10, 10);
//        [scene.rootNode addChildNode:lightNode];
//
//        // create and add an ambient light to the scene
//        SCNNode *ambientLightNode = [SCNNode node];
//        ambientLightNode.light = [SCNLight light];
//        ambientLightNode.light.type = SCNLightTypeAmbient;
//        ambientLightNode.light.color = [UIColor darkGrayColor];
//        [scene.rootNode addChildNode:ambientLightNode];
//
//        // Add our cube to the scene
//        [scene.rootNode addChildNode:theCube];
//
//        // retrieve the SCNView
//        SCNView *scnView = (SCNView *)self.view;
//
//        // set the scene to the view
//        scnView.scene = scene;
//
//        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = YES;
//
//        // show statistics such as fps and timing information
//        scnView.showsStatistics = YES;
//
//        // configure the view
//        scnView.backgroundColor = [UIColor blackColor];
//
//        // add a tap gesture recognizer
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//        NSMutableArray *gestureRecognizers = [NSMutableArray array];
//        [gestureRecognizers addObject:tapGesture];
//        [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
//        scnView.gestureRecognizers = gestureRecognizers;


// Unzip the archive
//        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *inputPath = [documentsDirectory stringByAppendingPathComponent:@"/product-1-optimized.scnassets.zip"];
//
//        NSError *zipError = nil;
//
//        [SSZipArchive unzipFileAtPath:inputPath toDestination:documentsDirectory overwrite:YES password:nil error:&zipError];
//
//        if( zipError ){
//            NSLog(@"[GameVC] Something went wrong while unzipping: %@", zipError.debugDescription);
//        }else {
//            NSLog(@"[GameVC] Archive unzipped successfully");
//            [self startScene];
//        }



- (void) downloadZip {
   
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/son-of-database.appspot.com/o/test%2Fmissile1.dae?alt=media&token=ea28d59c-015a-4c49-9e16-a02e0d12b5d2"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"missile1.dae"];
        
        SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:documentsDirectoryURL options:nil];
     //   NSLog(@"This is the sceneSource: %@", sceneSource);
    //    printf("HELLO!");
  //   printf("This is the URL!!!!!: %", filePath);
  //      NSString *myString = filePath.absoluteString;

       // printf(myString);
    }];
    [downloadTask resume];
    
    NSURLSessionConfiguration *configuration1 = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager1 = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration1];
    NSURL *URL1 = [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/son-of-database.appspot.com/o/test%2FTexture.png?alt=media&token=aaefc7cd-f697-4395-a271-473050de5787"];
    NSURLRequest *request1 = [NSURLRequest requestWithURL:URL1];
    
    NSURLSessionDownloadTask *downloadTask1 = [manager downloadTaskWithRequest:request1 progress:nil destination:^NSURL *(NSURL *targetPath1, NSURLResponse *response1) {
        NSURL *documentsDirectoryURL1 = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
      //  NSURL *documentsDirectoryURL11 = [documentsDirectoryURL1 URLByAppendingPathComponent:@"textures"];
        return [documentsDirectoryURL1 URLByAppendingPathComponent:@"Texture.png"];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath1, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath1);
        
    }];
    [downloadTask1 resume];
    
    
//    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"missile.dae"];
    
//    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:documentsDirectoryURL options:nil];
//    NSLog(@"This is the sceneSource: %@", sceneSource);
    
}


- (void)startScene {
   //    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"eyeball1.dae"];
//
//    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:documentsDirectoryURL options:nil];

}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
