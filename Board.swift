//
//  Category.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 21.02.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import Foundation
import RealmSwift

class Board: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var sortingIndex = 0
    let items = List<Item>()
    let notes = List<Note>()
}
