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
    
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var userListTableView: UITableView!
    
    let cellId = "cellId"
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startChatButton.layer.cornerRadius = 15
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        fetchUserInfoFromFirestore()
        
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, error) in
            if let err = error {
                print("fetch users err: ",err.localizedDescription)
                return
            }
            print("fetch users success!!")
            guard let uid = Auth.auth().currentUser?.uid else { return }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
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
    
}

