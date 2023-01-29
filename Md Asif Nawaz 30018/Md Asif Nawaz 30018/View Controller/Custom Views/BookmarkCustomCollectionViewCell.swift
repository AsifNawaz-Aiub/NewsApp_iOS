//
//  BookmarkCustomCollectionViewCell.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 17/1/23.
//

import UIKit

class BookmarkCustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nibImage: UIImageView!
    @IBOutlet weak var nibLabel: UILabel!
    @IBOutlet weak var nibShowBtn: UIButton!
    @IBOutlet weak var nibDeleteBtn: UIButton!
    var vc : BookmarksViewController?
    var articleTitle = ""
    var articleSource = ""
    var articleAuthor = ""
    var articleImage = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    @IBAction func nibShowBtnAction(_ sender: Any) {
        
    }
        
    @IBAction func nibDeleteBtnAction(_ sender: Any) {
    }
}
