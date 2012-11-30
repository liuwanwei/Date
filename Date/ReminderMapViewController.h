//
//  ReminderMapViewController.h
//  Date
//
//  Created by maoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Reminder.h"

typedef enum {
    MapOperateTypeSet = 0,
    MapOperateTypeShow
}MapOperateType;

@interface ReminderMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) MapOperateType type;
@property (weak, nonatomic) Reminder * reminder;

@property (weak, nonatomic) IBOutlet MKMapView * mapView;


@end
