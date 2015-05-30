//
//  ECDatePickerCell.h
//  EvCal
//
//  Created by Tom on 5/30/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDatePickerCell : UICollectionViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date displayed by the cell
@property (nonatomic, strong) NSDate* date;

@end
