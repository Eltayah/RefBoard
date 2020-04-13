//
//  ItemCell.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 08.03.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setData(text: String) {
        
        self.textLabel.text = text
        
    }
    
}
