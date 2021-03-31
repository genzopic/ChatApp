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
        fetchLoginUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchChatRoomsInfoFromFirestore()
        
    }
    // チャットルームをFirestoreから取得
    private func fetchChatRoomsInfoFromFirestore() {
        Firestore.firestore().collection("chatRooms").getDocuments { (snapshot, error) in
            if let err = error {
                print("get chatRooms err: ",err.localizedDescription)
                return
            }
            print("get chatRooms success!!")
            snapshot?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let chatRoom = ChatRoom(dic: dic)
                guard let uid = Auth.auth().currentUser?.uid else { return }
                chatRoom.members.forEach { (memberUid) in
                    if memberUid != uid {
                        Firestore.firestore().collection("users").document(memberUid).getDocument { (snapshot, error) in
                            if let err = error {
                                print("get member err: ",err)
                                return
                            }
                            print("get member success")
                            // メンバーのユーザー情報を取得
                            guard let dic = snapshot?.data() else {
                                print("snapshot is Null")
                                return
                            }
                            let user = User(dic: dic)
                            user.uid = snapshot?.documentID
                            chatRoom.partnerUser = user
                            //
                            self.chatRooms.append(chatRoom)
                            print("chatRooms count: ",self.chatRooms.count)
                            self.chatListView.reloadData()
                        }
                    }
                }
                
                
            })
            
        }
    }
    // ビューの初期設定
    private func setupViews() {
        chatListView.delegate = self
        chatListView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    // 未ログインは、ログイン画面を表示
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func tappedNavRightBarButton() {
        let storyboard = UIStoryboard(name: "UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController")
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
}


// MARK: - chatListTableViewCell
class chatListTableViewCell: UITableViewCell {
    
    var chatRoom: ChatRoom? {
        didSet {
            if let chatRoom = chatRoom {
                self.partnerLable.text = chatRoom.partnerUser?.username
                guard let url = URL(string: chatRoom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: self.userImageView)
                dataLabel.text = dataFormatterForDateLabel(date: chatRoom.createdAt.dateValue())
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLable: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func dataFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja-jp")
        return formatter.string(from: date)
    }
    
}
