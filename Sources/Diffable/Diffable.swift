//
//  Diffable.swift
//  LIFX
//
//  Created by Alexander Stonehouse on 16/11/18.
//  Copyright © 2018 LIFX Labs. All rights reserved.
//

import Foundation

/// A type which can be 'diffed' in a collection, so if you have
/// two collections of these values then you can find out what
/// has changed between the two.
protocol Diffable {
    /// Identifier is a unique string to identify an item.
    /// This is used to determine if an item has been
    /// deleted/inserted/moved.
    ///
    /// A good identifier could be the hashValue of an unique
    /// identifying property (i.e. title/UUID)
    var identifier: Int { get }
}

/// Wrapper for a section of a list, will contain items which can also be diffed
protocol ListSection: Diffable {
    associatedtype ListItem: Diffable, Equatable

    var items: [ListItem] { get }
}

extension Diffable where Self: Hashable {
    var identifier: Int {
        return hashValue
    }
}

enum Diff {
    case insertion(Int)
    case deletion(Int)
    case move(from: Int, to: Int)
    /// Updates indicate that the content has changed, but the
    /// item has not been moved. The Diffable item should
    /// implement Equatable to support update detection.
    case update(Int)
}

// MARK: Diffing functions

/// Produces an array of 'Diffs' based on a comparison of the identifier properties in the two arrays.
/// It is crucial that the identifiers are unique values for each value type and that there aren't duplicates.
///
/// This diff can be used to product an animated transition in the UI.
///
/// - Parameters:
///   - old: Previous data set, of which the diff will be based
///   - new: New data set, this should be the end result after applying the diff to the old value
///   - processMovesFirst: Indicates whether moves should be processed before deletions and insertions or after.
///                        This affects the resulting index of the move. UITableView processes moves after while
///                        UICollectionView processes them first.
/// - Returns: Resulting diff
func diff(old: [Diffable], new: [Diffable], processMovesFirst: Bool = true) -> [Diff] {
    let deletions = old.enumerated()
        .compactMap { e -> (offset: Int, element: Diffable)? in
            if new.firstIndex(where: { $0.identifier == e.element.identifier }) == nil {
                return e
            }
            return nil
        }

    let insertions = new.enumerated()
        .compactMap { e -> (offset: Int, element: Diffable)? in
            if old.firstIndex(where: { $0.identifier == e.element.identifier }) == nil {
                return e
            }
            return nil
        }

    // Apply pending deletions and insertions to determine whether or not anything has moved
    var oldWithInsertionsAndDeletions = old
    if !processMovesFirst {
        var removed = 0
        deletions.forEach {
            oldWithInsertionsAndDeletions.remove(at: $0.offset - removed)
            removed += 1
        }
        insertions.forEach {
            oldWithInsertionsAndDeletions.insert($0.element, at: $0.offset)
        }
    }

    let moves: [(from: (offset: Int, element: Diffable), to: (offset: Int, element: Diffable))] = new.enumerated()
        .compactMap({ e in
            if let oldIndex = oldWithInsertionsAndDeletions.enumerated()
                .first(where: { $0.element.identifier == e.element.identifier }), e.offset != oldIndex.offset
            {
                return (oldIndex, e)
            }
            return nil
        })

    return [
        deletions.map { .deletion($0.offset) },
        insertions.map { .insertion($0.offset) },
        moves.map { .move(from: $0.from.offset, to: $0.to.offset) },
    ]
    .flatMap { $0 }
}

func diff<T>(old: [T], new: [T], skipUpdates: Bool, processMovesFirst: Bool) -> [Diff] where T: Diffable, T: Equatable {
    let diffWithoutUpdates = diff(old: old, new: new, processMovesFirst: processMovesFirst)

    // For updates, we need to check first, is the content different than before, and secondly, is this change already covered by a insertion/move
    let updates: [Int]
    if skipUpdates {
        updates = []
    } else {
        updates = new.enumerated()
            .compactMap { index, element -> Int? in
                if index < old.count, element.identifier == old[index].identifier, element != old[index],
                    !diffWithoutUpdates.moves.contains(where: { $0.to == index })
                {
                    // Updates are processed before insertions, so this should use the old index
                    return index
                }
                return nil
            }
    }

    return [
        diffWithoutUpdates,
        updates.map { .update($0) },
    ]
    .flatMap { $0 }
}

// MARK: - Diff helpers

extension Collection where Element == Diff {
    var deletions: [Int] {
        return compactMap {
            switch $0 {
            case .deletion(let index):
                return index
            default:
                return nil
            }
        }
    }

    var insertions: [Int] {
        return compactMap {
            switch $0 {
            case .insertion(let index):
                return index
            default:
                return nil
            }
        }
    }

    var moves: [(from: Int, to: Int)] {
        return compactMap {
            switch $0 {
            case .move(let from, let to):
                return (from, to)
            default:
                return nil
            }
        }
    }

    var updates: [Int] {
        return compactMap {
            switch $0 {
            case .update(let index):
                return index
            default:
                return nil
            }
        }
    }
}
