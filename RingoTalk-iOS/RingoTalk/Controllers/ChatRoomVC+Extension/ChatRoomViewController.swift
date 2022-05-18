//
//  ChatRoomViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/10.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatRoomViewController: MessagesViewController {
   
    // MARK: - view coustomizedd
    
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 22, width: 100, height: 25))
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: - Vars
    
    private var chatRoomId = ""
    private var recipientId = ""
    private var recipientName = ""
        
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    let currentUser = MKSender(senderId: User.currentId,
                               displayName: User.currentUser?.username ?? "")
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()
    
    var notificationToken: NotificationToken?
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    var gallery: GalleryController!
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    var audioFileName: String = ""
    var audioStartTime: Date = Date()
    
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    // MARK: - init
    
    init(chatRoomId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.chatRoomId = chatRoomId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGestureRecognizer()
        
        configureMSGCollectionView()
        configureMessageInputBar()
        
        loadMessages()
        listenForNewMessages()
                
        configureCustomTitle()
        createTypingObserver()
        
        listenForReadStatusUpdates()
        
        navigationItem.largeTitleDisplayMode = .never
        
        print("akb::Realm Path::\(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    private func configureMSGCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.actionAttachMessage(button)
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button],
                                          forStack: .left,
                                          animated: false)
        
        micButton.setSize(CGSize(width: 35, height: 35), animated: false)
        micButton.image = UIImage(systemName: "mic.fill")
        micButton.addGestureRecognizer(longPressGesture)
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    // MARK: - long press configration
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self,
                                                        action: #selector(recordAndSend))
        
    }
    
    // MARK: - configure custom title
    
    private func configureCustomTitle() {
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain, target: self,
                                         action: #selector(tappeddBackButton))

        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        navigationItem.leftBarButtonItems = [backButton, leftBarButtonItem]
        
        titleLabel.text = self.recipientName
    }
    
    @objc private func tappeddBackButton() {
        removeListener()
        FChatRoomListener.shared.clearUnreadCounterUsingChatRoomId(chatRoomId: chatRoomId)
                
        if self.presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    // MARK: - MarkMessageAs Read
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != User.currentId {
            FMessageListener.shared.updateMessageStatus(localMessage, userId: recipientId)
        }
    }
    
    // MARK: - Updadte typing indicator
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "Typing...":""
    }
    
    func startTypingIndicator() {
        typingCounter += 1
        FTypingListener.saveTypingCounter(typing: true, chatRoomId: chatRoomId)
        
        // Stop typing after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.stopTypingIndicator()
        }
    }
    
    func stopTypingIndicator() {
        typingCounter -= 1
        if typingCounter == 0 {
            FTypingListener.saveTypingCounter(typing: false, chatRoomId: chatRoomId)
        }
    }
    
    func createTypingObserver() {
        FTypingListener.shared.createTypingObserver(chatRoomId: chatRoomId) { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        }
    }
    
    // MARK: - Actions
    
    func send(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        Outgoing.sendMessage(chatRoomId: chatRoomId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [User.currentId, recipientId])
    }
    
    // Record and send function
    
    @objc private func recordAndSend() {
        switch longPressGesture.state {
        case .began:
            // record and start recording
            audioFileName = Date().stringDate()
            audioStartTime = Date()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            // stop recording
            // send the audio message
            AudioRecorder.shared.finishRecording()
            
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                let audioDuration = audioStartTime.interval(ofComponent: .second, to: Date())
                send(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioDuration)
            } else {
                print("No file found")
            }
        default:
            break
        }
    }
    
    
    private func actionAttachMessage(_ sender: InputBarButtonItem) {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { [weak self] _ in
            self?.showImageGallery(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Show Location", style: .default) { [weak self] _ in
            self?.showLocation()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        actionSheet.addAction(takePhotoOrVideo)
        actionSheet.addAction(shareMedia)
        actionSheet.addAction(shareLocation)
        actionSheet.addAction(cancel)
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.frame
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                self.insertMoreMKMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
    
    // MARK: Load Messages
    
    private func loadMessages() {
        
        let preddicate = NSPredicate(format: "chatRoomId = %@", chatRoomId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(preddicate).sorted(byKeyPath: kDATE, ascending: true)
        
        if allLocalMessages.isEmpty {
            checkForOlddMessage()
        }
        
        notificationToken = allLocalMessages.observe({ [weak self] (change: RealmCollectionChange) in
            switch change {
            case .initial(_):
                self?.insertMKMessages()
            case .update(_, _, let insertions, _):
                for index in insertions {
                    if let message = self?.allLocalMessages[index] {
                        self?.insertMKMessage(localMessage: message)
                    }
                }
            case .error(let error):
                print("error on new insertion:", error.localizedDescription)
            }
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToLastItem()
        })
    }
    
    private func insertMKMessage(localMessage: LocalMessage) {
        markMessageAsRead(localMessage)
        let incoming = Incoming(messagesViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.append(mkMessage)
        displayingMessagesCount += 1
    }
    
    private func insertOlderMKMessage(localMessage: LocalMessage) {
        let incoming = Incoming(messagesViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.insert(mkMessage, at: 0)
        displayingMessagesCount += 1
    }
    
    private func insertMKMessages() {
        
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber..<maxMessageNumber {
            insertMKMessage(localMessage: allLocalMessages[i])
        }
    }
        
    private func insertMoreMKMessages() {
        
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber...maxMessageNumber).reversed() {
            insertOlderMKMessage(localMessage: allLocalMessages[i])
        }
    }
    
    private func checkForOlddMessage() {
        FMessageListener.shared.checkForOldMessage(User.currentId, collectionId: chatRoomId)
    }
    
    private func listenForNewMessages() {
        FMessageListener.shared.listenForNewMessages(User.currentId, collectionId: chatRoomId, lastMessageDate: lastMessageDate())
    }
    
    // MARK: - Update Read Status
    
    private func updateReadStatus(_ updatedLocalMessage: LocalMessage) {
        for index in 0..<mkMessages.count {
            let tempMessage = mkMessages[index]
            if updatedLocalMessage.id == tempMessage.messageId {
                mkMessages[index].status = updatedLocalMessage.status
                mkMessages[index].readDate = updatedLocalMessage.readDate
                
                RealmManager.shared.save(updatedLocalMessage)
                
                if mkMessages[index].status == kREAD {
                    messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func listenForReadStatusUpdates() {
        FMessageListener.shared.listenForReadStats(User.currentId, collecitonId: chatRoomId) { [weak self] updatedMessage in
            self?.updateReadStatus(updatedMessage)
        }
    }
    
    // MARK: - Helpers
    
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    private func removeListener() {
        FTypingListener.shared.removeTypingListener()
        FMessageListener.shared.removeMessageListener()
    }
    
    // MARK: - Gallery
    
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        present(gallery, animated: true)
    }
    
    // MARK: - Location
    
    private func showLocation() {
        guard let currentLocation = LocationManager.shared.currentLocation else { return }

        let vc = LocationViewController(coordinates: currentLocation, viewType: .editer)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoordinates in
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            self?.send(text: nil, photo: nil, video: nil, audio: nil, location: "\(longitude)_\(latitude)")
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatRoomViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0,
           let firstImage = images.first {
            firstImage.resolve { [weak self] image in
                self?.send(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
                
        send(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true)
    }
}
