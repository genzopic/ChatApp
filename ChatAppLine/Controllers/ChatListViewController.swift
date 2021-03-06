//
//  ChatListViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/25.
//

import UIKit
//
import Firebase
import Nuke

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var chatListView: UITableView!
    
    private var chatRoomListner: ListenerRegistration?
    
    private let cellId = "cellId"
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    private var chatRooms = [ChatRoom]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        confirmLoggedInUser()
        fetchChatRoomsInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLoginUserInfo()
    }
    
    // チャットルームをFirestoreから取得
    func fetchChatRoomsInfoFromFirestore() {
        // 一度クリア
        chatRoomListner?.remove()
        chatRooms.removeAll()
        chatListView.reloadData()
        //
        chatRoomListner = Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (chatRoomSnapshot, error) in
                if let err = error {
                    print("get chatRooms err: ",err.localizedDescription)
                    return
                }
                print("get chatRooms success!!")
                chatRoomSnapshot?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDucumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
            }
    }
    //
    private func handleAddedDucumentChange(documentChange: DocumentChange) {
        let chatRoomdic = documentChange.document.data()
        let chatRoom = ChatRoom(dic: chatRoomdic)
        chatRoom.documentId = documentChange.document.documentID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 自分がメンバーに含まれていなければ抜ける
        let isContain = chatRoom.members.contains(uid)
        if !isContain { return }
        chatRoom.members.forEach { (memberUid) in
            // 自分以外のメンバーを表示する
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshots, error) in
                    if let err = error {
                        print("get member err: ",err)
                        return
                    }
                    // メンバーのユーザー情報を取得して、partnerUserにセット
                    guard let dic = userSnapshots?.data() else {
                        print("snapshot is Null")
                        return
                    }
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatRoom.partnerUser = user
                    // 最後のメッセージを取得して、latestMessageにセット
                    guard let chatRoomId = chatRoom.documentId  else { return }
                    let latestMessageId = chatRoom.latestMessageId
                    if latestMessageId == "" {
                        // テスト中の不整合データの対応
                        self.chatRooms.append(chatRoom)
                        print("chatRooms count: ",self.chatRooms.count)
                        self.chatListView.reloadData()
                        return
                    }
                    Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").document(latestMessageId).getDocument { (messageSnapshots, error) in
                        if let err = error {
                            print("get latestMessage err: ",err.localizedDescription)
                            return
                        }
                        guard let dic = messageSnapshots?.data() else { return }
                        let message = Message(dic: dic)
                        chatRoom.latestMessage = message
                    }
                    //
                    self.chatRooms.append(chatRoom)
                    print("chatRooms count: ",self.chatRooms.count)
                    self.chatListView.reloadData()
                }
            }
        }
        
    }
    
    // ビューの初期設定
    private func setupViews() {
        chatListView.delegate = self
        chatListView.dataSource = self
        // フッターの余分な線を消す
        chatListView.tableFooterView = UIView()
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLogoutButton))
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    // 未ログインは、ログイン画面を表示
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    // 新規チャットボタン
    @objc private func tappedNavRightBarButton() {
        let storyboard = UIStoryboard(name: "UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        present(nav, animated: true, completion: nil)
    }
    // ログウトボタン
    @objc private func tappedLogoutButton() {
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
        } catch {
            print("ログアウトに失敗しました",error)
        }
        
    }
    // サインアップ画面を表示
    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        let nav = UINavigationController(rootViewController: loginViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    //
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let err = error {
                print("fetch users err: ",err.localizedDescription)
                return
            }
            guard let snapshot = snapshot else { return }
            guard let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            
            self.user = user
            
        }
        
    }
        
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! chatListTableViewCell
        cell.chatRoom = self.chatRooms[indexPath.row]
        return cell
    }
    // セルをタップしたらチャットルームへ
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.chatRoom = self.chatRooms[indexPath.row]
        chatRoomViewController.user = user
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
}


// MARK: - chatListTableViewCell
class chatListTableViewCell: UITableViewCell {
    
    var chatRoom: ChatRoom? {
        didSet {
            if let chatRoom = chatRoom {
                // パートナー名
                self.partnerLable.text = chatRoom.partnerUser?.username
                guard let url = URL(string: chatRoom.partnerUser?.profileImageUrl ?? "") else { return }
                // プロフィール画像
                Nuke.loadImage(with: url, into: self.userImageView)
                // 更新日時
                dataLabel.text = dataFormatterForDateLabel(date: chatRoom.latestMessage?.createdAt.dateValue() ?? Date())
                // 最後のメッセージ
                latestMessageLabel.text = self.chatRoom?.latestMessage?.message
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLable: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func dataFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja-jp")
        return formatter.string(from: date)
    }
    
}
