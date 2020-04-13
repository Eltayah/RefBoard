//
//  Item.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 21.02.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Item: Object {
    
    @objc dynamic var imageID = UUID().uuidString
    @objc dynamic var imagePath: String? = nil
    let imageTag = RealmOptional<Int>()
    let xValue = RealmOptional<Int>()
    let yValue = RealmOptional<Int>()
    let imageWidth = RealmOptional<Int>()
    let imageHeight = RealmOptional<Int>()
    let imageRotation = RealmOptional<Float>()
    let imageBackward = RealmOptional<Int>()
    let imageFlip = RealmOptional<Bool>()
    
    
    var parentCategory = LinkingObjects(fromType: Board.self, property: "items")
    
    override static func primaryKey() -> String? {
        return "imageID"
    }

}
