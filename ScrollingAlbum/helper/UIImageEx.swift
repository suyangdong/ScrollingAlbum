//
//  UIImage.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/24/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func stamp(image:UIImage, with index:String) -> UIImage {
        let imageView: UIImageView = UIImageView.init(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addSubview(labelStamp(from: index, frame: CGRect(x: image.size.width*0.375, y: image.size.height*0.375, width: image.size.width/4.0, height: image.size.height/4.0)))
        return UIImage.imageWithImageView(imageView: imageView)
    }
    
    class func labelStamp(from index:String, frame:CGRect) -> UILabel {
        let labelView: UILabel = UILabel.init(frame: frame)
        let sizeOfFont = frame.size.width > 200 ? 320 : 32
        labelView.font = UIFont(name: "HelveticaNeue", size: CGFloat(sizeOfFont) )
        labelView.text = index
        labelView.textColor = UIColor.black
        labelView.textAlignment = .center
        labelView.backgroundColor = UIColor.white
        
        return labelView
    }
 
    class func imageWithImageView(imageView: UIImageView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage()}
        UIGraphicsEndImageContext()
        return img
    }
}

