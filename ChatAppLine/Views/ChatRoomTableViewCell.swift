//
//  ChatRoomTableViewCell.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/26.
//

import UIKit
//
import Nuke
import Firebase

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userimageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var messageTextViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myMessageTextViewConstraint: NSLayoutConstraint!
    
    
    var message : Message? {
        didSet{
//            if let message = message {
//                let width = estimateFrameTextView(text: message.message).width + 25
//                messageTextViewConstraint.constant = width
//                partnerMessageTextView.text = message.message
//                partnerDataLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
////                userimageView.image
//
//            }
            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // プロフィールイメージの初期設定
        userimageView.layer.cornerRadius = userimageView.frame.size.height / 2
        partnerMessageTextView.layer.cornerRadius = 15
        partnerMessageTextView.isEditable = false
        partnerMessageTextView.isSelectable = false
        //
        myMessageTextView.layer.cornerRadius = 15
        myMessageTextView.isEditable = false
        myMessageTextView.isSelectable = false

        backgroundColor = .clear
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        checkWhichUserMessage()
        
    }
    
    private func checkWhichUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message?.uid {
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userimageView.isHidden = true
            
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            
            if let message = message {
                let width = estimateFrameTextView(text: message.message).width + 30
                myMessageTextViewConstraint.constant = width
                myMessageTextView.text = message.message
                myDateLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        } else {
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userimageView.isHidden = false
            
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            
            if let message = message {
                let width = estimateFrameTextView(text: message.message).width + 30
                messageTextViewConstraint.constant = width
                partnerMessageTextView.text = message.message
                partnerDateLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
                if let partnerProfileImageUrl = message.partnerUser?.profileImageUrl,let url = URL(string: partnerProfileImageUrl) {
                    Nuke.loadImage(with: url, into: userimageView)
                }
                
            }

        }
        
    }
    
    // メッセージテキストの幅を自動調整する
    private func estimateFrameTextView(text: String) -> CGRect {
        // max用
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    private func dataFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja-jp")
        return formatter.string(from: date)
    }

    
}
