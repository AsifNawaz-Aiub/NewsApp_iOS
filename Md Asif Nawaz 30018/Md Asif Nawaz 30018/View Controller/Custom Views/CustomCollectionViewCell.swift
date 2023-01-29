//
//  CustomCollectionViewCell.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 12/1/23.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func prepareForReuse() {
        categoryLabel.textColor = .darkGray
    }
}
