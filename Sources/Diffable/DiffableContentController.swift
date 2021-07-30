//
//  DiffableContentController.swift
//  LIFX
//
//  Created by Alexander Stonehouse on 22/11/18.
//  Copyright © 2018 LIFX Labs. All rights reserved.
//

import UIKit

// MARK: Content Controller

/// Controller responsible for updating the content of a DiffableContentView that may contain multiple sections.
protocol DiffableContentController: class {
    associatedtype SectionType: ListSection
    var skipUpdates: Bool { get }
    var processMovesFirst: Bool { get }
    var content: [SectionType] { get set }
    var diffableContentView: DiffableContentView? { get }
    func prepareUpdatedContent() -> [SectionType]
}

extension DiffableContentController {
    func performBatchUpdates(completion: ((Bool) -> Void)?) {
        diffableContentView?
            .batchUpdate(
                {
                    self.doBatchUpdate()
                },
                completion: completion
            )
    }

    func doBatchUpdate() {
        guard let view = diffableContentView else {
            return
        }
        let newContent = prepareUpdatedContent()
        let (sectionDiff, itemDiffs) = view.generateSectionsDiff(
            old: content,
            new: newContent,
            skipUpdates: skipUpdates
        )
        self.content = newContent
        view.updateSections(sectionDiff)
        view.updateSectionItems(itemDiffs, skipUpdates: skipUpdates)
    }
}

extension DiffableContentController where Self: UITableViewController {
    var diffableContentView: DiffableContentView? {
        return tableView
    }

    var processMovesFirst: Bool {
        return false
    }
}

extension DiffableContentController where Self: UITableViewDataSource {
    var processMovesFirst: Bool {
        return false
    }
}

extension DiffableContentController where Self: UICollectionViewController {
    var diffableContentView: DiffableContentView? {
        return collectionView
    }

    var processMovesFirst: Bool {
        return true
    }
}

extension DiffableContentController where Self: UICollectionViewDataSource {
    var processMovesFirst: Bool {
        return true
    }
}
