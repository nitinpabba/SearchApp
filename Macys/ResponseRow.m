//
//  ResponseRow.m
//  Macys
//
//  Created by Nitin Pabba on 5/5/16.
//  Copyright © 2016 Nitin Pabba. All rights reserved.
//

#import "ResponseRow.h"

@implementation ResponseRow

-(void) parseFromDictionary:(NSDictionary *) dictionary{
    
    self.mainString = [dictionary valueForKey:@"lf"];
    self.subString = [NSString stringWithFormat:@"Freq %@ | Since %@",[dictionary valueForKey:@"freq"], [dictionary valueForKey:@"since"]];
    
}

@end
