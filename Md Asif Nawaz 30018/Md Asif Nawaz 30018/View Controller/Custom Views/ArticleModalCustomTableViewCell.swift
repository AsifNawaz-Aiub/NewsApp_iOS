//
//  ArticleModalCustomTableViewCell.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 16/1/23.
//

import UIKit

class ArticleModalCustomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
