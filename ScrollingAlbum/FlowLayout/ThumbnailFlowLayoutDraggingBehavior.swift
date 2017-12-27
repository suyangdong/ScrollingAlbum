//
//  ThumbnailFlowLayout.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol ThumbnailFlowLayoutDraggingBehavior {
    func foldCurrentCell()
    func unfoldCurrentCell()
}
