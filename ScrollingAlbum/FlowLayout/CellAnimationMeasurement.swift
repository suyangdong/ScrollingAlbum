//
//  CellAnimationMeasurement.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol CellAnimationMeasurement {
    var animatedCellIndex: Int { get set}
    var originalInsetAndContentOffset: (CGFloat, CGFloat) { get set}
    var animatedCellType: AnimatedCellType { get set }
}
