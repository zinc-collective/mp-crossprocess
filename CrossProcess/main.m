//
//  main.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <unistd.h>
#import <stdlib.h>

#import "CPAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        srand48(time(NULL));

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CPAppDelegate class]));
    }
}
