//
// CameraOverlayViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-18.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CameraViewController.h"
#import "WhiteBorderView.h"
#import "Utils.h"
#import "User.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "ConfigurationManager.h"
#import "LLSimpleCamera.h"
#import "UIImage+ResizeMagick.h"
#import "ViewControllerFactory.h"
#import "ReceiptCheckingViewController.h"
#import "FlashButtonView.h"
#import "Receipt.h"
#import "SolidGreenButton.h"

@interface CameraViewController ()
{
    NSString *newlyAddedReceiptID;
}

@property (strong, nonatomic) LLSimpleCamera *camera;
@property (weak, nonatomic) IBOutlet UIImageView *previousImageView;
@property (weak, nonatomic) IBOutlet UIView *greenBar;

@property (weak, nonatomic) IBOutlet SolidGreenButton *cancelButton;
@property (weak, nonatomic) IBOutlet SolidGreenButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet FlashButtonView *flashButtonView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topRightCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomRightCornerView;
@property (weak, nonatomic) IBOutlet UIView *maskViewUnderButtonCornerViews;
@property (weak, nonatomic) IBOutlet UIView *maskViewAboveTopCornerViews;
@property (weak, nonatomic) IBOutlet UIView *dragBarContainer;
@property (weak, nonatomic) IBOutlet UIView *dragBarView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTopToGreenBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMaskHeight;
@property (nonatomic) float distanceFromTopToGreenBarDefaultConstant;
@property (nonatomic) float bottomMaskHeightDefaultConstant;

@property (nonatomic) float distanceFromTopToGreenBarStartingConstant;
@property (nonatomic) float bottomMaskHeightStartingConstant;

// these ratios means (coordinate value) / (total available length)
@property float topCropEdgeRatio;
@property float bottomCropEdgeRatio;
@property float leftCropEdgeRatio;
@property float rightCropEdgeRatio;

@property float buttomCornersOriginalYCoordinate;

@property NSMutableArray *takenImageFilenames;
@property NSMutableArray *takenImages;

@end

@implementation CameraViewController

- (void) refreshCropEdgeRatio
{
    self.topCropEdgeRatio = self.topLeftCornerView.frame.origin.y / self.view.frame.size.height;
    self.leftCropEdgeRatio = self.topLeftCornerView.frame.origin.x / self.view.frame.size.width;
    self.rightCropEdgeRatio = (self.topRightCornerView.frame.origin.x + self.topRightCornerView.frame.size.width) / self.view.frame.size.width;
    self.bottomCropEdgeRatio = (self.bottomLeftCornerView.frame.origin.y + self.bottomLeftCornerView.frame.size.height) / self.view.frame.size.height;
}

