//
//  HDFlowLayout.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

class HDFlowLayout: UICollectionViewFlowLayout {
    var cellMaximumWidth: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellMaximumWidth
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
    
    var cellMaximumHeight: CGFloat {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return 0 }
        return collectionView.cellHeight
    }
    
    var cellCount: Int {
        return collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0)
    }
    
    fileprivate func cellIndex(at offset: CGFloat) -> Int {
        return Int(offset / cellMaximumWidth)
    }
    
    fileprivate var currentOffset: CGFloat {
        return (collectionView!.contentOffset.x + collectionView!.contentInset.left)
    }
    
    fileprivate var currentCellIndex: Int {
        return min(cellCount - 1, Int(currentOffset / cellMaximumWidth))
    }
    
    fileprivate var currentFractionComplete: CGFloat {
        let relativeOffset = currentOffset / cellMaximumWidth
        return modf(relativeOffset).1
    }
    
    // MARK: - Stored Property
    fileprivate var cellEstimatedCenterPoints: [CGPoint] = []
    fileprivate var cellEstimatedFrames: [CGRect] = []
    var shouldLayoutEverything = true
    let minimumPhotoWidth: CGFloat = 40
}


//MARK: - UICollectionViewFlowLayout Override
extension HDFlowLayout {
    override func prepare() {
        
    }
    
    override var collectionViewContentSize: CGSize {
        let contentWidth = cellMaximumWidth * CGFloat(cellCount)
        let contentHeight = cellMaximumHeight
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        return allAttributes
    }
}

//MARK: - Invalidate Context

extension HDFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
