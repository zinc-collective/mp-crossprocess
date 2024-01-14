//
//  ImageMetadata.m
//  CrossProcess
//
//  Created by Sean Hess on 8/3/16.
//  Copyright  2019 Zinc Collective LLC. All rights reserved.
//

#import "ImageMetadata.h"

@implementation ImageMetadata


+(void)fetchMetadataForAssetIdentifier:(NSString*)assetIdentifier found:(void(^)(NSDictionary*))found {
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithLocalIdentifiers:[[NSArray alloc] initWithObjects:assetIdentifier, nil] options:allPhotosOptions];
    NSMutableArray<PHAsset*> *arrPhassets=[[NSMutableArray alloc]init];
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        [arrPhassets addObject:asset];
    }];

    [ImageMetadata fetchMetadataForAsset:arrPhassets.firstObject found:found];
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
