//
//  CustomSearchController.swift
//  Firebase podtest
//
//  Created by Bobby Zhang on 2017-09-07.
//  Copyright © 2017 bobby. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController {

  //  var customSearchBar: CustomSearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

//    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
//        super.init(searchResultsController: searchResultsController)
//        
//        configureSearchBar(frame: searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
//    }

//    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
//        customSearchBar = CustomSearchBar(frame: frame, font: font , textColor: textColor)
//
//        customSearchBar.barTintColor = bgColor
//        customSearchBar.tintColor = textColor
//        customSearchBar.showsBookmarkButton = false
//        customSearchBar.showsCancelButton = true
//    }
//
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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
