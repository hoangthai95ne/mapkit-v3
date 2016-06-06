//
//  PinAnnotation.h
//  MapKitCoreLocation
//
//  Created by Cuong Trinh on 9/29/15.
//  Copyright © 2015 Cuong Trinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface PinAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong, nullable) UIColor* color;

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

@property (nonatomic, weak, nullable) UIImage *image;

- (nonnull instancetype) init: (CLLocationCoordinate2D) coordinate
            withColor: (nullable UIColor*) color
            withTitle: (nullable NSString*) title
         withSubTitle: (nullable  NSString*) subTitle;

@end
