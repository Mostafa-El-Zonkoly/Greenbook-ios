//
//  ImageUploader.swift
//  greenBook
//
//  Created by Mostafa on 11/21/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import ReachabilitySwift
import Alamofire
import FirebaseCore
import FirebaseStorage

class ImageUploader: AbstractManager {
 
    
    func uploadImage(imageData: Data, handler: @escaping (Response) -> Void){
        // Create a root reference
        let storageRef = FIRStorage.storage().reference()
        var user_id = -1
        if UserSession.sharedInstant.userLoggedIn() {
            user_id = UserSession.sharedInstant.currUser.id
        }
        let imageRef = storageRef.child("clients/\(Date().description)_\(user_id).jpg")
        let uploadTask = imageRef.put(imageData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                let apiResponse = Response()
                apiResponse.status = false
                apiResponse.error = GBError()
                apiResponse.error?.error = error
                handler(apiResponse)
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL()
            let apiResponse = Response()
            apiResponse.result = downloadURL
            apiResponse.status = true
            handler(apiResponse)
            return
        }
    }
}
