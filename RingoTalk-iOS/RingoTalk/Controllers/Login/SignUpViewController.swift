//
//  SignUpViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ProgressHUD

class SignUpViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet { avatarImageView.circleImage() }
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! 
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton! {
        didSet { registerButton.layer.cornerRadius = 12 }
    }
    @IBOutlet weak var aleadyHaveAccountButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func tappedAleadyHaveAccountButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
        
    @IBAction func tappeddProfileImage(_ sender: UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func tappedRegisterButton(_ sender: UIButton) {
        didTapRegisterButton()
    }
    
    private func didTapRegisterButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let username = usernameTextField.text else { return }
                   
        FUserListener.shared.registerUserWith(email: email, password: password, username: username) { [weak self] result in
            switch result {
            case .success(let user):
                self?.uploadAvatarImage(user.id)
            case .failure(let error):
                ProgressHUD.showError("failed to signup: \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadAvatarImage(_ uid: String) {
        if let image = avatarImageView.image {
            let fileDirectory = "Avatars/_\(uid).png"
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
        
        dismiss(animated: true)
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            avatarImageView.image = editImage
        } else if let originImage = info[.originalImage] as? UIImage {
            avatarImageView.image = originImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        
        registerButton.isEnabled = !(emailIsEmpty || passwordIsEmpty || usernameIsEmpty)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            didTapRegisterButton()
        }
        
        return true
    }
}
