//
//  UIViewExtension.swift
//  iOS Steps
//
//  Created by Steve on 24/05/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit



extension UIView {
    func snapShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
