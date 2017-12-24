//
//  HDCollectionViewCell.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/24/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

class HDCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoViewWidthConstraint: NSLayoutConstraint!
}
