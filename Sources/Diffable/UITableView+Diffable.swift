//
//  UIViewController+Diffable.swift
//  LIFX
//
//  Created by Alexander Stonehouse on 22/11/18.
//  Copyright © 2018 LIFX Labs. All rights reserved.
//

import UIKit

extension UITableView: DiffableContentView {
    var processMovesFirst: Bool {
        return false
    }

    func batchUpdate(_ updates: () -> Void, completion: ((Bool) -> Void)?) {
        if #available(iOS 11.0, *) {
            performBatchUpdates(updates, completion: completion)
        } else {
            beginUpdates()
            updates()
            endUpdates()
            completion?(true)
        }
    }

    func deleteSections(_ sections: IndexSet) {
        deleteSections(sections, with: .automatic)
    }

    func insertSections(_ sections: IndexSet) {
        insertSections(sections, with: .automatic)
    }

    func insertContent(at rows: [IndexPath]) {
        insertRows(at: rows, with: .automatic)
    }

    func moveContent(at: IndexPath, to: IndexPath) {
        moveRow(at: at, to: to)
    }

    func reloadContent(at: [IndexPath]) {
        reloadRows(at: at, with: .automatic)
    }

    func deleteContent(at: [IndexPath]) {
        deleteRows(at: at, with: .automatic)
    }

}
