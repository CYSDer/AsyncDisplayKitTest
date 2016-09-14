//
//  CustomCollectionViewLayout.swift
//  Layers
//
//  Created by yuanshengcao on 16/9/13.
//  Copyright © 2016年 Razeware LLC. All rights reserved.
//

import Foundation

enum RainforestLayoutType {
    case OneColumn
    case TwoColumn
    
    func metrics() -> RainforestLayoutMetrics {
        switch self {
        case OneColumn:
            return OneColumnLayoutMetrics()
        case TwoColumn:
            return TwoColumnLayoutMetrics()
        }
    }
}

class RainforestCollectionViewLayout: UICollectionViewLayout {
    
    var allLayoutAttributes = [UICollectionViewLayoutAttributes]()
    let cellDefaultHeight = 300
    let cellWidth = Int(FrameCalculator.cardWidth)
    let interCellVerticalSpacing = 10
    let interCellHorizontalSpacing = 10
    var contentMaxY: CGFloat = 0
    var layoutType: RainforestLayoutType
    var layoutMetrics: RainforestLayoutMetrics
    
    init(type: RainforestLayoutType) {
        layoutType = type
        layoutMetrics = type.metrics()
        super.init()
    }
    
    override init() {
        layoutType = .TwoColumn
        layoutMetrics = layoutType.metrics()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        layoutType = .TwoColumn
        layoutMetrics = layoutType.metrics()
        super.init(coder: aDecoder)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        if allLayoutAttributes.count == 0 {
            if let collectionView = self.collectionView {
                if collectionView.frame.size.width < CGFloat((self.cellWidth * 2) + interCellHorizontalSpacing) {
                    layoutType = .OneColumn
                    layoutMetrics = layoutType.metrics()
                }
            }
            populateLayoutAttributes()
        }
    }
    
    func populateLayoutAttributes() {
        if self.collectionView == nil {
            return
        }
        let collectionView = self.collectionView!
        
        // Calculate left margin max x.
        let totalWidthOfCellsInARow = layoutMetrics.numberOfColumns() * cellWidth
        let totalSpaceBetweenCellsInARow = interCellHorizontalSpacing * max(0, layoutMetrics.numberOfColumns() - 1)
        let totalCellAndSpaceWidth = totalWidthOfCellsInARow + totalSpaceBetweenCellsInARow
        let totalHorizontalMargin = collectionView.frame.size.width - CGFloat(totalCellAndSpaceWidth)
        let leftMarginMaxX = totalHorizontalMargin / CGFloat(2.0)
        
        allLayoutAttributes.removeAll(keepCapacity: true)
        
        for i in 0 ..< collectionView.numberOfItemsInSection(0) {
            let la = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
            let row = layoutMetrics.rowForItemAtIndex(i)
            let column = layoutMetrics.columnForItemAtIndex(i)
            let x = ((cellWidth + interCellHorizontalSpacing) * column) + Int(leftMarginMaxX)
            let y = (row * cellDefaultHeight) + (interCellVerticalSpacing * (row + 1))
            
            la.frame = CGRect(x: x, y: y, width: cellWidth, height: cellDefaultHeight)
            if la.frame.maxY > contentMaxY {
                contentMaxY = ceil(la.frame.maxY)
            }
        
            allLayoutAttributes.append(la)
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        if self.collectionView == nil {
            return CGSizeZero
        }
        let collectionView = self.collectionView!
        return CGSize(width: collectionView.frame.size.width, height: contentMaxY)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var layoutAttributes = [UICollectionViewLayoutAttributes]()
//        for i in 0 ..< allLayoutAttributes.count {
//            let la = allLayoutAttributes[i]
//            if rect.contains(la.frame) {
//                layoutAttributes.append(la)
//            }
//        }
        return allLayoutAttributes
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < allLayoutAttributes.count else { return nil }
        return allLayoutAttributes[indexPath.item]
    }
    
    override func shouldInvalidateLayoutForPreferredLayoutAttributes(preferredAttributes: UICollectionViewLayoutAttributes,
                                                                     withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return true
    }
    
    override func invalidationContextForPreferredLayoutAttributes(preferredAttributes: UICollectionViewLayoutAttributes,
                                                                  withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        
        let indexForItemAbove = layoutMetrics.indexForItemAboveItemAtIndex(originalAttributes.indexPath.item)
        let layoutAttributesForItemAbove = allLayoutAttributes[indexForItemAbove]
        
        if originalAttributes.indexPath.item != indexForItemAbove {
            preferredAttributes.frame.origin.y = layoutAttributesForItemAbove.frame.maxY + CGFloat(interCellVerticalSpacing)
        } else {
            preferredAttributes.frame.origin.y = 0
        }
        
        allLayoutAttributes[originalAttributes.indexPath.item] = preferredAttributes
        
        let invalidationContext = super.invalidationContextForPreferredLayoutAttributes(preferredAttributes, withOriginalAttributes: originalAttributes)
        invalidationContext.invalidateItemsAtIndexPaths([originalAttributes.indexPath])
        
        if preferredAttributes.frame.maxY > contentMaxY {
            invalidationContext.contentSizeAdjustment = CGSize(width: 0, height: preferredAttributes.frame.maxY - contentMaxY)
            contentMaxY = ceil(preferredAttributes.frame.maxY)
        }
        
        return invalidationContext
    }
    
}
