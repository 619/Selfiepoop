//
//  subCategoryCollectionView.swift
//  Firebase podtest
//
//  Created by Bobby Zhang on 2017-09-16.
//  Copyright © 2017 bobby. All rights reserved.
//

import UIKit

let objectArray = [#imageLiteral(resourceName: "lamp"), #imageLiteral(resourceName: "chair"), #imageLiteral(resourceName: "candle.png"), #imageLiteral(resourceName: "lamp"), #imageLiteral(resourceName: "cup")]
var selectedCategory = 0



class subCategoryCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate{
   
   // weak var AR_delegate: ARViewControllerDelegate?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectArray.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subCategoryCollectionViewCell", for: indexPath) as! ImageViewCell
        
      //  let image: UIImage? = UIImage(named: CollectionViewController.availableObjects[indexPath.row].modelName)
        let image: UIImage? = objectArray[indexPath.row]
        cell.cellImage.image = image
        cell.tintColor = UIColor.white
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if (indexPath.row == 0) {
//            AR_delegate?.changeObjectList(index: 0)
//            AR_delegate?.updateCollectionView()
//        } else if (indexPath.row == 1) {
//            AR_delegate?.changeObjectList(index: 1)
//            AR_delegate?.updateCollectionView()
//        } else if (indexPath.row == 2) {
//            AR_delegate?.changeObjectList(index: 2)
//            AR_delegate?.updateCollectionView()
//        } else if (indexPath.row == 3) {
//            AR_delegate?.changeObjectList(index: 3)
//            AR_delegate?.updateCollectionView()
//            } else if (indexPath.row == 4) {
//            AR_delegate?.changeObjectList(index: 4)
//            AR_delegate?.updateCollectionView()
//        } else {
//           AR_delegate?.changeObjectList(index: 5)
//           AR_delegate?.updateCollectionView()
//        }
//        
//        selectedCategory = indexPath.row
//        
//        
    }

    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
