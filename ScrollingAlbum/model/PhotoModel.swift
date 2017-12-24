//
//  HDPhotoDataController.swift
//  PhotoScroller
//
//  Created by RippleArc on 10/24/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol PhotoModel {
    func numberOfPhotos() -> Int
    func photoName(at index:Int) -> String?
    mutating func photoSize(at index: Int) -> CGSize?
    func photo(at index:Int, debug: Bool) -> UIImage?
    func photo(at index:Int) -> UIImage?
}

struct PhotoCollection: PhotoModel {
    
    let photoNames: [String]
    var photoSizes: [String:CGSize] = [:]
    init(photos: [String]) {
        photoNames = photos
    }
    
    func numberOfPhotos() -> Int {
        return photoNames.count
    }
    
    func photoName(at index:Int) -> String? {
        guard index < photoNames.count else {
            return nil
        }
        return photoNames[index]
    }
    
    mutating func photoSize(at index: Int) -> CGSize? {
        guard let name = photoName(at:index), name != "" else {
            return nil
        }
        if let size = photoSizes[name] {
            return size
        } else {
            photoSizes[name] = photo(at: index)?.size
            return photoSizes[name]
        }
    }
    
    func photo(at index:Int) -> UIImage? {
        return photo(at: index, debug: false)
    }
    
    func photo(at index:Int, debug: Bool) -> UIImage? {
        guard let name = photoName(at:index), name != "" else {
            return nil
        }
        if debug {
            return UIImage.stamp(image: UIImage(named:name)!, with: "\(index)")
            
        } else {
            return UIImage(named:name)
        }
    }
}
