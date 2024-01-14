//
//  PhotoSource.swift
//  CrossProcess
//
//  Created by Cricket on 10/23/23.
//  Copyright © 2023 Zinc Collective LLC. All rights reserved.
//

import Foundation

@objc protocol PhotoProvider {
    func getAsset(imageURL: NSURL, success: @escaping (CGImage) -> Void, failure: @escaping (NSError?) -> Void) -> Void
}


@objc class PhotoSource: NSObject, PhotoProvider {
    @objc func getAsset(imageURL: NSURL, success: @escaping (_ asset: CGImage) -> Void, failure: @escaping (_ error: NSError?) -> Void) {
        // Ensure you have access to the Photos library
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                // Request a fetch result for assets matching the URL
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [imageURL.absoluteString!], options: fetchOptions)

                // Check if any assets were found
                if fetchResult.count > 0 {
                    let asset = fetchResult.firstObject // Access the first matching asset
                    
                    // Request the image representation for the asset
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true  // Synchronous for simplicity in this example
                    PHImageManager.default().requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, info in
                        if let image = image {
                            success(image.cgImage!)
                            // UIImage successfully retrieved
                            // Use the image as needed
                            print("Image retrieved: \(image)")
                        } else {
                            let error:NSError = NSError(domain: "Error retrieving image.", code: -1)
                            failure(error)
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    let error:NSError = NSError(domain: "No assets found matching the URL.", code: -1)
                    failure(error)
                    print(error.localizedDescription)
                }
            } else {
                // Handle cases where authorization is not granted
                let error:NSError = NSError(domain: "Access to Photos library not authorized.", code: -1)
                failure(error)
                print(error.localizedDescription)
            }
        }
    }
}
