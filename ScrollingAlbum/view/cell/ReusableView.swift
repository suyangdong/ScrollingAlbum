//
//  ReusableView.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/24/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension HDCollectionViewCell: ReusableView {}
extension ThumbnailCollectionViewCell: ReusableView {}
