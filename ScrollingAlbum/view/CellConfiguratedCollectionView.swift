//
//  CellConfiguratedCollectionView.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

public protocol CellConfiguration {
    var cellMaximumWidth: CGFloat! { get set }
    var cellNormalWidth: CGFloat! { get set }
    var cellFullSpacing: CGFloat! { get set }
    var cellNormalSpacing: CGFloat! { get set }
    var cellHeight: CGFloat! { get set }
    func cellSize(for indexPath:IndexPath) -> CGSize?
}

protocol CollectionViewCellSize {
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize?
}

class CellConfiguratedCollectionView: UICollectionView, CellConfiguration{
    var cellSize: CollectionViewCellSize?
    public func cellSize(for indexPath: IndexPath) -> CGSize? {
        return cellSize?.collectionView(self, sizeForItemAt:indexPath)
    }
    public var cellMaximumWidth: CGFloat!
    public var cellNormalWidth: CGFloat!
    public var cellFullSpacing: CGFloat!
    public var cellNormalSpacing: CGFloat!
    public var cellHeight: CGFloat!
}
