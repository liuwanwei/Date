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
    OperateTypeSet= 0,
    OperateTypeShow
}OperateType;

@interface ReminderMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) OperateType type;
@property (weak, nonatomic) Reminder * reminder;

@property (weak, nonatomic) IBOutlet MKMapView * mapView;


@end
