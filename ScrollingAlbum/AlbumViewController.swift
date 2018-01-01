//
//  ViewController.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/23/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    // if enabled, will show a middle vertical line for debugging and indices of the photos
    var debug: Bool = false
    @IBOutlet weak var assistantMiddleLine: UIView!
    
    // dependency injection
    var hdPhotoModel: PhotoModel!
    var thumbnailPhotoModel: PhotoModel!
    var flowLayoutSyncManager: FlowLayoutSyncManager!
    
    var hdCollectionViewRatio: CGFloat = 0
    var thumbnailCollectionViewThinnestRatio: CGFloat = 0
    var thumbnailCollectionViewThickestRatio: CGFloat = 0
    let thumbnailMaximumWidth:CGFloat = 160
    
    @IBOutlet weak var hdCollectionView: CellConfiguratedCollectionView!
    @IBOutlet weak var thumbnailCollectionView: CellConfiguratedCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        assistantMiddleLine.isHidden = !debug
        
        setupHDCollectionView()
        setupThumbnailCollectionView()
        flowLayoutSyncManager.register(hdCollectionView)
        flowLayoutSyncManager.register(thumbnailCollectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let layout = thumbnailCollectionView.collectionViewLayout as? ThumbnailFlowLayoutDraggingBehavior {
            layout.unfoldCurrentCell()
        }
    }
    
    override func viewDidLayoutSubviews() {
        setupHDCollectionViewMeasurement()
        hdCollectionView.collectionViewLayout.invalidateLayout()
        setupThumbnailCollectionViewMeasurement()
        thumbnailCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    fileprivate func setupHDCollectionView() {
        hdCollectionView!.cellSize = self
        hdCollectionView.dataSource = self
        hdCollectionView.delegate = self
        hdCollectionView!.isPagingEnabled = true
        hdCollectionView!.decelerationRate = UIScrollViewDecelerationRateNormal;
        let layout = HDFlowLayout()
        layout.flowLayoutSyncManager = flowLayoutSyncManager
        hdCollectionView!.collectionViewLayout = layout
    }
    
    fileprivate func setupThumbnailCollectionView() {
        thumbnailCollectionView!.dataSource = self
        thumbnailCollectionView!.delegate = self
        thumbnailCollectionView!.cellSize = self
        thumbnailCollectionView!.alwaysBounceHorizontal = true
        thumbnailCollectionView!.collectionViewLayout = ThumbnailSlaveFlowLayout()
    }
    
    fileprivate func setupHDCollectionViewMeasurement() {
        hdCollectionView.cellFullSpacing = 100
        hdCollectionView.cellNormalWidth = hdCollectionView!.bounds.size.width - hdCollectionView.cellFullSpacing
        hdCollectionView.cellMaximumWidth = hdCollectionView!.bounds.size.width
        hdCollectionView.cellNormalSpacing = 0
        hdCollectionView.cellHeight = hdCollectionView.bounds.size.height
        hdCollectionViewRatio = hdCollectionView.frame.size.height / hdCollectionView.frame.size.width
        if var layout = hdCollectionView.collectionViewLayout as? FlowLayoutInvalidateBehavior {
            layout.shouldLayoutEverything = true
        }
    }
    
    fileprivate func setupThumbnailCollectionViewMeasurement() {
        thumbnailCollectionView.cellNormalWidth = 30
        thumbnailCollectionView.cellFullSpacing = 15
        thumbnailCollectionView.cellNormalSpacing = 2
        thumbnailCollectionView.cellHeight = thumbnailCollectionView.frame.size.height
        thumbnailCollectionView.cellMaximumWidth = thumbnailMaximumWidth
        thumbnailCollectionViewThinnestRatio = thumbnailCollectionView.cellHeight / thumbnailCollectionView.cellNormalWidth
        thumbnailCollectionViewThickestRatio = thumbnailCollectionView.cellHeight / thumbnailMaximumWidth
        if var layout = hdCollectionView.collectionViewLayout as? FlowLayoutInvalidateBehavior {
            layout.shouldLayoutEverything = true
        }
    }
}

//MARK: UICollectionViewDataSource

extension AlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case hdCollectionView:
            return hdPhotoModel.numberOfPhotos()
        case thumbnailCollectionView:
            return thumbnailPhotoModel.numberOfPhotos()
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case thumbnailCollectionView:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as ThumbnailCollectionViewCell
            if let image = thumbnailPhotoModel.photo(at: indexPath.row, debug:debug),
                let size = self.collectionView(thumbnailCollectionView, sizeForItemAt: indexPath) {
                cell.photoViewWidthConstraint.constant = size.width
                cell.clipsToBounds = true
                cell.photoView?.contentMode = .scaleAspectFill
                cell.photoView?.image = image
            }
            
            return cell
        case hdCollectionView:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as HDCollectionViewCell
            if let image = hdPhotoModel.photo(at: indexPath.item, debug:debug),
                let size = self.collectionView(hdCollectionView, sizeForItemAt: indexPath)  {
                cell.photoViewWidthConstraint.constant = size.width
                cell.photoViewHeightConstraint.constant = size.height
                cell.clipsToBounds = true
                cell.photoView?.contentMode = .scaleAspectFill
                cell.photoView?.image = image
            }
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

//MARK：- CollectionView Delegate
extension AlbumViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            flowLayoutSyncManager.masterCollectionView = collectionView
            if let layout = collectionView.collectionViewLayout as? ThumbnailFlowLayoutDraggingBehavior {
                layout.foldCurrentCell()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView,
            let layout = collectionView.collectionViewLayout as? ThumbnailFlowLayoutDraggingBehavior{
            layout.unfoldCurrentCell()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate,
            let collectionView = scrollView as? UICollectionView,
            let layout = collectionView.collectionViewLayout as? ThumbnailFlowLayoutDraggingBehavior{
            layout.unfoldCurrentCell()
        }
    }
}

//MARK: - CollectionViewCellSize Protocol
extension AlbumViewController: CollectionViewCellSize {
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize? {
        switch collectionView {
        case hdCollectionView:
            if let size = hdPhotoModel.photoSize(at: indexPath.row) {
                return cellSize(forHDImage: size)
            }
        case thumbnailCollectionView:
            if let size = thumbnailPhotoModel.photoSize(at: indexPath.row) {
                return cellSize(forThumbImage: size)
            }
        default:
            return nil
        }
        return nil
    }
    
    fileprivate func cellSize(forHDImage size: CGSize) -> CGSize? {
        let ratio = size.height / size.width
        if (ratio < hdCollectionViewRatio) {
            return CGSize(width: hdCollectionView.frame.size.width, height: hdCollectionView.frame.size.width * ratio)
        } else {
            return CGSize(width: hdCollectionView.frame.size.height / ratio, height: hdCollectionView.frame.size.height)
        }
    }
    
    fileprivate func cellSize(forThumbImage size: CGSize) -> CGSize? {
        let ratio = size.height / size.width
        if (ratio > thumbnailCollectionViewThinnestRatio) {
            return CGSize(width: thumbnailCollectionView.cellNormalWidth, height: thumbnailCollectionView.cellHeight)
        } else if ratio < thumbnailCollectionViewThickestRatio {
            return CGSize(width: thumbnailCollectionView.cellMaximumWidth, height: thumbnailCollectionView.cellHeight)
        } else {
            return CGSize(width: thumbnailCollectionView.frame.size.height / ratio, height: thumbnailCollectionView.frame.size.height)
        }
    }
}
