//
//  CustomTableViewCell.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 12/1/23.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsPublishDuration: UILabel!
    @IBOutlet weak var newsPublishDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        newsImage.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
