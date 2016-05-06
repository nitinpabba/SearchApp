//
//  ResponseRow.h
//  Macys
//
//  Created by Nitin Pabba on 5/5/16.
//  Copyright © 2016 Nitin Pabba. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ResponseRow : NSObject

@property(nonatomic, strong) NSString *mainString;
@property(nonatomic, strong) NSString *subString;

-(void) parseFromDictionary:(NSDictionary *) dictionary;

@end
