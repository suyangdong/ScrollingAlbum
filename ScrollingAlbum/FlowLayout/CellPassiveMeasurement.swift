//
//  CellPassiveMeasurement.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/29/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol CellPassiveMeasurement {
    var puppetCellIndex: Int { get set }
    var puppetFractionComplete: CGFloat { get set }
    var unitStepOfPuppet: CGFloat { get }
}
