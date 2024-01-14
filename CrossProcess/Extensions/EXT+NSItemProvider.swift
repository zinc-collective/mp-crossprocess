//
//  EXT+NSItemProvider.swift
//  CrossProcess
//
//  Created by Cricket on 1/14/24.
//  Copyright © 2024 Zinc Collective LLC. All rights reserved.
//

import Foundation


// MARK: - NSItemProvider to support WebP format (PNG-based and JPEG-based)
@objc extension NSItemProvider {
    enum NSItemProviderLoadImageError: Error {
        case unexpectedImageType
    }
    
    @objc func loadImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        if canLoadObject(ofClass: UIImage.self) {
            
            // Handle UIImage type
            loadObject(ofClass: UIImage.self) { image, error in
               
                guard let resultImage = image as? UIImage else {
                    completion(nil, error)
                    return
                }
                
                completion(resultImage, error)
            }
            
        } else if hasItemConformingToTypeIdentifier(UTType.webP.identifier) {
            
            // Handle WebP Image
            loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) { data, error in
                
                guard let data,
                      let webpImage = UIImage(data: data) else {
                    completion(nil, error)
                    return
                }
                
                completion(webpImage, error)
            }
            
        } else {
            completion(nil, NSItemProviderLoadImageError.unexpectedImageType)
        }
    }
}

