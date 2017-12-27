//
//  FlowLayoutAnimationProgressManager.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/25/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

typealias timerHandler = (Timer)  -> Void

protocol AccordionAnimation {
    mutating func startAnimation(_ collectionView: UICollectionView, animationType: AnimatedCellType, cellLength: CGFloat, onProgress: @escaping timerHandler)
    func progress() -> CGFloat
}

struct AcoordionAnimationManager: AccordionAnimation {
    var animationMinimumDuration: TimeInterval = 0.25
    var cellBaseLength:CGFloat = 80
    
    fileprivate var timer: Timer?
    fileprivate var animationType: AnimatedCellType = .folding
    fileprivate var animationStartTime: TimeInterval = 0
    fileprivate var cellLength: CGFloat = 0
    fileprivate var timeInterval: TimeInterval = 0.02
    
    mutating func startAnimation(_ collectionView: UICollectionView, animationType: AnimatedCellType, cellLength: CGFloat, onProgress block: @escaping timerHandler) {
        
        self.animationType = animationType
        self.cellLength = cellLength
        self.animationStartTime = Date().timeIntervalSince1970
        
        setupCollectionViewForAnimation(collectionView)
        
        startTimer(onProgress:block)
    }
    
    func progress() -> CGFloat {
        let currentTime = Date().timeIntervalSince1970
        switch animationType {
        case .folding:
            return foldingAnimationProgress(currentTime)
        case .unfolding:
            return unfoldingAnimationProgress(currentTime)
        }
    }
    
    fileprivate func setupCollectionViewForAnimation(_ collectionView: UICollectionView) {
        if let basicMeasurement = collectionView.collectionViewLayout as? CellBasicMeasurement,
            var animationMeasurement = collectionView.collectionViewLayout as? CellAnimationMeasurement {
            animationMeasurement.animatedCellType = animationType
            animationMeasurement.originalInsetAndContentOffset = (collectionView.contentInset.left , collectionView.contentOffset.x)
            
            animationMeasurement.animatedCellIndex = basicMeasurement.currentCellIndex
        }
    }
    
    mutating fileprivate func startTimer(onProgress: @escaping timerHandler) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: onProgress)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .commonModes)
        }
    }
    
    fileprivate func endTimer() {
        timer?.invalidate()
    }
}

//MARK: - Helper
extension AcoordionAnimationManager {
    
    fileprivate var animationDuration: TimeInterval {
        return fmax(animationMinimumDuration, TimeInterval(cellLength / cellBaseLength) * animationMinimumDuration)
    }
    
    fileprivate func unfoldingAnimationProgress(_ currentTime: TimeInterval) -> CGFloat {
        if  animationStartTime == 0 {
            return 0
        } else if currentTime >= animationStartTime + animationDuration {
            endTimer()
            return 1
        } else {
            return CGFloat((currentTime - animationStartTime) / animationDuration)
        }
    }
    
    fileprivate func foldingAnimationProgress(_ currentTime: TimeInterval) -> CGFloat {
        if  animationStartTime == 0 {
            return 1
        } else if currentTime >= animationStartTime + animationDuration {
            endTimer()
            return 0
        } else {
            return 1 - CGFloat((currentTime - animationStartTime) / animationDuration)
        }
    }
}
