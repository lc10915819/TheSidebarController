// TheSidebarController.m
// TheSidebarController
//
// Copyright (c) 2013 Jon Danao (danao.org | jondanao)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "TheSidebarController.h"


static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kVisibleWidth = 260.0f;


@interface TheSidebarController()

@property (assign, nonatomic) SidebarTransitionStyle selectedTransitionStyle;
@property (assign, nonatomic) Side selectedSide;
@property (strong, nonatomic) UIView *selectedSidebarView;
@property (strong, nonatomic) NSArray *sidebarAnimations;
@property (strong, nonatomic) UIViewController *contentContainerViewController;
@property (strong, nonatomic) UIViewController *leftSidebarContainerViewController;
@property (strong, nonatomic) UIViewController *rightSidebarContainerViewController;
@property (assign, nonatomic) CATransform3D contentTransform;

- (void)showSidebarViewControllerFromSide:(Side)side withTransitionStyle:(SidebarTransitionStyle)transitionStyle;
- (void)hideSidebarViewController;
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

@end


@implementation TheSidebarController

#pragma mark - Designated Initializer
- (id)init
{
    return [self initWithContentViewController:nil leftSidebarViewController:nil rightSidebarViewController:nil];
}

- (id)initWithContentViewController:(UIViewController *)contentViewController leftSidebarViewController:(UIViewController *)leftSidebarViewController
{
    return [self initWithContentViewController:contentViewController leftSidebarViewController:leftSidebarViewController rightSidebarViewController:nil];
}

- (id)initWithContentViewController:(UIViewController *)contentViewController rightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    return [self initWithContentViewController:contentViewController leftSidebarViewController:nil rightSidebarViewController:rightSidebarViewController];
}

- (id)initWithContentViewController:(UIViewController *)contentViewController leftSidebarViewController:(UIViewController *)leftSidebarViewController rightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    self = [super init];
    
    if(self)
    {
        _contentContainerViewController = [[UIViewController alloc] init];
        _leftSidebarContainerViewController = [[UIViewController alloc] init];
        _rightSidebarContainerViewController = [[UIViewController alloc] init];
        
        _contentViewController = contentViewController;
        _leftSidebarViewController = leftSidebarViewController;
        _rightSidebarViewController = rightSidebarViewController;
        
        _animationDuration = kAnimationDuration;
        _visibleWidth = kVisibleWidth;
        _sidebarAnimations = @[SIDEBAR_ANIMATIONS];
        _sidebarIsPresenting = NO;
    }
    
    return self;
}


