//
//  FUserListener.swift
//  Message
//
//  Created by Yoo on 2022/05/12.
//

import Foundation
import Firebase

class FUserListener {
    
    static let shared = FUserListener()
    
    // MARK: - Login
    
    func loginUserWith(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResults, error) in            
            if let error = error {
                completion(.failure(error))
            } else {
             /*&& authResults!.user.isEmailVerified*/
                completion(.success(true))
                self?.saveUserLocallyFromFirestore(userId: authResults!.user.uid)
            }
        }
    }
    
    // MARK: - Logout
    
    func logoutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    // MARK: - Register
    
    func registerUserWith(email: String, password: String, username: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResults, error in
            guard let authResults = authResults else { return }
            if let error = error {
                print("failed to create user: \(error)")
                completion(.failure(error))
                return
            }
            
//            authResults.user.sendEmailVerification { error in
//                if let error = error {
//                    print("failed to send email verification: \(error)")
//                }
//            }
            
            let user = User(id: authResults.user.uid,
                            username: username,
                            email: email,
                            pushId: "",
                            avatarLink: "")
            self?.saveUserFirestore(user)
            
            saveUserLocally(user)
            
            completion(.success(user))            
        }
    }
    
    // MARK: - Resend link verficiation function
    
    func resendVerficationEmailWith(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload() { error in
            Auth.auth().currentUser?.sendEmailVerification() { error in
                completion(error)
            }
        }
    }
    
    
    // MARK: - Reset password
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)            
        }
    }
    
    // MARK: - Get User
    
    func getUsers(withIds: [String], completion: @escaping (_ allUSers: [User]) -> Void) {
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            FirestoreReference(.User).document(userId).getDocument { snapshot, error in
                guard let document = snapshot else { return }
                
                if let user = try? document.data(as: User.self) {
                    usersArray.append(user)
                }
                count += 1
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        FirestoreReference(.User).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document dound")
                return
            }
            
            let allUsers = documents.compactMap { snap -> User? in
                return try? snap.data(as: User.self)
            }
            
            let users: [User] = allUsers.filter { $0.id !=  User.currentUser?.id }
            
            completion(.success(users))
        }
    }
    
    // MARK: - Save User
    
    func saveUserFirestore(_ user: User) {
        do {
            try FirestoreReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveUserLocallyFromFirestore(userId: String) {
        FirestoreReference(.User).document(userId).getDocument { document, error in
            guard let userDocument = document else {
                print("no data found")
                return
            }
            
            let result = Result {
                try? userDocument.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("error decoding user: \(error)")
            }
        }
    }
}

