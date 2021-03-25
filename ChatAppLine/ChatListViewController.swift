//
//  ChatListViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/25.
//

import UIKit

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var chatListView: UITableView!
    
    private let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListView.delegate = self
        chatListView.dataSource = self
        
        
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
    
}


// MARK: - chatListTableViewCell
class chatListTableViewCell: UITableViewCell {
    
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
}
