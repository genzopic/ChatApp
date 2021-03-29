//
//  ChatListViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/25.
//

import UIKit
//
import Firebase

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var chatListView: UITableView!
    
    private let cellId = "cellId"
    private var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListView.delegate = self
        chatListView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if Auth.auth().currentUser?.uid == nil {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            present(signUpViewController, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserInfoFromFirestore()
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, error) in
            if let err = error {
                print("fetch users err: ",err.localizedDescription)
                return
            }
            print("fetch users success!!")
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                self.users.append(user)
                self.chatListView.reloadData()
            })
            self.users.forEach { (user) in
                print("username : ",user.username)
            }
        }
    }
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! chatListTableViewCell
        
        cell.user = users[indexPath.row]
        
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

    var user: User? {
        didSet {
            if let user = user {
                partnerLable.text = user.username
                //            userImageView.image = user.profileImageUrl
                dataLabel.text = dataFormatterForDateLabel(date: user.createAt.dateValue())
                latestMessageLabel.text = user.email
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
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja-jp")
        return formatter.string(from: date)
    }
    
}
