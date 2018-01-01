//
//  FlowLayoutSyncProtocol.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/28/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

protocol FlowLayoutSync {
    func register(_ collectionView: UICollectionView)
    var masterCollectionView: UICollectionView? { get set }
    func didMove(_ collectionView: UICollectionView, to indexPath:IndexPath, with fractionComplete: CGFloat)
}

class FlowLayoutSyncManager: FlowLayoutSync {

    var collectionViews = Set<CellConfiguratedCollectionView>()
    var exSlave: CellConfiguratedCollectionView?
    
    func didMove(_ collectionView: UICollectionView, to indexPath: IndexPath, with fractionComplete: CGFloat) {
        if isHdMaster,
            let slave = slaveCollectionView {
            setThumbnailContentOffset(slave, indexPath, fractionComplete)
        } else if !isHdMaster,
            let slave = slaveCollectionView {
            setHDContentOffset(slave, indexPath)
        }
    }
    
    var masterCollectionView: UICollectionView? {
        didSet {
            guard !isSlaveNotChanged else { return }
            if (isHdMaster) {
                switchThumbnailToSlave()
            } else {
                switchThumbnailToMaster()
            }
        }
    }
    
    func register(_ collectionView: UICollectionView) {
        guard let collectionView = collectionView as? CellConfiguratedCollectionView else { return }
        collectionViews.insert(collectionView)
    }
}


// MARK: - Helper
extension FlowLayoutSyncManager {
    
    fileprivate func switchThumbnailToSlave() {
        slaveCollectionView?.collectionViewLayout = ThumbnailSlaveFlowLayout()
    }
    
    fileprivate func switchThumbnailToMaster() {
        let newLayout = ThumbnailMasterFlowLayout()
        newLayout.flowLayoutSyncManager = self
        newLayout.accordionAnimationManager = AcoordionAnimationManager()
        
        if let oldLayout = masterCollectionView?.collectionViewLayout as? CellPassiveMeasurement,
            let originalContentOffset = masterCollectionView?.contentOffset {
            newLayout.animatedCellIndex = oldLayout.puppetCellIndex
            masterCollectionView?.setCollectionViewLayout(newLayout, animated: false)
            masterCollectionView?.setContentOffset(originalContentOffset, animated: false)
        }
    }
    
    fileprivate func setHDContentOffset(_ slave: UICollectionView, _ indexPath: IndexPath) {
        if let slaveMeasurement = slave.collectionViewLayout as? CellBasicMeasurement {
            let slaveContentOffset = slaveMeasurement.cellMaximumWidth * (CGFloat(indexPath.item))
            slave.setContentOffset((CGPoint(x: slaveContentOffset - slave.contentInset.left, y:0)), animated: false)
        }
    }
    
    fileprivate func setThumbnailContentOffset(_ slave: CellConfiguratedCollectionView, _ indexPath: IndexPath, _ fractionComplete: CGFloat) {
        var slaveContentOffset:CGFloat = 0
        
        if let cellSize = slave.cellSize(for: indexPath),
            var slaveLayout = slave.collectionViewLayout as? CellPassiveMeasurement {
            if fractionComplete < 0 {
                slaveContentOffset = cellSize.width * fractionComplete
            } else {
                slaveContentOffset = slaveLayout.unitStepOfPuppet * (CGFloat(indexPath.item) + fractionComplete)
                slaveLayout.puppetCellIndex = indexPath.item
                slaveLayout.puppetFractionComplete = fractionComplete
            }
            slave.setContentOffset(CGPoint(x: slaveContentOffset - slave.contentInset.left, y: 0), animated: false)
        }
    }
    
    // MARK: - Computed Property
    
    fileprivate var isSlaveNotChanged: Bool {
        if let slave = slaveCollectionView,
            slave != exSlave {
            exSlave = slave
            return false
        } else {
            return true
        }
    }
    
    fileprivate var isHdMaster: Bool {
        guard let slave = slaveCollectionView else { return false }
        return !(slave.collectionViewLayout is HDFlowLayout)
    }
    
    fileprivate var slaveCollectionView: CellConfiguratedCollectionView? {
        guard let master = masterCollectionView else { return nil }
        for view in collectionViews {
            if view != master{
                return view
            }
        }
        return nil
    }
}

