//
//  ChatRoomViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/26.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    let cellId = "cellId"
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
    }
    
    // MARK: - xibで作成したチャットメッセージの入力エリアを、ViewControllerが標準で持つ、inputAccessoryViewにセットする
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    // チャットメッセージの入力エリアの文字を受け取る
    func tappedSendButton(text: String) {
        messages.append(text)
        chatInputAccessoryView.removeText()
        chatRoomTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // textViewの高さに合わせて、セルの高さを自動にする。　textViewの scrollingEnabled をオフにしておく
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
//        cell.messageTextView.text = messages[indexPath.row]
        cell.messageText = messages[indexPath.row]
        return cell
    }
    
}

