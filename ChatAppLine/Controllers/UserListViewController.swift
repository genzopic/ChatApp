//
//  UserListViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/30.
//

import UIKit
//
import Firebase

class UserListViewController: UIViewController {
    
    let cellId = "cellId"
    private var users = [User]()
    private var selecteduser: User?
    
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartButton), for: .touchUpInside)
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        fetchUserInfoFromFirestore()
        
    }
    
    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func tappedStartButton() {
        print("tappedStartButton")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid =  self.selecteduser?.uid else { return }
        let members = [uid,partnerUid]
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (error) in
            if let err = error {
                print("save chatRooms err: ",err.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("save chatRooms success!!")
        }
        
    }
    // Firestoreからユーザー登録したユーザ情報を取得する
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, error) in
            if let err = error {
                print("fetch users err: ",err.localizedDescription)
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID

                if uid != snapshot.documentID {
                    self.users.append(user)
                    
                    self.userListTableView.reloadData()
                }
                
            })
        }
    }


}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user =  users[indexPath.row]
        self.selecteduser = user
        print("didSelectRowAt user: ",user.username)
        startChatButton.isEnabled = true

    }
    
}

