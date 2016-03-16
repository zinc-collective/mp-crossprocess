//
//  BCMiscellaneous.m
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import "BCMiscellaneous.h"
#import <objc/runtime.h>

id BCDynamicCast(Class c, id<NSObject> src)
{
	id result = nil;
    
	if(src != nil && [src isKindOfClass: c])
		result = src;
    
	return result;
}


id BCProtocolCast(Protocol* protocol, id<NSObject> src)
{
	id result = nil;
    
	if(src != nil && [src conformsToProtocol: protocol])
		result = src;
    
	return result;
}


CFTypeRef BCCFTypeCast(CFTypeID typeId, CFTypeRef src)
{
    CFTypeRef result = NULL;
    
    if (src != NULL && CFGetTypeID(src) == typeId)
        result = src;
    
    return result;
}

@implementation UIView(IndexedViews)

static NSInteger sViewIndexKey;

- (NSInteger) index
{
    NSNumber*   viewIndex = (NSNumber*)objc_getAssociatedObject(self, &sViewIndexKey);
    return [viewIndex integerValue];
}

- (void) setIndex: (NSInteger) index
{
    NSNumber*   viewIndex = [NSNumber numberWithInteger: index];
    objc_setAssociatedObject(self, &sViewIndexKey, viewIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

