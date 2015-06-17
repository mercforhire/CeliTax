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
#import "LLSimpleCamera.h"
#import "UIImage+ResizeMagick.h"

@interface CameraViewController ()

@property NSString *receiptFilenameID;

@property (strong, nonatomic) LLSimpleCamera *camera;
@property (weak, nonatomic) IBOutlet UIImageView *previousImageView;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topRightCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomRightCornerView;
@property (weak, nonatomic) IBOutlet UIView *maskViewUnderButtonCornerViews;
@property (weak, nonatomic) IBOutlet UIView *maskViewAboveTopCornerViews;

// these ratios means (coordinate value) / (total available length)
@property float topCropEdgeRatio;
@property float bottomCropEdgeRatio;
@property float leftCropEdgeRatio;
@property float rightCropEdgeRatio;

@property float buttomCornersOriginalYCoordinate;

@property (nonatomic) BOOL weAreNotDoneYet; // user not done capturing the whole receipt yet

@property NSMutableArray *takenImageFilenames;
@property NSMutableArray *takenImages;

@end

@implementation CameraViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationBarTitleImageContainer setHidden:YES];

    // Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];

    [self.navigationController.navigationBar setHidden: YES];
    self.navigationItem.hidesBackButton = YES;

    self.receiptFilenameID = [Utils generateUniqueID];

    // Do any additional setup after loading the view from its nib.
    self.takenImageFilenames = [NSMutableArray new];
    self.takenImages = [NSMutableArray new];

    [self.previousImageView setHidden: YES];
    [self.previousImageView setAlpha: 0.8f];

    [self.topLeftCornerView setRightBorder: NO];
    [self.topLeftCornerView setBottomBorder: NO];
    [self.topLeftCornerView setBorderThickness: 2];
    [self.topLeftCornerView setBackgroundColor: [UIColor clearColor]];

    [self.topRightCornerView setLeftBorder: NO];
    [self.topRightCornerView setBottomBorder: NO];
    [self.topRightCornerView setBorderThickness: 2];
    [self.topRightCornerView setBackgroundColor: [UIColor clearColor]];

    [self.bottomLeftCornerView setTopBorder: NO];
    [self.bottomLeftCornerView setRightBorder: NO];
    [self.bottomLeftCornerView setBorderThickness: 2];
    [self.bottomLeftCornerView setBackgroundColor: [UIColor clearColor]];
    self.buttomCornersOriginalYCoordinate = self.bottomLeftCornerView.frame.origin.y;

    [self.bottomRightCornerView setTopBorder: NO];
    [self.bottomRightCornerView setLeftBorder: NO];
    [self.bottomRightCornerView setBorderThickness: 2];
    [self.bottomRightCornerView setBackgroundColor: [UIColor clearColor]];

    self.topCropEdgeRatio = self.topLeftCornerView.frame.origin.y / self.view.frame.size.height;
    self.leftCropEdgeRatio = self.topLeftCornerView.frame.origin.x / self.view.frame.size.width;
    self.rightCropEdgeRatio = (self.topRightCornerView.frame.origin.x + self.topRightCornerView.frame.size.width) / self.view.frame.size.width;
    [self refreshBottomCropEdgeRatio];

    // Instantiate the camera view & assign its frame
    self.camera = [[LLSimpleCamera alloc] initWithQuality: AVCaptureSessionPresetHigh
                                                 position: CameraPositionBack
                                             videoEnabled: NO];
    // attach to the view
    [self.camera attachToViewController: self withFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;

    [self.camera setOnDeviceChange: ^(LLSimpleCamera *camera, AVCaptureDevice *device) {
        // device changed, check if flash is available
        if ([camera isFlashAvailable])
        {
            weakSelf.flashButton.hidden = NO;

            if (camera.flash == CameraFlashOff)
            {
                weakSelf.flashButton.selected = NO;
            }
            else
            {
                weakSelf.flashButton.selected = YES;
            }
        }
        else
        {
            weakSelf.flashButton.hidden = YES;
        }
    }];

    [self.camera setOnError: ^(LLSimpleCamera *camera, NSError *error) {
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
    [self.flashButton setBackgroundColor: [UIColor clearColor]];
    [self.flashButton setImage: [UIImage imageNamed: @"camera-flash-off.png"] forState: UIControlStateNormal];
    [self.flashButton setImage: [UIImage imageNamed: @"camera-flash-on.png"] forState: UIControlStateSelected];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget: self action: @selector(flashButtonPressed:) forControlEvents: UIControlEventTouchUpInside];

    [self.camera updateFlashMode: CameraFlashOff];

    self.flashButton.selected = NO;
    self.flashButton.tintColor = [UIColor whiteColor];

    [self.view sendSubviewToBack: self.camera.view];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    // start the camera
    [self.camera start];
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
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else
    {
        BOOL done = [self.camera updateFlashMode: CameraFlashOff];

        if (done)
        {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
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

            NSString *fileName = [NSString stringWithFormat: @"Receipt-%@-%ld", self.receiptFilenameID, (long)self.takenImages.count];

            NSString *savedFilePath = [Utils saveImage: resizedImage withFilename: fileName forUser: self.userManager.user.userKey];

            DLog(@"Image saved to %@", savedFilePath);

            [self.takenImageFilenames addObject: fileName];
            [self.takenImages addObject: resizedImage];

            if (self.weAreNotDoneYet)
            {
                [self.previousImageView setImage: resizedImage];
                [self.previousImageView setHidden: NO];
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
                self.weAreNotDoneYet = NO;

                [self.camera start];
            }
            else
            {
                // we are done with camera

                if (self.takenImages.count)
                {
                    [self saveNewReceipt];
                }

                [self exitCamera];
            }
        }
        else
        {
            DLog(@"An error has occured: %@", error);
        }
    } exactSeenImage: YES];
}

