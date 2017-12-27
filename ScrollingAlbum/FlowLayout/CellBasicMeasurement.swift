//
//  CellBasicConfiguration.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol CellBasicMeasurement: class {
    var currentCellIndex: Int { get }
}

extension CellBasicMeasurement where Self: UICollectionViewLayout {
    var cellMaximumWidth: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellMaximumWidth
    }
    
    func cellFullWidth(for indexPath: IndexPath) -> CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellSize(for: indexPath)?.width ?? 0
    }
    
    var cellFullSpacing: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellFullSpacing
    }
    
    var cellNormalWidth: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellNormalWidth
    }
    
    var cellNormalSpacing: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellNormalSpacing
    }
    
    var cellNormalWidthAndSpacing: CGFloat {
        return cellNormalWidth + cellNormalSpacing
    }
    
    var cellNormalSize: CGSize {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return CGSize.zero }
        return CGSize(width:collectionView.cellNormalWidth, height:collectionView.cellHeight)
    }
    
    var cellHeight: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellHeight
    }
    
    var cellCount: Int {
        return collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0)
    }
}
