//
//  ImageMetadata.h
//  CrossProcess
//
//  Created by Sean Hess on 8/3/16.
//  Copyright  2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ImageMetadata : NSObject

+(void)fetchMetadataForAsset:(PHAsset*)asset found:(void(^)(NSDictionary*))found;
+(void)fetchMetadataForAssetIdentifier:(NSString*)assetIdentifier found:(void(^)(NSDictionary*))found;

@end
