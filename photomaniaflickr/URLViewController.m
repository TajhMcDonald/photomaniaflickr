//
//  URLViewController.m
//  photomaniaflickr
//
//  Created by Tajh McDonald on 12/1/16.
//  Copyright © 2016 McDonald's Computing INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLViewController.h"

@interface URLViewController ()<UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end

@implementation URLViewController


-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverPresentationController.delegate = self;
    
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self updateUI];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI
{
    self.urlTextView.text = [self.url absoluteString];
}

-(CGSize)preferredContentSize {
    if (self.urlTextView != nil && self.presentingViewController != nil ) {
        return [self.urlTextView
                sizeThatFits:self.presentingViewController.view.bounds.size];
    }
    else {
        return super.preferredContentSize;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
                                                               traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}


@end
