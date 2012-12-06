//
//  ReminderMapViewController.m
//  Date
//
//  Created by lixiaoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderMapViewController.h"
#import "SinaWeiboManager.h"

@interface ReminderMapViewController () {
    MKPointAnnotation * _pointAnnotation;
    BOOL _isLongPress;
}

@end

@implementation ReminderMapViewController
@synthesize mapView = _mapView;
@synthesize type = _type;
@synthesize reminder = _reminder;

- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetAddressMessage:) name:kGetAddressMessage object:nil];
}

- (void)handleGetAddressMessage:(NSNotification *)note {
    if (nil != note && nil != note.userInfo) {
        NSDictionary * dictionary = note.userInfo;
        NSString * value = [dictionary objectForKey:@"address"];
        if (nil != value) {
            _reminder.longitude = [NSString stringWithFormat:@"%f",_pointAnnotation.coordinate.longitude];
            _reminder.latitude = [NSString stringWithFormat:@"%f",_pointAnnotation.coordinate.latitude];
//            _reminder.desc = value;
            
            [self dismiss];
        }
    }
}

- (void)initMapView {
    _mapView.delegate = self;
    MKCoordinateRegion theRegion;

    if (MapOperateTypeSet == _type) {
        _mapView.showsUserLocation=YES;
        
        CLLocationManager * locationManager = [[CLLocationManager alloc] init];//创建位置管理器
        locationManager.delegate = self ;//设置代理
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//指定需要的精度级别
        locationManager.distanceFilter = 10.0f;//设置距离筛选器
        [locationManager startUpdatingLocation];//启动位置管理器
        
        //定义一个区域（用定义的经纬度和范围来大小来定义）
        theRegion.center = [[locationManager location] coordinate];
        
        //长按事件
        UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        lpress.minimumPressDuration = 1.0;//按1秒响应longPress方法
        lpress.allowableMovement = 10.0;
        [_mapView addGestureRecognizer:lpress];
    }else {
        CLLocationCoordinate2D coordinate;
        coordinate.longitude = [_reminder.longitude doubleValue];
        coordinate.latitude = [_reminder.latitude doubleValue];
        theRegion.center = coordinate;
        
        _pointAnnotation = [[MKPointAnnotation alloc] init];
        _pointAnnotation.coordinate = coordinate;
        [_mapView addAnnotation:_pointAnnotation];
    }
    
    //定义显示的范围
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.01;
    theSpan.longitudeDelta = 0.01;
    theRegion.span = theSpan;
    //在地图上显示此区域
    [_mapView setRegion:theRegion animated:YES];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        _isLongPress = YES;
        //取地图上的长按的点坐标
        CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
        //将点坐标转换为经纬度坐标
        CLLocationCoordinate2D touchMapCoordinate =
        [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
        NSLog(@"%f   %f",touchMapCoordinate.latitude,touchMapCoordinate.longitude);
        //初始化详情弹出框对象
        if (nil == _pointAnnotation) {
            _pointAnnotation = [[MKPointAnnotation alloc] init];
        }else {
            [_mapView removeAnnotation:_pointAnnotation];
                       
        }
    
        //位置
        _pointAnnotation.coordinate = touchMapCoordinate;
        [_mapView addAnnotation:_pointAnnotation];
    
    }
}

/**********************************************
 函数名称 : viewForAnnotation
 函数描述 : 在地图上加入大头针，及其动画。
 输入参数 : mapView，theMapView，annotation。
 输出参数 : N/A
 返回值	: N/A
 *********************************************/
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKPinAnnotationView * pinView;
    if (YES == _isLongPress) {
        static NSString * AnnotationIdentifier = @"AnnotationIdentifier";
        pinView = (MKPinAnnotationView *)[mV dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        //初始化大头针对象
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        }else{
            pinView.annotation = annotation;
        }
        
        pinView.pinColor = MKPinAnnotationColorRed;//设置大头针的颜色
        pinView.animatesDrop = YES;                //坠落动画
        pinView.canShowCallout = YES;              //显示详情
    }
   
    
    return pinView;
}


- (void)dismiss {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    [[SinaWeiboManager defaultManager] requestAddressWithCoordinate2D:_pointAnnotation.coordinate];
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (MapOperateTypeSet == _type) {
        [self registerHandleMessage];
        _isLongPress = NO;

        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = rightItem;

    }

    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initMapView];
}

@end
