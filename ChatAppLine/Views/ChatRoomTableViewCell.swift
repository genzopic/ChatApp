//
//  ChatRoomTableViewCell.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/26.
//

import UIKit
//
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userimageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var messageTextViewConstraint: NSLayoutConstraint!
    
    var message : Message? {
        didSet{
            if let message = message {
                let width = estimateFrameTextView(text: message.message).width + 25
                messageTextViewConstraint.constant = width
                messageTextView.text = message.message
                dataLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
//                userimageView.image
            }
            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // プロフィールイメージの初期設定
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
    
    private func dataFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja-jp")
        return formatter.string(from: date)
    }

    
}
