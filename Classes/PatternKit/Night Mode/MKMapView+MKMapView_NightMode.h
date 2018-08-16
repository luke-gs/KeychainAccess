//
//  MKMapView+MKMapView_NightMode.h
//  MPOLKit
//
//  Created by Herli Halim on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

#import <MapKit/MKMapView.h>

@interface MKMapView (MKMapView_NightMode)

// This uses private API, so prefix, in case if it ever being public.
- (void)mpl_setNightModeEnabled:(BOOL)enabled;

@end
