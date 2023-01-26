//
//  MessageTableViewCell.swift
//  MessageBoard
//
//  Created by imac-1763 on 2023/1/17.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var MessagepeopleLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    static let identifire = "MessageTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
