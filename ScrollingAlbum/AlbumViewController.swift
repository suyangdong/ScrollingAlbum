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
    
    @IBOutlet weak var hdCollectionView: UICollectionView!
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        assistantMiddleLine.isHidden = !debug
        thumbnailCollectionView.dataSource = self
        hdCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        // set up the basic attributes such as itemSize and spacing.
        if let layout = hdCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = hdCollectionView.frame.size
            layout.minimumLineSpacing = 0
        }
        if let layout = thumbnailCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 30, height: 48)
            layout.minimumLineSpacing = 2
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
        case
        thumbnailCollectionView:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as ThumbnailCollectionViewCell
            if let image = thumbnailPhotoModel.photo(at: indexPath.row, debug:debug) {
                cell.photoViewWidthConstraint.constant = 64
                cell.photoView?.image = image
            }
            
            return cell
        case hdCollectionView:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as HDCollectionViewCell
            if let image = hdPhotoModel.photo(at: indexPath.item, debug:debug) {
                cell.photoViewWidthConstraint.constant = hdCollectionView.bounds.size.width
                cell.photoViewHeightConstraint.constant = hdCollectionView.bounds.size.height
                cell.photoView?.image = image
            }
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