#pragma mark - UIViewController Lifecycle
- (void)viewDidLoad
{
    NSAssert(self.contentViewController != nil, @"contentViewController was not set");
    
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if(self.leftSidebarViewController)
    {
        // Parent View Controller
        [self addChildViewController:self.leftSidebarContainerViewController];
        [self.view addSubview:self.leftSidebarContainerViewController.view];
        [self.leftSidebarContainerViewController didMoveToParentViewController:self];
        self.leftSidebarContainerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftSidebarContainerViewController.view.hidden = YES;
        
        // Child View Controller
        [self.leftSidebarContainerViewController addChildViewController:self.leftSidebarViewController];
        [self.leftSidebarContainerViewController.view addSubview:self.leftSidebarViewController.view];
        [self.leftSidebarViewController didMoveToParentViewController:self.leftSidebarContainerViewController];
    }
    
    if(self.rightSidebarViewController)
    {
        // Parent View Controller
        [self addChildViewController:self.rightSidebarContainerViewController];
        [self.view addSubview:self.rightSidebarContainerViewController.view];
        [self.rightSidebarContainerViewController didMoveToParentViewController:self];
        self.rightSidebarContainerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightSidebarContainerViewController.view.hidden = YES;
        
        // Child View Controller
        [self.rightSidebarContainerViewController addChildViewController:self.rightSidebarViewController];
        [self.rightSidebarContainerViewController.view addSubview:self.rightSidebarViewController.view];
        [self.rightSidebarViewController didMoveToParentViewController:self.rightSidebarContainerViewController];
    }
    
    
    // Parent View Controller
    [self addChildViewController:self.contentContainerViewController];
    [self.view addSubview:self.contentContainerViewController.view];
    [self.contentContainerViewController didMoveToParentViewController:self];
    
    // Child View Controller
    [self.contentContainerViewController addChildViewController:self.contentViewController];
    [self.contentContainerViewController.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self.contentContainerViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - TheSidebarController Presentation Methods
- (void)dismissSidebarViewController
{
    [self hideSidebarViewController];
}

- (void)presentLeftSidebarViewController
{
    [self presentLeftSidebarViewControllerWithStyle:SidebarTransitionStyleFacebook];
}

- (void)presentLeftSidebarViewControllerWithStyle:(SidebarTransitionStyle)transitionStyle
{
    NSAssert(self.leftSidebarViewController != nil, @"leftSidebarViewController was not set");
    [self showSidebarViewControllerFromSide:LeftSide withTransitionStyle:transitionStyle];
}

- (void)presentRightSidebarViewController
{
    [self presentRightSidebarViewControllerWithStyle:SidebarTransitionStyleFacebook];
}

- (void)presentRightSidebarViewControllerWithStyle:(SidebarTransitionStyle)transitionStyle
{
    NSAssert(self.rightSidebarViewController != nil, @"rightSidebarViewController was not set");
    [self showSidebarViewControllerFromSide:RightSide withTransitionStyle:transitionStyle];
}


#pragma mark - TheSidebarController Private Methods
- (void)showSidebarViewControllerFromSide:(Side)side withTransitionStyle:(SidebarTransitionStyle)transitionStyle
{    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    if(side == LeftSide)
    {
        self.leftSidebarContainerViewController.view.hidden = NO;
        self.rightSidebarContainerViewController.view.hidden = YES;
        self.selectedSidebarView = self.leftSidebarContainerViewController.view;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    }
    else if(side == RightSide)
    {
        self.rightSidebarContainerViewController.view.hidden = NO;
        self.leftSidebarContainerViewController.view.hidden = YES;
        self.selectedSidebarView = self.rightSidebarContainerViewController.view;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    }
    
    self.selectedSide = side;
    self.selectedTransitionStyle = transitionStyle;
    
    NSString *animationClassName = self.sidebarAnimations[transitionStyle];
    Class animationClass = NSClassFromString(animationClassName);
    [animationClass animateContentView:self.contentContainerViewController.view
                           sidebarView:self.selectedSidebarView
                              fromSide:self.selectedSide
                          visibleWidth:self.visibleWidth
                              duration:self.animationDuration
                            completion:^(BOOL finished) {
                                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                self.sidebarIsPresenting = YES;
                            }
     ];
}

- (void)hideSidebarViewController
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSString *animationClassName = self.sidebarAnimations[self.selectedTransitionStyle];
    Class animationClass = NSClassFromString(animationClassName);
    [animationClass reverseAnimateContentView:self.contentContainerViewController.view
                                  sidebarView:self.selectedSidebarView
                                     fromSide:self.selectedSide
                                 visibleWidth:self.visibleWidth
                                     duration:self.animationDuration
                                   completion:^(BOOL finished) {
                                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                       self.sidebarIsPresenting = NO;
                                   }
     ];
}


#pragma mark - UIViewController Setters
- (void)setContentViewController:(UIViewController *)contentViewController
{
    // Old View Controller
    UIViewController *oldViewController = self.contentViewController;
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    // New View Controller
    UIViewController *newViewController = contentViewController;
    [self.contentContainerViewController addChildViewController:newViewController];
    [self.contentContainerViewController.view addSubview:contentViewController.view];
    [contentViewController didMoveToParentViewController:self.contentContainerViewController];
    
    _contentViewController = contentViewController;
}

- (void)setLeftSidebarViewController:(UIViewController *)leftSidebarViewController
{
    NSLog(@"leftSidebarContentViewController");
}

- (void)setRightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    NSLog(@"rightSidebarContentViewController");
}


#pragma mark - Autorotation Delegates
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
       (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        NSLog(@"Portrait");
    }
    else if((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
    }
    
    
}


#pragma mark - Helpers
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

@end


#pragma mark - TheSidebarController Category
@implementation UIViewController(TheSidebarController)

- (TheSidebarController *)sidebarController
{
    if([self.parentViewController.parentViewController isKindOfClass:[TheSidebarController class]])
    {
        return (TheSidebarController *)self.parentViewController.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController.parentViewController isKindOfClass:[TheSidebarController class]])
    {
        return (TheSidebarController *)self.parentViewController.parentViewController.parentViewController;
    }
    
    return nil;
}

@end
