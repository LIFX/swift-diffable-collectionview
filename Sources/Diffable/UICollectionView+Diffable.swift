//
//  UICollectionView+Diffable.swift
//  LIFX
//
//  Created by Alexander Stonehouse on 22/11/18.
//  Copyright © 2018 LIFX Labs. All rights reserved.
//

import UIKit

extension UICollectionView: DiffableContentView {
    var processMovesFirst: Bool {
        return true
    }

    func batchUpdate(_ updates: () -> Void, completion: ((Bool) -> Void)?) {
        performBatchUpdates(updates, completion: completion)
    }

    func insertContent(at: [IndexPath]) {
        insertItems(at: at)
    }

    func moveContent(at: IndexPath, to: IndexPath) {
        moveItem(at: at, to: to)
    }

    func reloadContent(at: [IndexPath]) {
        reloadItems(at: at)
    }

    func deleteContent(at: [IndexPath]) {
        deleteItems(at: at)
    }

}
