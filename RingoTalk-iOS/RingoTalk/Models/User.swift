//
//  User.swift
//  Message
//
//  Created by Yoo on 2022/05/12.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id: String
    var username: String
    var email: String
    var pushId: String
    var avatarLink: String
    
    static var currentId: String {
        guard let currentUser = Auth.auth().currentUser else { return "" }
        return currentUser.uid
    }
        
    static var currentUser: User? {        
        if Auth.auth().currentUser != nil {
            if let data = userDefaults.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: data)
                    return userObject
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: kCURRENTUSER)
    } catch {
        print(error.localizedDescription)
    }    
}

func createDummyUsers() {
    
    let names = ["Iron man","Spiderman","Dr.strange","Black widow"]
    
    for i in 0..<names.count {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/_\(id).png"
        
        FileStorage.uploadImage(UIImage(named: "user\(i)")!, directory: fileDirectory) { avatarLink in
            
            let user = User(id: id, username: names[i], email: "user\(i)@gmail.com", pushId: "", avatarLink: avatarLink ?? "")
            
            FUserListener.shared.saveUserFirestore(user)
        }
    }
}
