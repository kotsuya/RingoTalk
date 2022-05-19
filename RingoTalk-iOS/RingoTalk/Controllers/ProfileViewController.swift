//
//  ProfileViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/06.
//

import UIKit
import ProgressHUD
import SDWebImage

class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet { avatarImageView.circleImage() }
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction func tappedLogoutButton(_ sender: UIButton) {
        FUserListener.shared.logoutCurrentUser { [weak self] error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self?.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    @IBAction func tappeddProfileImage(_ sender: UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    // MARK: - Private func
    
    private func setupUI() {
        if let user = User.currentUser {
            emailTextField.text = user.email
            usernameTextField.text = user.username
            
            if !user.avatarLink.isEmpty {
                guard let imageUrl = URL(string: user.avatarLink) else { return }
                avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                avatarImageView.sd_setImage(with: imageUrl)
            } else {
                avatarImageView.image = UIImage(systemName: "person.circle")                
            }
        }
    }
    
    private func didTapUpdateButton() {
        guard let username = usernameTextField.text else { return }
        if !username.isEmpty {
            if var user = User.currentUser {
                user.username = username
                saveUserLocally(user)
                FUserListener.shared.saveUserFirestore(user)
            }
        }
        dismissKeyboard()
    }
    
    private func uploadAvatarImage(_ image: UIImage) {
        let fileDirectory = "Avatars/_\(User.currentId).png"
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user)
                FUserListener.shared.saveUserFirestore(user)
            }
                        
            guard let imageData = image.pngData() as? NSData else { return }
            FileStorage.saveFileLocally(fileData: imageData, fileName: User.currentId)
        }
    }

    private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            uploadAvatarImage(editImage)
            avatarImageView.image = editImage
        } else if let originImage = info[.originalImage] as? UIImage {
            uploadAvatarImage(originImage)
            avatarImageView.image = originImage
        }

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField,
           let text = textField.text {
            if !text.isEmpty {
                if var user = User.currentUser {
                    user.username = text
                    saveUserLocally(user)
                    FUserListener.shared.saveUserFirestore(user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
