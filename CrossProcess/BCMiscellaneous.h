//
//  BCMiscellaneous.h
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#define BCCastAsClass(C, SRC)	((C*)BCDynamicCast([C class], SRC))
#define BCCastAsProtocol(P, SRC)	((id<P>)BCProtocolCast(@protocol(P), SRC))
#define BCCastAsCFType(T, SRC) ((T ## Ref)BCCFTypeCast(T ## GetTypeID(), SRC))

//#define AppDelegate() ((CPAppDelegate*)[UIApplication sharedApplication].delegate)

#ifdef __cplusplus
extern "C" {
#endif
    
    id BCDynamicCast(Class c, id<NSObject> src);
    id BCProtocolCast(Protocol* protocol, id<NSObject> src);
    CFTypeRef BCCFTypeCast(CFTypeID typeId, CFTypeRef src);

    NS_INLINE CGFloat radians(CGFloat degrees) { return (CGFloat)(degrees * M_PI / 180.0f); }
    
#ifdef __cplusplus
}
#endif

/*

 CGFloat scale = MIN (r.size.width / s.width, r.size.height / s.height);
 s.width = trunc(s.width * scale); 
 s.height = trunc(s.height * scale);
 r.origin.x += trunc((r.size.width - s.width) * .5);
 r.size.width = s.width;
 r.origin.y += trunc((r.size.height - s.height) * .5);
 r.size.height = s.height;

*/

// Category on UIView that uses objc_get/setAssociatedObject to add an index ivar.

@interface UIView(IndexedViews)

- (NSInteger) index;
- (void) setIndex: (NSInteger) index;

@end
