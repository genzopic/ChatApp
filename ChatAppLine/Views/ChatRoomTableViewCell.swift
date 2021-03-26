//
//  ChatRoomTableViewCell.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/26.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userimageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dataLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userimageView.layer.cornerRadius = userimageView.frame.size.height / 2
        messageTextView.layer.cornerRadius = 15
        backgroundColor = .clear
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