- (void) refreshBottomCropEdgeRatio
{
    self.bottomCropEdgeRatio = (self.bottomLeftCornerView.frame.origin.y + self.bottomLeftCornerView.frame.size.height) / self.view.frame.size.height;

    // DLog(@"Bottom Y coordinate: %f", self.bottomRightCornerPoint.y);
}

- (void) saveNewReceipt
{
    [self.manipulationService addReceiptForFilenames: self.takenImageFilenames success: ^{
        DLog(@"addReceiptForUserKey success");
    } failure: ^(NSString *reason) {
        // should not happen
        DLog(@"saveNewReceipt ERROR");
    }];
}

- (void) exitCamera
{
    [self.camera stop];

    if (self.takenImages.count)
    {
        NSAssert(self.delegate, @"self.delegate must not be unset");
        [self.delegate hasJustCreatedNewReceipt];
    }
    
    [self.navigationController.navigationBar setHidden: NO];
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) cancelPressed: (UIButton *) sender
{
    if (self.takenImages.count)
    {
        [self saveNewReceipt];
    }

    [self exitCamera];
}

- (IBAction) handlePan: (UIPanGestureRecognizer *) recognizer
{
    CGPoint translation = [recognizer translationInView: self.view];

    if (recognizer.view.frame.origin.y + translation.y >= self.topLeftCornerView.frame.origin.y + self.topLeftCornerView.frame.size.height - 20
        &&
        recognizer.view.frame.origin.y + translation.y <= self.view.frame.size.height - recognizer.view.frame.size.height)
    {
        self.bottomLeftCornerView.center = CGPointMake(self.bottomLeftCornerView.center.x,
                                                       self.bottomLeftCornerView.center.y + translation.y);
        self.bottomRightCornerView.center = CGPointMake(self.bottomRightCornerView.center.x,
                                                        self.bottomRightCornerView.center.y + translation.y);
        [self.maskViewUnderButtonCornerViews
         setFrame: CGRectMake(self.bottomLeftCornerView.frame.origin.x,
                              self.bottomLeftCornerView.frame.origin.y + self.bottomLeftCornerView.frame.size.height,
                              self.bottomRightCornerView.frame.origin.x + self.bottomRightCornerView.frame.size.width - self.bottomLeftCornerView.frame.origin.x,
                              self.view.frame.size.height - (self.bottomLeftCornerView.frame.origin.y + self.bottomLeftCornerView.frame.size.height))];

        [recognizer setTranslation: CGPointMake(0, 0) inView: self.view];
    }

    // when touch is finished
    if (UIGestureRecognizerStateEnded == [recognizer state])
    {
        // if buttomReceiptView is dragged near the button, change remove its bottom border
        if (recognizer.view.frame.origin.y >= self.view.frame.size.height - recognizer.view.frame.size.height - 20)
        {
            [self.bottomLeftCornerView setBottomBorder: NO];
            [self.bottomRightCornerView setBottomBorder: NO];

            if (!self.weAreNotDoneYet)
            {
                self.weAreNotDoneYet = YES;
            }
        }
        else
        {
            [self.bottomLeftCornerView setBottomBorder: YES];
            [self.bottomRightCornerView setBottomBorder: YES];

            if (self.weAreNotDoneYet)
            {
                self.weAreNotDoneYet = NO;
            }
        }
    }

    [self refreshBottomCropEdgeRatio];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end