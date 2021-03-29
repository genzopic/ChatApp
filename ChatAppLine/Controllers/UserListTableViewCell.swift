//
//  UserListTableViewCell.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/30.
//

import UIKit
//
import Nuke

class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet {
            if let user = user {
                usernameLabel.text = user.username
                if let url = URL(string: user.profileImageUrl) {
                    Nuke.loadImage(with: url, into: userImageView)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }

}
