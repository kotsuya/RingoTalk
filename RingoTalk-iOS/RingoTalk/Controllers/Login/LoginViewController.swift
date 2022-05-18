//
//  LoginViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/06.
//

import UIKit
import FirebaseAuth
import Firebase
import ProgressHUD

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton! {
        didSet { loginButton.layer.cornerRadius = 12 }
    }
    @IBOutlet weak var dontHaveAccountButton: UIButton!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions

    @IBAction func tappedDontHaveAccountButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func tappedLoginButton(_ sender: UIButton) {
        didTapLoginButton()
    }

    private func didTapLoginButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        FUserListener.shared.loginUserWith(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let isEmailVerified):
                if isEmailVerified {
                    if !User.currentId.isEmpty {
                        let pushManager = PushNotificationManager(userID: User.currentId)
                        pushManager.registerForPushNotifications()
                    }
                } else {
                    ProgressHUD.showFailed("Please check your email and verify your registration")
                }
            case .failure(let error):
                ProgressHUD.showError("failed to login: \(error.localizedDescription)")
            }
            self?.dismiss(animated: true)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false

        loginButton.isEnabled = !(emailIsEmpty || passwordIsEmpty)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            didTapLoginButton()
        }

        return true
    }
}
