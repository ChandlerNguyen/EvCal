//
//  ECEditEventMultiPickerCell.h
//  EvCal
//
//  Created by Tom on 8/15/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECEditEventMultiPickerCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak, readonly) UIPickerView* primaryPickerView;
@property (nonatomic, weak, readonly) UIPickerView* secondaryPickerView;

@end
