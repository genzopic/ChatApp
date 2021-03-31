//
//  ChatRoomViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/26.
//

import UIKit
//
import Firebase

class ChatRoomViewController: UIViewController {
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    // loginUser
    var user: User?
    // chatRoom,partnerUser
    var chatRoom: ChatRoom?

    let cellId = "cellId"
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        
        fetchMessages()
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
    
    // MARK: - Firestoreからメッセージを取得
    private func fetchMessages() {
        guard let chatRoomdocId = chatRoom?.documentId else { return }
        print("chatRoomdocId: ",chatRoomdocId)
        Firestore.firestore().collection("chatRooms").document(chatRoomdocId).collection("messages")
            .addSnapshotListener { (snapshots, error) in
                if let err = error {
                    print("get messages err:",err.localizedDescription)
                    return
                }
                print("get messages success!! count: ",snapshots?.count)
                snapshots?.documentChanges.forEach { (documentChange) in
                    switch documentChange.type {
                    case .added:
                        let dic = documentChange.document.data()
                        let message = Message(dic: dic)
                        message.partnerUser = self.chatRoom?.partnerUser
                        self.messages.append(message)
                        self.chatRoomTableView.reloadData()
                    case .modified,.removed:
                        print("nothing to do")
                    }
                }
                
            }
        
    }
    
    
}
extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    // チャットメッセージの入力エリアの文字を受け取る
    func tappedSendButton(text: String) {
//        messages.append(text)
//        chatRoomTableView.reloadData()
        
        guard let chatRoomDocId = chatRoom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        Firestore.firestore().collection("chatRooms").document(chatRoomDocId).collection("messages").document()
            .setData(docData, completion: { (error) in
                if let err = error {
                    print("save messages err: ",err.localizedDescription)
                    return
                }
                print("save message success!!")
                self.chatInputAccessoryView.removeText()
            })
            
        
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
        cell.message = messages[indexPath.row]
        return cell
    }
    
}

