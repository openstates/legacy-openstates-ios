AppendingFlowView - Dynamic iOS flow charty thing 
=============
by Gregory S. Combs, based on work at [GitHub](https://github.com/grgcombs/AppendingFlowView)

Description
=============

- Intended to visually portray some (simple) process with stages. 
- A stages and stage status may be added/deleted dynamically, as needed, animating changes. 
- FlowView width is constrained, but resizes height as needed (to accommodate additional stages). 
- FlowView re-animates it's content views as it reorganizes itself for landscape/portrait orientation. 
- Handles multiple rows of stages/boxes. 
- Customizable fonts, colors, backgrounds, etc. 
- Sample application demos the FlowView as a bill in the legislative process. 
- This is incredibly simplistic, sure, but I'd like to see you come up with something better. (Fork it!) 

How To Use it
=============

    // in your view controller
    - (void)viewDidLoad {
        AppendingFlowView *flowView = [[AppendingFlowView] initWithFrame:CGRectMake(self.view.bounds)];
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
        
        flowView.font = [self.flowView.font fontWithSize:12.f];
        flowView.preferredBoxSize = CGSizeMake(65.f, 35.f);
        flowView.connectorSize = CGSizeMake(16.f, 6.f);
        flowView.uniformWidth = YES;
        flowView.pendingAlpha = 0.6f;
        flowView.stages = stages;
        
        [self.view addSubview:flowView];
        [flowView release];
        
        [stage1 release];
        [stage2 release]; 
        [stage3 release];
        [stage4 release];
        [stage5 release];
        [stage6 release];
        [stage7 release];
        [stages release];

        [super viewDidLoad];
    } 

Technology
=============

- Written in Objective-C for iOS/iPad/iPhone/iPod.

Attributions
=============
- I wrote this to answer one of my own questions at [StackOverflow](http://stackoverflow.com/questions/5859381/simple-but-dynamically-generated-flow-chart-or-process-chart-view-for-ios).
- The visual concept originated from the [Texas Legislature Online](http://www.legis.state.tx.us/BillLookup/BillStages.aspx?LegSess=821&Bill=SB1).
- Clues on how to implement it came from the folks who created [NMView](http://www.github.com/nextmunich/NMView).
- You can see it in live-action once I release another update to [TexLege](http://www.texlege.com).

License
=========================

[Under a Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/)

![Creative Commons License Badge](http://i.creativecommons.org/l/by/3.0/88x31.png "Creative Commons Attribution")

Screenshots
=========================

![Screenshot](https://github.com/grgcombs/AppendingFlowView/raw/master/screenshot.png "AppendingFlowView")
