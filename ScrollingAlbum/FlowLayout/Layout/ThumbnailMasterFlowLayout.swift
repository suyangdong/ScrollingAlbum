//
//  ThumbnailMasterFlowLayout.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

enum AnimatedCellType {
    case folding
    case unfolding
}

class ThumbnailMasterFlowLayout: UICollectionViewFlowLayout,  CellBasicMeasurement, CellAnimationMeasurement {
    
    fileprivate var normalCenterPoints: [CGPoint] = []
    var shouldLayoutEverything = true
    
    var animatedCellType: AnimatedCellType = .folding
    
    // Dependency Injection
    var accordionAnimationManager: AccordionAnimation!
    var flowLayoutSyncManager: FlowLayoutSync!
    
    var animatedCellIndex: Int = 0
    
    var originalInsetAndContentOffset: (CGFloat, CGFloat) = (0, 0) {
        didSet {
            if animatedCellType == .unfolding {
                unfoldingCenterOffset = originalInsetAndContentOffset.0 + originalInsetAndContentOffset.1 + cellNormalWidthAndSpacing / 2 - normalCenterPoints[currentCellIndex].x
            }
        }
    }
    
    var currentCellIndex: Int {
        return min(cellCount-1, Int(currentOffset / cellNormalWidthAndSpacing))
    }
    
    fileprivate var unfoldingCenterOffset: CGFloat = 0
}

//MARK: - ThumbnailFlowLayout
extension ThumbnailMasterFlowLayout: ThumbnailFlowLayoutDraggingBehavior {
    func foldCurrentCell() {
        startAnimation(of: .folding)
    }
    
    func unfoldCurrentCell() {
        startAnimation(of: .unfolding)
    }
    
    fileprivate func startAnimation(of type:AnimatedCellType) {
        accordionAnimationManager.startAnimation(collectionView!, animationType: type, cellLength: cellFullWidth(for: animatedCellIndexPath), onProgress: { [weak self] _  in
            if let strongSelf = self {
                strongSelf.onAnimationUpdate(of: type)
            }
        })
    }
    
    fileprivate func onAnimationUpdate(of type: AnimatedCellType) {
        invalidateLayout()
        
        setContentInset()
        if type == .unfolding {
            setContentOffset()
        }
    }
}

//MARK: - UICollectionViewFlowLayout Override
extension ThumbnailMasterFlowLayout {
    override func prepare() {
        guard shouldLayoutEverything else { return }
        
        normalCenterPoints = []
        for itemIndex in 0 ..< cellCount {
            var cellCenter: CGPoint = CGPoint.zero
            cellCenter.y = cellHeight / 2.0
            cellCenter.x = CGFloat(itemIndex) * cellNormalWidthAndSpacing + cellNormalSpacing + cellNormalWidth / 2.0
            normalCenterPoints.append(cellCenter)
        }
        shouldLayoutEverything = false
    }
    
    override var collectionViewContentSize: CGSize {
        let contentWidth = 2 * adjacentSpacingOfAnimatedCell
            + animatedCellSize.width
            + fmax(0.0, CGFloat(cellCount - 1)) * cellNormalWidthAndSpacing
        
        return CGSize(width: contentWidth, height: cellHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        if indexPath.item < animatedCellIndex {
            attributes.size = cellNormalSize
            attributes.center = normalCenterPoints[indexPath.item]
        } else if indexPath.item > animatedCellIndex {
            attributes.size = cellNormalSize
            attributes.center = centerAfterAnimatedCell(for: indexPath)
        } else {
            attributes.size = animatedCellSize
            attributes.center = animatedCellCenter
        }
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        flowLayoutSyncManager.didMove(collectionView!, to: IndexPath(item:currentCellIndex, section:0),  with: 0)
        
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for itemIndex in 0 ..< cellCount {
            if rect.contains(normalCenterPoints[itemIndex]) {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = layoutAttributesForItem(at: indexPath)!
                allAttributes.append(attributes)
            }
        }
        
        return allAttributes
    }
    
    fileprivate func setContentInset() {
        collectionView!.contentInset.left = symmetricContentInset
        collectionView!.contentInset.right = symmetricContentInset
    }
    
    fileprivate func setContentOffset() {
        if accordionAnimationManager.progress() < 1,
            accordionAnimationManager.progress() > 0 {
            let insetOffset = symmetricContentInset - originalInsetAndContentOffset.0
            var cellCenterOffset: CGFloat = 0
            if animatedCellType == .unfolding {
                cellCenterOffset = unfoldingCenterOffset * accordionAnimationManager.progress()
            }
            collectionView!.contentOffset.x = originalInsetAndContentOffset.1 - insetOffset - cellCenterOffset
        }
    }
}

//MARK: - Invalidate Context
extension ThumbnailMasterFlowLayout {
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

// MARK: - Computed Property

extension ThumbnailMasterFlowLayout {
    
    fileprivate var symmetricContentInset: CGFloat{
        return collectionView!.superview!.frame.size.width / 2.0
            - adjacentSpacingOfAnimatedCell
            - animatedCellSize.width / 2
        
    }
    
    fileprivate var currentOffset: CGFloat {
        return (collectionView!.contentOffset.x + collectionView!.contentInset.left + cellNormalWidthAndSpacing / 2)
    }
}

// MARK: - Cell Center and Size

extension ThumbnailMasterFlowLayout {
    
    fileprivate var animatedCellIndexPath: IndexPath {
        return IndexPath(item: animatedCellIndex, section: 0)
    }
    
    fileprivate func centerAfterAnimatedCell(for indexPath: IndexPath) -> CGPoint {
        guard indexPath.item > animatedCellIndexPath.item else { return CGPoint.zero }
        return CGPoint(x: animatedCellCenter.x
            + animatedCellSize.width / 2.0
            + adjacentSpacingOfAnimatedCell
            + cellNormalWidthAndSpacing * fmax(0, CGFloat(indexPath.item - animatedCellIndex - 1))
            + cellNormalWidth / 2,
                       y: cellHeight / 2)
    }
    
    fileprivate var animatedCellCenter: CGPoint {
        return CGPoint(x: CGFloat(animatedCellIndex) * cellNormalWidthAndSpacing + adjacentSpacingOfAnimatedCell + animatedCellSize.width / 2,y: cellHeight / 2)
    }
    
    fileprivate var adjacentSpacingOfAnimatedCell: CGFloat {
        return (cellFullSpacing - cellNormalSpacing) *  accordionAnimationManager.progress() + cellNormalSpacing
    }
    
    fileprivate var animatedCellSize: CGSize {
        return CGSize(width: (cellFullWidth(for: animatedCellIndexPath) - cellNormalWidth) *  accordionAnimationManager.progress() + cellNormalWidth, height: cellHeight)
    }
}
