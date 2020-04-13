//
//  MyImageStorage.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 25.02.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import Foundation
import RealmSwift
import RealmSwift

class Note: Object {
    
    @objc dynamic var noteText: String? = nil
    let noteTag = RealmOptional<Int>()
    let xValue = RealmOptional<Int>()
    let yValue = RealmOptional<Int>()
    let noteWidth = RealmOptional<Int>()
    let noteHeight = RealmOptional<Int>()
    let noteFont = RealmOptional<Double>()

    var parentCategory = LinkingObjects(fromType: Board.self, property: "notes")

}
