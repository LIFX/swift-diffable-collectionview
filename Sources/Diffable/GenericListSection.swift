//
//  GenericListSection.swift
//  LIFX
//
//  Created by Alexander Stonehouse on 22/8/19.
//  Copyright © 2019 LIFX Labs. All rights reserved.
//

import Foundation

struct GenericListSection<ItemType: Diffable & Equatable>: ListSection {
    typealias ListItem = ItemType
    let identifier: Int
    let items: [ItemType]

    init(identifier: Int = 0, items: [ItemType]) {
        self.identifier = identifier
        self.items = items
    }
}
