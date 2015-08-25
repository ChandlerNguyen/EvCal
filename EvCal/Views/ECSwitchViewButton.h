//
//  ECSwitchViewButton.h
//  EvCal
//
//  Created by Tom on 8/25/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ECSwitchViewButtonDirection) {
    ECSwitchViewButtonDirectionRight,
    ECSwitchViewButtonDirectionLeft,
};

@interface ECSwitchViewButton : UIView

@property (nonatomic) ECSwitchViewButtonDirection direction;
@property (nonatomic, weak) IBOutlet UIButton* button;
@property (nonatomic, weak) IBOutlet UIView* accessoryView;

@end
