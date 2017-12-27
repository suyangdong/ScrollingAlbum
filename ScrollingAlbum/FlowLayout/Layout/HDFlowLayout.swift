//
//  HDFlowLayout.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

class HDFlowLayout: UICollectionViewFlowLayout, CellBasicMeasurement {
    
    fileprivate func cellIndex(at offset: CGFloat) -> Int {
        return Int(offset / cellMaximumWidth)
    }
    
    fileprivate var currentOffset: CGFloat {
        return (collectionView!.contentOffset.x + collectionView!.contentInset.left)
    }
    
    var currentCellIndex: Int {
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
        guard shouldLayoutEverything else { return }
        
        cellEstimatedCenterPoints = []
        cellEstimatedFrames = []
        for itemIndex in 0 ..< cellCount {
            var cellCenter: CGPoint = CGPoint(x: 0, y: 0)
            cellCenter.y = collectionView!.frame.size.height / 2.0
            cellCenter.x = cellMaximumWidth * CGFloat(itemIndex) + cellMaximumWidth  / 2.0
            cellEstimatedCenterPoints.append(cellCenter)
            cellEstimatedFrames.append(CGRect.init(origin: CGPoint.init(x: cellMaximumWidth * CGFloat(itemIndex), y: 0), size: CGSize.init(width: cellMaximumWidth, height: cellHeight)))
        }
        shouldLayoutEverything = false
    }
    
    override var collectionViewContentSize: CGSize {
        let contentWidth = cellMaximumWidth * CGFloat(cellCount)
        let contentHeight = cellHeight
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        let relativeOffset = currentOffset / cellMaximumWidth
        let fractionComplete = max(0, modf(relativeOffset).1)
        switch indexPath.item {
        case currentCellIndex:
            if let collectionView = collectionView as? CellConfiguratedCollectionView,
                let cellSize = collectionView.cellSize(for: indexPath) {
                
                attributes.size = CGSize(width: max(minimumPhotoWidth, cellSize.width - cellFullSpacing * fractionComplete), height: cellSize.height)
                attributes.center = cellEstimatedCenterPoints[indexPath.row]
            }
        case currentCellIndex + 1:
            if let collectionView = collectionView as? CellConfiguratedCollectionView,
                let cellSize = collectionView.cellSize(for: indexPath) {
                
                attributes.size = CGSize(width: max(minimumPhotoWidth, cellSize.width - cellFullSpacing * (1-fractionComplete)), height: cellSize.height)
                attributes.center = cellEstimatedCenterPoints[indexPath.row]
            }
        default:
            attributes.size = CGSize(width: cellMaximumWidth, height: cellHeight)
            attributes.center = cellEstimatedCenterPoints[indexPath.row]
        }
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for itemIndex in 0 ..< cellCount {
            if rect.intersects(cellEstimatedFrames[itemIndex]) {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = layoutAttributesForItem(at: indexPath)!
                allAttributes.append(attributes)
            }
        }
        return allAttributes
    }
}


//MARK: - Invalidate Context

extension HDFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        if newBounds.size != collectionView!.bounds.size {
            shouldLayoutEverything = true
        }
        return context
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            shouldLayoutEverything = true
        }
        super.invalidateLayout(with: context)
    }
}

