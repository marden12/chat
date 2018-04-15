//
//  ConversationsTableViewCell.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(colorLiteralRed: 128/255, green: 0/255, blue: 128/255, alpha: 1).cgColor
        // Initialization code
    }

}
