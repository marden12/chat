//
//  UsersTableViewCellTableViewCell.swift
//  chaD
//
//  Created by Dayana Marden on 01.05.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    @IBOutlet weak var userCountryLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(colorLiteralRed: 128/255, green: 0/255, blue: 128/255, alpha: 1).cgColor

        // Configure the view for the selected state
    }

}
