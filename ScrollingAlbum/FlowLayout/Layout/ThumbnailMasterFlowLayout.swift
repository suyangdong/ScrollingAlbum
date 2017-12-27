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

class ThumbnailMasterFlowLayout: UICollectionViewFlowLayout,  CellBasicMeasurement, CellAnimationMeasurement, FlowLayoutInvalidateBehavior {
    
    fileprivate var normalCenterPoints: [CGPoint] = []
    var shouldLayoutEverything = true
    
    var animatedCellType: AnimatedCellType = .folding
    
    // Dependency Injection
    var accordionAnimationManager: AccordionAnimation!
    
    var animatedCellIndex: Int = 0
    
    var originalInsetAndContentOffset: (CGFloat, CGFloat) = (0, 0)
    
    var currentCellIndex: Int {
        return min(cellCount-1, Int(currentOffset / cellNormalWidthAndSpacing))
    }
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
    }
}

//MARK: - UICollectionViewFlowLayout Override
extension ThumbnailMasterFlowLayout {
    override func prepare() {
        guard shouldLayoutEverything else { return }
        
        normalCenterPoints = []
        for itemIndex in 0 ..< cellCount {
            var cellCenter: CGPoint = CGPoint.zero
            cellCenter.y = cellMaximumHeight / 2.0
            cellCenter.x = CGFloat(itemIndex) * cellNormalWidthAndSpacing + cellNormalSpacing + cellNormalWidth / 2.0
            normalCenterPoints.append(cellCenter)
        }
        shouldLayoutEverything = false
    }
    
    override var collectionViewContentSize: CGSize {
        let contentWidth = 2 * adjacentSpacingOfAnimatedCell
            + animatedCellSize.width
            + fmax(0.0, CGFloat(cellCount - 1)) * cellNormalWidthAndSpacing
        
        return CGSize(width: contentWidth, height: cellMaximumHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
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
        return 0
    }
    
    fileprivate var contentNormalInset: CGFloat {
        return 0
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
        return CGPoint.zero
    }
    
    fileprivate var animatedCellCenter: CGPoint {
        return CGPoint.zero
    }
    
    fileprivate var adjacentSpacingOfAnimatedCell: CGFloat {
        return 0
    }
    
    fileprivate var animatedCellSize: CGSize {
        return CGSize.zero
    }
}
