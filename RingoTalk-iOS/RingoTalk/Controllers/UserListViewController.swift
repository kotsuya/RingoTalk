//
//  UserListViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/10.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import ProgressHUD

class UserListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton! {
        didSet { startChatButton.layer.cornerRadius = 10 }
    }
    
    // MARK: - Vars
    
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    private var selectedUser: User!
    
    let searchController = UISearchController(searchResultsController: nil)
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        //createDummyUsers()
        
        setupUI()
        fetchUsersFromFirestore()
    }

    // MARK: Actions
    
    @IBAction func tappedStartChatButton(_ sender: UIButton) {
        if let sender = User.currentUser, let receiver = selectedUser {
            let chatRoomId = startChat(sender: sender, receiver: receiver)
            
            let vc = ChatRoomViewController(chatRoomId: chatRoomId,
                                            recipientId: receiver.id,
                                            recipientName: receiver.username)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Private func
    
    private func setupUI() {
        userListTableView.refreshControl = refreshControl
        
        // setup SearchController
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
    }
    
    private func fetchUsersFromFirestore() {
        FUserListener.shared.getAllUsers { [weak self] result in
            switch result {
            case .success(let allUsers):
                self?.allUsers = allUsers
                DispatchQueue.main.async {
                    self?.userListTableView.reloadData()
                }
            case .failure(let error):
                ProgressHUD.showError("failed to fetch all users: \(error.localizedDescription)")                
            }
        }
    }
}

extension UserListViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            fetchUsersFromFirestore()
            refreshControl.endRefreshing()
        }
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count:allUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.identifier,
                                                 for: indexPath) as! UserListTableViewCell
        let user = searchController.isActive ? filteredUsers[indexPath.row]:allUsers[indexPath.row]
        cell.configure(user)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = searchController.isActive ? filteredUsers[indexPath.row]:allUsers[indexPath.row]
    }
}

// MARK: - UISearchResultsUpdating

extension UserListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased() {
            filteredUsers = allUsers.filter({ $0.username.lowercased().contains(text) })
            userListTableView.reloadData()
        }
    }
}
