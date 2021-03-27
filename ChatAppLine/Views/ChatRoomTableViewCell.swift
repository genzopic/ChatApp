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
    @IBOutlet weak var messageTextViewConstraint: NSLayoutConstraint!
    
    var messageText : String? {
        didSet{
            guard let text = messageText else { return }
            let width = estimateFrameTextView(text: text).width + 25
            messageTextViewConstraint.constant = width
            messageTextView.text = text
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        userimageView.layer.cornerRadius = userimageView.frame.size.height / 2
        messageTextView.layer.cornerRadius = 15
        backgroundColor = .clear
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    // メッセージテキストの幅を自動調整する
    private func estimateFrameTextView(text: String) -> CGRect {
        // max用
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], context: nil)
    }
    
}
