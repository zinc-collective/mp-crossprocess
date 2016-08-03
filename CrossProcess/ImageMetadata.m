//
//  ImageMetadata.m
//  CrossProcess
//
//  Created by Sean Hess on 8/3/16.
//  Copyright © 2016 Copyright Banana Camera Company 2010 - 2012. All rights reserved.
//

#import "ImageMetadata.h"

@implementation ImageMetadata


+(void)fetchMetadataForURL:(NSURL*)url found:(void(^)(NSDictionary*))found {
    PHAsset * asset = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil][0];
    
    [ImageMetadata fetchMetadataForAsset:asset found:found];
}

+(void)fetchMetadataForAsset:(PHAsset*)asset found:(void(^)(NSDictionary*))found {
    PHContentEditingInputRequestOptions * options = [[PHContentEditingInputRequestOptions alloc] init];
    options.networkAccessAllowed = true;
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        
        NSURL * fullURL = [contentEditingInput fullSizeImageURL];
        CIImage* fullImage = [CIImage imageWithContentsOfURL:fullURL];
        NSDictionary * meta = [fullImage properties];
        found(meta);
    }];
}


@end
