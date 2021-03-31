//
//  ChatInputAccessoryView.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/27.
//

import UIKit

protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    //
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    //
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    // 上記initを作ると自動生成される
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.addSubview(view)
        
    }

    private func setupViews() {
        //
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        chatTextView.text = ""
        chatTextView.delegate = self
        //
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
    }
    
    func removeText()  {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }

    // MARK: - テキストビューのサイズに応じてインプットエリアを可変にする
    // textViewのScrollingEnabledのチェックを外しておく
    // initでautoresizingMask = .flexibleHeight　をしておく
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
}

extension ChatInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        if textView.text.isEmpty {
            sendButton.isEnabled = false
            print("sendButton Enable=false")
        } else {
            sendButton.isEnabled = true
            print("sendButton Enable=true")
        }
        
    }
    
}
