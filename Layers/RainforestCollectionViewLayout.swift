//
//  RainforestCollectionViewLayout.swift
//  LayersCollectionViewPlayground
//
//  Created by René Cacheaux on 10/1/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation


// NOTE: This custom layout is built specifically for the AsyncDisplayKit tutorial. If you would like
//  to use this layout outside this project you may end up needing to make modifications.
//  However, this code is a good starting point.

protocol RainforestLayoutMetrics {
    
    func numberOfRowsForNumberOfItems(numberOfItems: Int) -> Int
    func rowForItemAtIndex(index: Int) -> Int
    func columnForItemAtIndex(index: Int) -> Int
    func indexForItemAboveItemAtIndex(index: Int) -> Int
    func numberOfColumns() -> Int
    
}

class TwoColumnLayoutMetrics: RainforestLayoutMetrics {
    
    func numberOfRowsForNumberOfItems(numberOfItems: Int) -> Int {
        let isOdd: Bool = numberOfItems%2 > 0
        var numberOfRows = numberOfItems/2
        if isOdd {
            numberOfRows += 1
        }
        return numberOfRows
    }
    
    func rowForItemAtIndex(index: Int) -> Int {
        return ((index + 1)/2 + (index + 1)%2) - 1
    }
    
    func columnForItemAtIndex(index: Int) -> Int {
        return index%2
    }
    
    func indexForItemAboveItemAtIndex(index: Int) -> Int {
        let aboveItemIndex = index - 2
        return aboveItemIndex >= 0 ? aboveItemIndex : index
    }
    
    func numberOfColumns() -> Int {
        return 2
    }
}

class OneColumnLayoutMetrics: RainforestLayoutMetrics {
    
    func numberOfRowsForNumberOfItems(numberOfItems: Int) -> Int {
        return numberOfItems
    }
    
    func rowForItemAtIndex(index: Int) -> Int {
        return index
    }
    
    func columnForItemAtIndex(index: Int) -> Int {
        return 0
    }
    
    func indexForItemAboveItemAtIndex(index: Int) -> Int {
        let aboveItemIndex = index - 1
        return aboveItemIndex >= 0 ? aboveItemIndex : index
    }
    
    func numberOfColumns() -> Int {
        return 1
    }
}



