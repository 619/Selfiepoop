//
//  closeKeyboard.swift
//  Firebase podtest
//
//  Created by Bobby Zhang on 2017-09-16.
//  Copyright © 2017 bobby. All rights reserved.
//

import Foundation
import UIKit

extension ARViewController {
    func hideViewIfDone() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.dismissView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissView() {
        view.isHidden = true
    }
}