-(void)setupUI
{
    [self.navigationBarTitleImageContainer setHidden:YES];
    
    // Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setHidden: YES];
    self.navigationItem.hidesBackButton = YES;
    
    [self.previousImageView setHidden: YES];
    
    [self.dragBarContainer setBackgroundColor:[UIColor clearColor]];
    
    [self.topLeftCornerView setRightBorder: NO];
    [self.topLeftCornerView setBottomBorder: NO];
    [self.topLeftCornerView setBorderThickness: 2];
    [self.topLeftCornerView setMargin:7.5f];
    [self.topLeftCornerView setBackgroundColor: [UIColor clearColor]];
    
    [self.topRightCornerView setLeftBorder: NO];
    [self.topRightCornerView setBottomBorder: NO];
    [self.topRightCornerView setBorderThickness: 2];
    [self.topRightCornerView setMargin:7.5f];
    [self.topRightCornerView setBackgroundColor: [UIColor clearColor]];
    
    [self.bottomLeftCornerView setTopBorder: NO];
    [self.bottomLeftCornerView setRightBorder: NO];
    [self.bottomLeftCornerView setBorderThickness: 2];
    [self.bottomLeftCornerView setMargin:7.5f];
    [self.bottomLeftCornerView setBackgroundColor: [UIColor clearColor]];
    self.buttomCornersOriginalYCoordinate = self.bottomLeftCornerView.frame.origin.y;
    
    [self.bottomRightCornerView setTopBorder: NO];
    [self.bottomRightCornerView setLeftBorder: NO];
    [self.bottomRightCornerView setBorderThickness: 2];
    [self.bottomRightCornerView setMargin:7.5f];
    [self.bottomRightCornerView setBackgroundColor: [UIColor clearColor]];
    
    self.dragBarView.layer.cornerRadius = 4.0f;

    [self refreshCropEdgeRatio];
    
    [self.cancelButton setLookAndFeel:self.lookAndFeel];
    [self.continueButton setLookAndFeel:self.lookAndFeel];
    
    // snap button to capture image
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget: self action: @selector(snapButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    // button to toggle flash
    [self.flashButtonView.flashButton addTarget: self action: @selector(flashButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    // Instantiate the camera view & assign its frame
    self.camera = [[LLSimpleCamera alloc] initWithQuality: AVCaptureSessionPresetHigh
                                                 position: CameraPositionBack
                                             videoEnabled: NO];
    // attach to the view
    [self.camera attachToViewController: self withFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    
    [self.camera setOnDeviceChange: ^(LLSimpleCamera *camera, AVCaptureDevice *device)
    {
        // device changed, check if flash is available
        if ([camera isFlashAvailable])
        {
            weakSelf.flashButtonView.hidden = NO;
            
            if (camera.flash == CameraFlashOff)
            {
                weakSelf.flashButtonView.on = NO;
            }
            else
            {
                weakSelf.flashButtonView.on = YES;
            }
        }
        else
        {
            weakSelf.flashButtonView.hidden = YES;
        }
    }];
    
    [self.camera setOnError: ^(LLSimpleCamera *camera, NSError *error)
    {
        NSLog(@"Camera error: %@", error);
        
        if ([error.domain isEqualToString: LLSimpleCameraErrorDomain])
        {
            if (error.code == LLSimpleCameraErrorCodeCameraPermission ||
                error.code == LLSimpleCameraErrorCodeMicrophonePermission)
            {
                NSLog(@"We need permission for the camera.\nPlease go to your settings.");
            }
        }
    }];
}

-(void)initAndSetupCamera
{
    [self.view sendSubviewToBack: self.camera.view];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    [self initAndSetupCamera];
    
    self.takenImageFilenames = [NSMutableArray new];
    self.takenImages = [NSMutableArray new];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // start the camera
    [self.camera start];
    
    self.distanceFromTopToGreenBarDefaultConstant = self.distanceFromTopToGreenBar.constant;
    
    self.bottomMaskHeightDefaultConstant = self.bottomMaskHeight.constant;
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];

    // stop the camera
    [self.camera stop];
    
    [self.navigationBarTitleImageContainer setHidden:NO];
}

- (void) flashButtonPressed: (UIButton *) button
{
    if (self.camera.flash == CameraFlashOff)
    {
        BOOL done = [self.camera updateFlashMode: CameraFlashOn];

        if (done)
        {
            self.flashButtonView.on = YES;
        }
    }
    else
    {
        BOOL done = [self.camera updateFlashMode: CameraFlashOff];

        if (done)
        {
            self.flashButtonView.on = NO;
        }
    }
}

- (void) snapButtonPressed: (UIButton *) button
{
    // capture
    [self.camera capture: ^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if (!error)
        {
            // crop first
            CGRect cropRectangle = CGRectMake(image.size.width * self.leftCropEdgeRatio,
                                              image.size.height * self.topCropEdgeRatio,
                                              image.size.width * self.rightCropEdgeRatio - image.size.width * self.leftCropEdgeRatio,
                                              image.size.height * self.bottomCropEdgeRatio - image.size.height * self.topCropEdgeRatio);

            UIImage *croppedImage = [Utils getCroppedImageUsingRect: cropRectangle forImage: image];

            UIImage *resizedImage = [croppedImage resizedImageByMagick: @"400"];
            
            NSString *fileName = [NSString stringWithFormat: @"Receipt-%@-%ld", [Utils generateUniqueID], (long)self.takenImages.count];

            NSString *savedFilePath = [Utils saveImage: resizedImage withFilename: fileName forUser: self.userManager.user.userKey];

            DLog(@"Image saved to %@", savedFilePath);

            [self.takenImageFilenames addObject: fileName];
            [self.takenImages addObject: resizedImage];

            float ratio = resizedImage.size.height / resizedImage.size.width;
            
            self.imageViewHeight.constant = self.previousImageView.frame.size.width * ratio;
            
            //reset Constrains
            self.bottomMaskHeight.constant = self.bottomMaskHeightDefaultConstant;
            self.distanceFromTopToGreenBar.constant = self.distanceFromTopToGreenBarDefaultConstant;
            
            [self.previousImageView setImage: resizedImage];
            [self.previousImageView setHidden: NO];
            [self.greenBar setHidden: NO];
            [self.maskViewAboveTopCornerViews setHidden:YES];
            
            [self.bottomLeftCornerView setBottomBorder: YES];
            [self.bottomRightCornerView setBottomBorder: YES];
            
            [self.bottomLeftCornerView setFrame: CGRectMake(self.bottomLeftCornerView.frame.origin.x,
                                                            self.buttomCornersOriginalYCoordinate,
                                                            self.bottomLeftCornerView.frame.size.width,
                                                            self.bottomLeftCornerView.frame.size.height)];
            
            [self.bottomRightCornerView setFrame: CGRectMake(self.bottomRightCornerView.frame.origin.x,
                                                             self.buttomCornersOriginalYCoordinate,
                                                             self.bottomRightCornerView.frame.size.width,
                                                             self.bottomRightCornerView.frame.size.height)];
            
            [self.continueButton setEnabled:YES];
            
            [self.view setNeedsUpdateConstraints];
            
            [self.camera start];
        }
        else
        {
            DLog(@"An error has occured: %@", error);
        }
    } exactSeenImage: YES];
}

- (IBAction) cancelPressed: (UIButton *) sender
{
    [self.camera updateFlashMode: CameraFlashOff];
    
    [self.camera stop];
    
    for (NSString *filename in self.takenImageFilenames)
    {
        [Utils deleteImageWithFileName:filename forUser:self.userManager.user.userKey];
    }
    
    [self.navigationController.navigationBar setHidden: NO];
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)continuePressed:(UIButton *)sender
{
    [self.camera updateFlashMode: CameraFlashOff];
    
    [self.camera stop];
    
    [self.navigationController.navigationBar setHidden: NO];
    
    //saving a new receipt
    if (!self.existingReceiptID)
    {
        NSInteger taxYear = [self.configurationManager getCurrentTaxYear];
        
        NSString *newestReceiptID = [self.manipulationService addReceiptForFilenames: self.takenImageFilenames
                                                                          andTaxYear: taxYear
                                                                                save:YES];
        
        if (newestReceiptID)
        {
            DLog(@"addReceiptForUserKey success");
            newlyAddedReceiptID = newestReceiptID;
            
            ReceiptCheckingViewController *receiptCheckingViewController = [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID:newlyAddedReceiptID cameFromReceiptBreakDownViewController:NO];
            
            // push the new viewController
            [self.navigationController pushViewController: receiptCheckingViewController animated: YES];
            
            // remove self viewController
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
            
            [viewControllers removeObject: self];
            
            // Assign the updated stack with animation
            [self.navigationController setViewControllers: viewControllers animated: NO];
        }
    }
    
    //adding the photos taken to an existing receipt
    else
    {
        Receipt *receipt = [self.dataService fetchReceiptForReceiptID:self.existingReceiptID];
        
        [receipt.fileNames addObjectsFromArray:self.takenImageFilenames];
        
        [self.manipulationService modifyReceipt:receipt save:YES];
        
        [self.navigationController popViewControllerAnimated: YES];
    }
}


- (IBAction) dragBarPan: (UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView: self.view];

    switch ([recognizer state])
    {
        case UIGestureRecognizerStateBegan:
            DLog(@"Dragging started with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            self.bottomMaskHeightStartingConstant = self.bottomMaskHeight.constant;
            [self.dragBarView setBackgroundColor:self.lookAndFeel.appGreenColor];
            break;
            
        case UIGestureRecognizerStateChanged:
            DLog(@"Dragging with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            
            //don't let self.bottomMaskHeight.constant drop below self.bottomMaskHeightDefaultConstant
            //nor let it grow larger than (self.view.frame.size.height - self.distanceFromTopToGreenBar.constant -self.topLeftCornerView.frame.size.height - self.dragBarContainer.frame.size.height)
            if ( self.bottomMaskHeightDefaultConstant <= (self.bottomMaskHeightStartingConstant - translation.y) &&
                (self.bottomMaskHeightStartingConstant - translation.y) < (self.view.frame.size.height - self.distanceFromTopToGreenBar.constant - self.topLeftCornerView.frame.size.height - self.dragBarContainer.frame.size.height/2) )
            {
                self.bottomMaskHeight.constant = self.bottomMaskHeightStartingConstant - translation.y;
                [self.view setNeedsUpdateConstraints];
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            DLog(@"Dragging completed with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            [self refreshCropEdgeRatio];
            [self.dragBarView setBackgroundColor:[UIColor whiteColor]];
            break;
            
        default:
            break;
    }
}

- (IBAction)imageViewPan: (UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView: self.view];
    
    switch ([recognizer state])
    {
        case UIGestureRecognizerStateBegan:
            DLog(@"Dragging started with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            self.distanceFromTopToGreenBarStartingConstant = self.distanceFromTopToGreenBar.constant;
            break;
            
        case UIGestureRecognizerStateChanged:
            DLog(@"Dragging with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            
            if ( self.distanceFromTopToGreenBarDefaultConstant <= (self.distanceFromTopToGreenBarStartingConstant + translation.y) &&
                (self.distanceFromTopToGreenBarStartingConstant + translation.y) < (self.view.frame.size.height - self.bottomMaskHeight.constant - self.distanceFromTopToGreenBarDefaultConstant) &&
                (self.distanceFromTopToGreenBarStartingConstant + translation.y) < (self.imageViewHeight.constant - self.distanceFromTopToGreenBarDefaultConstant) )
            {
                self.distanceFromTopToGreenBar.constant = self.distanceFromTopToGreenBarStartingConstant + translation.y;
                [self.view setNeedsUpdateConstraints];
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            DLog(@"Dragging completed with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            [self refreshCropEdgeRatio];
            break;
            
        default:
            break;
    }
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end