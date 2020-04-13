//
//  RealmHelper.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 03.03.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class RealmHelper {
    static let realm = try! Realm()
    
    static func getAllImages() -> Results<Item>? {
        var images: Results<Item>?
        images = realm.objects(Item.self)
        let sortedImages = images?.sorted(byKeyPath: "imageID", ascending: true)
        return sortedImages
    }
    
    static func saveImage(image: Item) {
        do {
            try realm.write {
                realm.add(image)
            }
        } catch {
            print("Error Saving Loan: \(error.localizedDescription)")
        }
    }
    
    static func updateImage(image: Item) {
        
        let imageID = image.imageID
        let imagePath = image.imagePath
        let tag = image.imageTag
        let x = image.xValue
        let y = image.yValue
        let width = image.imageWidth
        let length = image.imageHeight
        let rotation = image.imageRotation
        let backward = image.imageBackward
        let flip = image.imageFlip
        
        do { try realm.write {
            
            realm.create(Item.self, value: [imageID, imagePath!, tag, x, y, width, length, rotation, backward, flip])
            
            }
        } catch {
            print("Error Updating Image: \(error.localizedDescription)")
        }
    }
    
    static func deleteImage(image: Item) {
        do {
            try realm.write {
                realm.delete(image)
            }
        } catch {
            print("Error Deleting Image: \(error.localizedDescription)")
        }
    }
    
}
