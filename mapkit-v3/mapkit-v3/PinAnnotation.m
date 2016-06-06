//
//  PinAnnotation.m
//  MapKitCoreLocation
//
//  Created by Cuong Trinh on 9/29/15.
//  Copyright © 2015 Cuong Trinh. All rights reserved.
//

#import "PinAnnotation.h"

@implementation PinAnnotation
- (instancetype) init: (CLLocationCoordinate2D) coordinate
            withColor: (UIColor*) color
            withTitle: (NSString*) title
         withSubTitle: (NSString*) subTitle {
    if (self = [super init]) {
        _coordinate = coordinate;
        _title = title;
        _subtitle= subTitle;
        self.color = color;
    }
    
    return self;
}
@end
