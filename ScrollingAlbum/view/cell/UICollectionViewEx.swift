//
//  UICollectionViewEx.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/24/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
}
