//
//  PhotoSource.swift
//  CrossProcess
//
//  Created by Cricket on 10/23/23.
//  Copyright © 2023 Zinc Collective LLC. All rights reserved.
//

import Foundation

@objc protocol PhotoProvider {
    func getAsset(imageURL: NSURL, success:(CGImage) -> Void, failure: (NSError?) -> Void) -> Void
}


@objc class PhotoSource: NSObject, PhotoProvider {
    @objc func getAsset(imageURL: NSURL, success: (_ asset: CGImage) -> Void, failure: (_ error: NSError?) -> Void) {
        // NoOp
        // Need to get the image and set it to the source var
        var source: CGImage? = UIImage().cgImage
        guard let asset = source else {
            failure(nil)
            return
        }
        success(asset)
    }
}
