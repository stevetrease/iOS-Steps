//
//  UIViewExtension.swift
//  iOS Steps
//
//  Created by Steve on 24/05/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit


// snapshot UIView into a UIImage
extension UIView {
    func snapShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

// extension to allow a view to be duplicated
extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}
