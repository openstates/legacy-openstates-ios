//
//  VotingRecordDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 3/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "S7GraphView.h"


@interface VotingRecordDataSource : NSObject <S7GraphViewDataSource,S7GraphViewDelegate>{
	NSNumber *legislatorID;
	NSDictionary *chartData;
}
@property (nonatomic,retain) NSNumber *legislatorID;
@property (nonatomic,retain) NSDictionary *chartData;

- (void)prepareVotingRecordView:(S7GraphView *)aView;

@end
