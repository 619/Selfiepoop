//
//  CollectionViewController.swift
//  Firebase podtest
//
//  Created by Bobby Zhang on 2017-09-16.
//  Copyright © 2017 bobby. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
     func collectionView(_ collectionViewFunc: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
        
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectorCollectionViewCell", for: indexPath) as! SelectorCollectionViewCell
        let thumbUrl = Bundle.main.url(forResource: CollectionViewController.availableObjects[indexPath.row].modelName, withExtension: "png")
        let path:String = thumbUrl!.path
        cell.cellImage.image = UIImage(named: path)
       return cell
    }
    
    static let availableObjects: [VirtualObjectDefinition] = {
        guard let jsonURL = Bundle.main.url(forResource: "ObjectList1", withExtension: "json")
            else { fatalError("missing expected VirtualObjects.json in bundle") }
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode([VirtualObjectDefinition].self, from: jsonData)
        } catch {
            fatalError("can't load virtual objects JSON: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
