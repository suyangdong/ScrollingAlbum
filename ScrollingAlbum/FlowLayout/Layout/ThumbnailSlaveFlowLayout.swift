//
//  ThumbnailSlaveFlowLayout.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/29/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

class ThumbnailSlaveFlowLayout: UICollectionViewFlowLayout, CellBasicMeasurement, CellPassiveMeasurement {
    
    //MARK: - CellBasicMeasurement
    var currentCellIndex: Int = 0
    
    //MARK: - CellPassiveMeasurement
    var puppetCellIndex: Int = 0
    var puppetFractionComplete: CGFloat = 0
    var unitStepOfPuppet: CGFloat {
        return cellNormalWidth + cellNormalSpacing
    }
    
    //MARK: - Stored Property
    fileprivate var estimatedCenterPoints: [CGPoint] = []
    var shouldLayoutEverything = true
    
    // MARK: - Layout Overrides
    override func prepare() {
        estimatedCenterPoints = []
        for itemIndex in 0 ..< cellCount {
            var cellCenter: CGPoint = CGPoint.zero
            cellCenter.y = cellHeight / 2.0
            cellCenter.x = CGFloat(itemIndex) * cellNormalWidthAndSpacing + cellNormalSpacing + cellNormalWidth / 2.0
            estimatedCenterPoints.append(cellCenter)
        }
        shouldLayoutEverything = false
    }
    
    override var collectionViewContentSize: CGSize {
        let contentWidth = 2 * cellFullSpacing
            + focusedCellSize.width
            + nextFocusedCellSize.width
            + fmax(0.0, CGFloat(cellCount - 2)) * cellNormalWidthAndSpacing
            + cellNormalSpacing
        
        return CGSize(width: contentWidth, height: cellHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        if indexPath.item < puppetCellIndex {
            attributes.size = cellNormalSize
            attributes.center = estimatedCenterPoints[indexPath.item]
        } else if indexPath.item > puppetCellIndex + 1 {
            attributes.size = cellNormalSize
            attributes.center = centerAfterNextFocusedCell(for: indexPath)
        } else if indexPath.item == puppetCellIndex {
            attributes.size = focusedCellSize
            attributes.center = focusedCellCenter
        } else if indexPath.item == puppetCellIndex + 1 {
            attributes.size = nextFocusedCellSize
            attributes.center = nextFocusedCellCenter
        }
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        setCollectionViewInset()
        
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for itemIndex in 0 ..< cellCount {
            if rect.contains(estimatedCenterPoints[itemIndex]) ||
                rect.contains(estimatedCenterPoints[itemIndex]){
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = layoutAttributesForItem(at: indexPath)!
                allAttributes.append(attributes)
            }
        }
        return allAttributes
    }
}

//MARK: - Invalidate Context
extension ThumbnailSlaveFlowLayout {
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
    
    fileprivate func centerAfterNextFocusedCell(for indexPath: IndexPath) -> CGPoint {
        guard (indexPath.item > next(to: currentIndexPath).item) else { return CGPoint.zero }
        return CGPoint(x: nextFocusedCellCenter.x
            + nextFocusedCellSize.width / 2
            + rightSpacingOfNextFocusedCell
            + cellNormalWidthAndSpacing * CGFloat(indexPath.item - puppetCellIndex - 2)
            + cellNormalWidth / 2,
                       y: nextFocusedCellCenter.y)
    }
    
    fileprivate func setCollectionViewInset() {
        let inset = collectionView!.superview!.frame.size.width / 2.0
            - cellFullSpacing
            - (focusedCellSize.width + nextFocusedCellSize.width - cellNormalWidth) / 2
        collectionView!.contentInset.left = inset
        collectionView!.contentInset.right = inset
    }
}


// MARK: - Helper

extension ThumbnailSlaveFlowLayout {
    
    fileprivate var currentIndexPath: IndexPath {
        return IndexPath(item:puppetCellIndex, section: 0)
    }
    
    fileprivate var leftSpacingOfFocusedCell: CGFloat {
        return (cellFullSpacing - cellNormalSpacing) * (1 - puppetFractionComplete) + cellNormalSpacing
    }
    
    fileprivate var rightSpacingOfNextFocusedCell: CGFloat {
        return cellFullSpacing + cellNormalSpacing - leftSpacingOfFocusedCell
    }
    
    fileprivate var focusedCellSize: CGSize {
        if puppetFractionComplete < 0 {
            return CGSize(width: cellFullWidth(for:currentIndexPath), height: cellHeight)
        } else {
            return CGSize(width: (cellFullWidth(for:currentIndexPath) - cellNormalWidth) * (1 - puppetFractionComplete) + cellNormalWidth, height:cellHeight)
        }
    }
    
    fileprivate var focusedCellCenter: CGPoint {
        if puppetFractionComplete < 0 {
            return CGPoint(x: cellFullSpacing + cellFullWidth(for:currentIndexPath) / 2, y: cellHeight / 2)
        } else {
            return CGPoint(x: CGFloat(puppetCellIndex) * cellNormalWidthAndSpacing
                + leftSpacingOfFocusedCell
                + focusedCellSize.width / 2, y: cellHeight / 2)
        }
    }
    
    fileprivate var nextFocusedCellSize: CGSize {
        return CGSize(width: (cellFullWidth(for:next(to: currentIndexPath)) - cellNormalWidth) * puppetFractionComplete + cellNormalWidth, height: cellHeight)
    }
    
    fileprivate var nextFocusedCellCenter: CGPoint {
        return CGPoint(x: focusedCellCenter.x
            + focusedCellSize.width / 2
            + nextFocusedCellSize.width / 2
            + cellFullSpacing, y: cellHeight / 2)
    }
    
    fileprivate func prev(to indexPath: IndexPath) -> IndexPath{
        if indexPath.item > 0 {
            return IndexPath(item: indexPath.item - 1, section: 0)
        } else {
            return indexPath
        }
    }
    
    fileprivate func next(to indexPath: IndexPath) -> IndexPath{
        return IndexPath(item: indexPath.item + 1, section: 0)
    }
}
