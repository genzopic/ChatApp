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
    //
    private let accessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        // 取得できたら値がセットされる（getを省略した記述）
        self.view.safeAreaInsets.bottom
    }
    private var isKeyboardShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
    }
    //
    private func setupNotification() {
        // キーボードが表示されたら通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        // 見切れる部分を微調整( 反転させる前は、top: 0, left: 0, bottom: 40, right: 0 )
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        //　スクロールするとキーボードが消えるようにする
        chatRoomTableView.keyboardDismissMode = .interactive
        // 反転させて、cellもまた、反転させる
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    // キーボードが表示された時（テーブルビューを上に移動する）
    @objc func keyboardWillShow(notification: NSNotification) {
        if isKeyboardShow == false {
            isKeyboardShow = true
        } else {
            return
        }
        guard let userInfo = notification.userInfo else { return }
        // キーボードのサイズを取得
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            // 余分な動きを事前に防ぐ
            if keyboardFrame.height <= accessoryHeight {
                isKeyboardShow = false
                return
            }
            // キーボードの高さ分ずらす
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            // 最下部以外の時はズレるので、微調整
            if chatRoomTableView.contentOffset.y != -60 {
                moveY += 60
            }
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
        
    }
    // MARK: キーボードが隠れた時（テーブルビューを元の位置にする）
    @objc func keyboardWillHide() {
        if isKeyboardShow == true {
            isKeyboardShow = false
        } else {
            return
        }
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
    }
    
    // MARK: xibで作成したチャットメッセージの入力エリアを、ViewControllerが標準で持つ、inputAccessoryViewにセットする
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
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
    
    // MARK: Firestoreからメッセージを取得
    private func fetchMessages() {
        guard let chatRoomdocId = chatRoom?.documentId else { return }
        print("chatRoomdocId: ",chatRoomdocId)
        Firestore.firestore().collection("chatRooms").document(chatRoomdocId).collection("messages")
            .addSnapshotListener { (snapshots, error) in
                if let err = error {
                    print("get messages err:",err.localizedDescription)
                    return
                }
                print("get messages success!! count: \(snapshots?.count)")
                snapshots?.documentChanges.forEach { (documentChange) in
                    switch documentChange.type {
                    case .added:
                        let dic = documentChange.document.data()
                        let message = Message(dic: dic)
                        message.partnerUser = self.chatRoom?.partnerUser
                        self.messages.append(message)
                        self.messages.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                        }
                        self.chatRoomTableView.reloadData()
                    // 一番下にスクロールする（反転て一番下を表示固定にしたので、コメント。上の＜を＞にして並び順も逆にした）
                    //                        self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    case .modified,.removed:
                        print("nothing to do")
                    }
                }
                
            }
        
    }
    
    
}

//--------------------------------------------------------------------------------------------------------------------------
// MARK: - メッセージ入力エリア
//--------------------------------------------------------------------------------------------------------------------------
extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    // チャットメッセージの入力エリアの文字を受け取る
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatRoomDocId = chatRoom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        
        let messageId = randomString(length: 20)
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        Firestore.firestore().collection("chatRooms").document(chatRoomDocId).collection("messages").document(messageId)
            .setData(docData, completion: { (error) in
                if let err = error {
                    print("save messages err: ",err.localizedDescription)
                    return
                }
                let latestMessageDat = [
                    "latestMessageId": messageId
                ]
                Firestore.firestore().collection("chatRooms").document(chatRoomDocId).updateData(latestMessageDat) { (error) in
                    if let err = error {
                        print("update latestMessage err: ",err.localizedDescription)
                        return
                    }
                    print("save message success!!")
                }
            })
    }
    // ランダムな英数字を作成
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}

//--------------------------------------------------------------------------------------------------------------------------
// MARK: - UITableViewDelegate, UITableViewDataSource
//--------------------------------------------------------------------------------------------------------------------------
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
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messages[indexPath.row]
        return cell
    }
    
}

