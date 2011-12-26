//
//  AppendingFlowDemoViewController.m
//
//  AppendingFlowView by Gregory S. Combs, based on work at https://github.com/grgcombs/AppendingFlowView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "AppendingFlowDemoViewController.h"
#import "AppendingFlowView.h"

@implementation AppendingFlowDemoViewController
@synthesize flowView=flowView_;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	AppendingFlowStage *stage1, *stage2, *stage3, *stage4, *stage5, *stage6, *stage7;
	
	stage1 = [[AppendingFlowStage alloc] initWithStage:1 
											 stageType:FlowStageReached 
											   caption:NSLocalizedStringFromTable(@"Stage1", @"DemoStages", @"")];
	stage2 = [[AppendingFlowStage alloc] initWithStage:2 
											 stageType:FlowStageReached 
											   caption:NSLocalizedStringFromTable(@"Stage2", @"DemoStages", @"")];
	stage3 = [[AppendingFlowStage alloc] initWithStage:3 
											 stageType:FlowStageReached 
											   caption:NSLocalizedStringFromTable(@"Stage3", @"DemoStages", @"")];
	stage4 = [[AppendingFlowStage alloc] initWithStage:4 
											 stageType:FlowStageFailed 
											   caption:NSLocalizedStringFromTable(@"Stage4", @"DemoStages", @"")];
	stage5 = [[AppendingFlowStage alloc] initWithStage:5 
											   caption:NSLocalizedStringFromTable(@"Stage5", @"DemoStages", @"")];
	stage6 = [[AppendingFlowStage alloc] initWithStage:6 
											   caption:NSLocalizedStringFromTable(@"Stage6", @"DemoStages", @"")];
	stage7 = [[AppendingFlowStage alloc] initWithStage:7 
											   caption:NSLocalizedStringFromTable(@"Stage7", @"DemoStages", @"")];
	
	NSArray *stages = [[NSArray alloc] initWithObjects:stage1, stage2, stage3, stage4, stage5, stage6, stage7, nil];

	self.flowView.font = [self.flowView.font fontWithSize:12.f];
	self.flowView.preferredBoxSize = CGSizeMake(65.f, 35.f);
	self.flowView.connectorSize = CGSizeMake(16.f, 6.f);
	self.flowView.uniformWidth = YES;
	self.flowView.pendingAlpha = 0.6f;
	self.flowView.stages = stages;
		
	[stage1 release];
	[stage2 release];	
	[stage3 release];
	[stage4 release];
	[stage5 release];
	[stage6 release];
	[stage7 release];
	[stages release];
	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	self.flowView = nil;
	
    [super dealloc];
}

@end
