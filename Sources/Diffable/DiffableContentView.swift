//
//  DiffableContentView.swift
//  LIFX
//
//  Created by Alexander Stonehouse on 22/11/18.
//  Copyright © 2018 LIFX Labs. All rights reserved.
//

import Foundation

protocol DiffableContentView {
    var processMovesFirst: Bool { get }

    func batchUpdate(_: () -> Void, completion: ((Bool) -> Void)?)

    // MARK: Section Updates
    func deleteSections(_: IndexSet)
    func insertSections(_: IndexSet)
    func moveSection(_: Int, toSection: Int)

    // MARK: Content Updates
    func insertContent(at: [IndexPath])
    func moveContent(at: IndexPath, to: IndexPath)
    func reloadContent(at: [IndexPath])
    func deleteContent(at: [IndexPath])
}

typealias SectionItemDiff = (section: (before: Int, after: Int), diff: [Diff])
typealias SectionDiff = (sectionDiff: [Diff], itemDiffs: [SectionItemDiff])

extension DiffableContentView {
    func generateSectionsDiff<T>(old: [T], new: [T], skipUpdates: Bool) -> SectionDiff where T: ListSection {
        let sectionDiff: [Diff] = diff(old: old, new: new, processMovesFirst: processMovesFirst)
        let itemDiffs: [SectionItemDiff] = new.enumerated()
            .compactMap { e in
                if let oldSection = old.enumerated().first(where: { $0.element.identifier == e.element.identifier }) {
                    let d = diff(
                        old: oldSection.element.items,
                        new: e.element.items,
                        skipUpdates: skipUpdates,
                        processMovesFirst: processMovesFirst
                    )
                    if d.count > 0 {
                        return ((oldSection.offset, e.offset), d)
                    }
                }
                return nil
            }
        return (sectionDiff, itemDiffs)
    }

    func updateSections(_ sectionDiff: [Diff]) {
        handleSectionDeletions(sectionDiff)
        handleSectionInsertions(sectionDiff)
    }

    func updateSectionItems(
        _ itemDiffs: [(section: (before: Int, after: Int), diff: [Diff])],
        skipUpdates: Bool = false
    ) {
        itemDiffs.forEach {
            handleItemDeletions(section: $0.section.before, $0.diff)
        }

        itemDiffs.forEach {
            handleItemUpdates(section: $0.section.before, $0.diff, skipUpdates: skipUpdates)
        }

        itemDiffs.forEach {
            handleItemInsertions(section: $0.section.after, $0.diff)
        }
        itemDiffs.forEach {
            handleItemMoves(section: $0.section, $0.diff)
        }
    }

    // MARK: Section changes

    private func handleSectionDeletions(_ diff: [Diff]) {
        let deletions = diff.deletions
        if deletions.count > 0 {
            deleteSections(IndexSet(deletions))
        }
    }

    private func handleSectionInsertions(_ diff: [Diff]) {
        let insertions = diff.insertions
        if insertions.count > 0 {
            insertSections(IndexSet(insertions))
        }
        diff.moves.forEach {
            moveSection($0.from, toSection: $0.to)
        }
    }

    /// MARK: Item changes

    private func handleItemDeletions(section: Int, _ diff: [Diff]) {
        let deletions = diff.deletions.map { IndexPath(row: $0, section: section) }

        if deletions.count > 0 {
            deleteContent(at: deletions)
        }
    }

    private func handleItemInsertions(section: Int, _ diff: [Diff]) {
        let insertions = diff.insertions.map { IndexPath(row: $0, section: section) }

        if insertions.count > 0 {
            insertContent(at: insertions)
        }
    }

    private func handleItemMoves(section: (before: Int, after: Int), _ diff: [Diff]) {
        diff.moves.forEach {
            moveContent(
                at: IndexPath(row: $0.from, section: section.before),
                to: IndexPath(row: $0.to, section: section.after)
            )
        }
    }

    private func handleItemUpdates(section: Int, _ diff: [Diff], skipUpdates: Bool) {
        if !skipUpdates {
            let updates = diff.updates
            if updates.count > 0 {
                reloadContent(at: updates.map { IndexPath(row: $0, section: section) })
            }
        }
    }
}
