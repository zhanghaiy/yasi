//
//  PersonInfoModel.h
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonInfoModel : NSObject

@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *studentname;
@property (nonatomic,strong) NSString *totallength;
@property (nonatomic,strong) NSString *countclasstype;
@property (nonatomic,strong) NSString *countpassclasstype;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSArray *notPassList;
@property (nonatomic,strong) NSArray *passList;


@end
