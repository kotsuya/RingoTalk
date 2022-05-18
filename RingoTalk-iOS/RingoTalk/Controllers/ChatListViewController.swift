//
//  ChatListViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatListViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    // MARK: - Vars
    
    var allChatRooms: [ChatRoom] = []
    var filteredChatRooms: [ChatRoom] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchChatRoomsFromFirestore()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        validateAuth()
        
        if let indexPath = chatListTableView.indexPathForSelectedRow {
            chatListTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc func tappedUserListButton() {
        performSegue(withIdentifier: "toUserList", sender: nil)
    }
    
    // MARK: - Private func
    
    private func setupUI() {
        let rightButton = UIBarButtonItem(title: "新規チャット",
                                          style: .plain,
                                          target: self,
                                          action: #selector(tappedUserListButton))
        navigationItem.rightBarButtonItem = rightButton
        
        chatListTableView.refreshControl = refreshControl
        
        // setup SearchController
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
    }
    
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "toSignUp", sender: nil)
        }
    }
    
    private func fetchChatRoomsFromFirestore() {
        FChatRoomListener.shared.downloadChatRooms { [weak self] allFBChatRooms in
            self?.allChatRooms = allFBChatRooms
            
            DispatchQueue.main.async {
                self?.chatListTableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    
    private func goToChatRoomViewController(chatRoom: ChatRoom) {
        
        // to make sure that both users have chatrooms
        restartChat(chatRoomId: chatRoom.chatRoomId, memberIds: chatRoom.memberIds)
        
        let vc = ChatRoomViewController(chatRoomId: chatRoom.chatRoomId,
                                        recipientId: chatRoom.receiverId,
                                        recipientName: chatRoom.receiverName)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UITableView datasource, delegate

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredChatRooms.count:allChatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.identifier, for: indexPath) as! ChatListTableViewCell
        let chatRoom = searchController.isActive ? filteredChatRooms[indexPath.row]:allChatRooms[indexPath.row]
        cell.configure(chatRoom)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomObject = searchController.isActive ? filteredChatRooms[indexPath.row]:allChatRooms[indexPath.row]
        goToChatRoomViewController(chatRoom: chatRoomObject)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let chatRoom = searchController.isActive ? filteredChatRooms[indexPath.row]:allChatRooms[indexPath.row]
            FChatRoomListener.shared.deleteChatRoom(chatRoom)
            
            if searchController.isActive {
                filteredChatRooms.remove(at: indexPath.row)
            } else {
                allChatRooms.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}


// MARK: - UISearchResultsUpdating

extension ChatListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased() {
            filteredChatRooms = allChatRooms.filter({ $0.receiverName.lowercased().contains(text) })
            chatListTableView.reloadData()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ChatListViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            fetchChatRoomsFromFirestore()
            refreshControl.endRefreshing()
        }
    }
}
