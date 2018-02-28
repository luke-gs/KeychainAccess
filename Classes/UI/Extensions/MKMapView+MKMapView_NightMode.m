//
//  MKMapView+MKMapView_NightMode.m
//  MPOLKit
//
//  Created by Herli Halim on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

#import "MKMapView+MKMapView_NightMode.h"

@interface MKMapView(NightMode)
- (void)_setShowsNightMode:(BOOL)enabled;
@end

@implementation MKMapView (MKMapView_NightMode)

- (void)mpl_setNightModeEnabled:(BOOL)enabled {
    if ([self respondsToSelector:@selector(_setShowsNightMode:)]) {
        [self _setShowsNightMode:enabled];
    }
}

@end
