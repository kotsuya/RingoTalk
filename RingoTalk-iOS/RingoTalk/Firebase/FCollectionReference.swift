//
//  FCollectionReference.swift
//  Message
//
//  Created by Yoo on 2022/05/12.
//

import Foundation
import Firebase

enum FCollectionReference: String {
    case User
    case Chat
    case Message
    case Typing
    case Channel
    
}

func FirestoreReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
