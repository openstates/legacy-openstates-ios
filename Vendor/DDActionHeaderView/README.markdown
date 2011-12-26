# DDActionHeaderView for iOS 4
Header with title and actions, rapid UI component for quick hands.

## Features
DDActionHeaderView is a new UI component combined the concept of UIToolbar and UINavigationBar. The goal of the design is to allow application **to have both title label and action items in one header, and keep simplicity and accessibility at the same time**.

![](https://github.com/digdog/DDActionHeaderView/raw/master/Screenshots/Portrait.png)

1. Clean and simple user interface.
2. Slick animation as visual hints.
3. Multiline title label.
4. Action items can be any UIView subclass, e.g. UIImageView, UIButton, UIControl, etc.
5. Support orientation.
6. Just one header and one implementation, no third party dependencies, no library headache.
7. Designed for small iOS devices like iPhone or iPod touch, but you can also use it on iPad.

## Requirement

* iOS 4.0 SDK or later, demo project is using iOS 4.2GM SDK.
* QuartzCore framework.

DDActionHeaderView uses Blocks, Quartz 2D, CALayer, CAGradientLayer, CAAnimation and UIGestureRecognizer. 

## How to Use

1. Make sure you link QuartzCore.framework in your target.
2. Create DDActionHeaderView with <code>-initWithFrame:</code> or <code>-initWithCoder:</code>. If you want to create it programmatically, use <code>-initWithFrame:</code>, the frame height is ignored, and is always fixed to 70 pixels height.

        self.actionHeaderView = [[[DDActionHeaderView alloc] initWithFrame:self.view.bounds] autorelease]; 
        // if self.actionHeaderView is a retain property, we need autorelease.

    If you want to use it in Interface Builder, just drag a UIView component and change its class type to DDActionHeaderView. Once you have IBOutlet connected with it, <code>-initWithCoder:</code> will take over the initization.

3. Then you can set the title label.

        self.actionHeaderView.titleLabel.text = @"Tap DDActionHeaderView Action Picker";
	
4. Or set the action items through <code>items</code> property. Items is a NSArray of UIView subclass instances, and the UIView subclass instance can be UIView, UIButton, UIImageView or UIControl, etc. They will be added into a *(DDActionHeaderView's width - 20) pixels width and 50 pixel height* action picker. 

        // Create action items, have to be UIView subclass, and set frame position by yourself.
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [facebookButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        [facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        facebookButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        facebookButton.imageEdgeInsets = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
        facebookButton.center = CGPointMake(25.0f, 25.0f);
    
        UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [twitterButton addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        [twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        twitterButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        twitterButton.imageEdgeInsets = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
        twitterButton.center = CGPointMake(75.0f, 25.0f);
    
        self.actionHeaderView.items = [NSArray arrayWithObjects:facebookButton, twitterButton, nil];	

    Once you set the items array, previous items will be removed from action picker if there is any.

5. You can optionally decide if you want to shrink action picker:

        if (self.actionHeaderView.isActionPickerExpanded) {
            [self.actionHeaderView shrinkActionPicker];
        }

## Screenshots

![](https://github.com/digdog/DDActionHeaderView/raw/master/Screenshots/Portrait.png)  

![](https://github.com/digdog/DDActionHeaderView/raw/master/Screenshots/Landscape.png)  

## License

DDActionHeaderView is released under MIT License.
