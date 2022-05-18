//
//  FireStorage.swift
//  Message
//
//  Created by Yoo on 2022/05/13.
//

import Foundation
import UIKit
import ProgressHUD
import FirebaseStorage

let storage = Storage.storage()

class FileStorage {
    
    // MARK: - Images
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        //1. Create folder on firestore
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
                
        //2. Convert the image to data
        let imageData = image.pngData()
                
        //3. Put the data into firestore and return the link
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil) { metaData, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if let error = error {
                print("Error uploading image \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        }
        
        //4. Observe percentage upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let unitCount = progress.completedUnitCount / progress.totalUnitCount
            ProgressHUD.showProgress(CGFloat(unitCount))
        }
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if fileExistsAtPath(path: imageFileName) {
            // get it locally
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(contentOfFile)
            } else {
                print("Could not convert local image")
                completion(UIImage(systemName: "person.circle.fill")!)
            }
            
        } else {
            // download from firebase
            if imageUrl != "" {
                guard let documentUrl = URL(string: imageUrl) else { return }
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    if let data = NSData(contentsOf: documentUrl) {
                        FileStorage.saveFileLocally(fileData: data, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data as Data))
                        }
                    } else {
                        completion(nil)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Upload Video
    
    class func uploadVideo(_ video: Data, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        
        //1. Create folder on firestore
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
                
        //3. Put the data into firestore and return the link
        var task: StorageUploadTask!
        task = storageRef.putData(video, metadata: nil) { metaData, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if let error = error {
                print("Error uploading image \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        }
        
        //4. Observe percentage upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let unitCount = progress.completedUnitCount / progress.totalUnitCount
            ProgressHUD.showProgress(CGFloat(unitCount))
        }
    }
    
    class func downloadVideo(videoUrl: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        let videoFileName = fileNameFrom(fileUrl: videoUrl) + ".mov"
        if fileExistsAtPath(path: videoFileName) {

            completion(true, videoFileName)
            
        } else {
            // download from firebase
            if videoUrl != "" {
                guard let documentUrl = URL(string: videoUrl) else { return }
                let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
                
                downloadQueue.async {
                    if let data = NSData(contentsOf: documentUrl) {
                        FileStorage.saveFileLocally(fileData: data, fileName: videoFileName)
                        DispatchQueue.main.async {
                            completion(true, videoFileName)
                        }
                    } else {
                        print("no document found in database")
                    }                    
                }
            }
        }
    }
    
    // MARK: - Audio
    
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        //1. Create folder on firestore
        let fileName = audioFileName + ".m4a"
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
                
        //3. Put the data into firestore and return the link
        if fileExistsAtPath(path: fileName) {
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                var task: StorageUploadTask!
                task = storageRef.putData(audioData as Data, metadata: nil) { metaData, error in
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if let error = error {
                        print("Error uploading auiod \(error)")
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        guard let downloadUrl = url else {
                            completion(nil)
                            return
                        }
                        completion(downloadUrl.absoluteString)
                    }
                }
                
                //4. Observe percentage upload
                task.observe(StorageTaskStatus.progress) { snapshot in
                    guard let progress = snapshot.progress else { return }
                    let unitCount = progress.completedUnitCount / progress.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(unitCount))
                }
            }
        } else {
            print("Nothing to upload, or file not exist.")
        }        
    }
    
    class func downloadAudio(audioUrl: String, completion: @escaping (_ audioFileName: String) -> Void) {
        let audioFileName = fileNameFrom(fileUrl: audioUrl) + ".m4a"
        if fileExistsAtPath(path: audioFileName) {

            completion(audioFileName)
            
        } else {
            // download from firebase
            if audioUrl != "" {
                guard let documentUrl = URL(string: audioUrl) else { return }
                let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
                
                downloadQueue.async {
                    if let data = NSData(contentsOf: documentUrl) {
                        FileStorage.saveFileLocally(fileData: data, fileName: audioFileName)
                        DispatchQueue.main.async {
                            completion(audioFileName)
                        }
                    } else {
                        print("no document found in database")
                    }
                }
            }
        }
    }
    
    // MARK: - Svee file locally
    
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
}

// Helpers
func getDocumentURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentURL().appendingPathComponent(fileName).path
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
