//
// Utils.h
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SideMenuView;

@interface Utils : NSObject

+ (NSString *) getFilePathForFileName: (NSString *) fileName;

+ (id) unarchiveFile: (NSString *) path;

+ (BOOL) archiveFile: (id) objectToArchive toFile: (NSString *) path;

+ (NSString *) getImageStorageFolderPathForUser: (NSString *) userKey;

+ (NSString *) saveImage: (UIImage *) image withFilename: (NSString *) filename forUser: (NSString *) userKey;

+ (UIImage *) readImageWithFileName: (NSString *) filename forUser: (NSString *) userKey;

+ (BOOL) deleteAllPhotosforUser: (NSString *) userKey;

+ (BOOL) imageWithFileNameExist: (NSString *) filename forUser: (NSString *) userKey;

+ (BOOL) deleteImageWithFileName: (NSString *) filename forUser: (NSString *) userKey;

+ (UIImage *) getCroppedImageUsingRect: (CGRect) cropRect forImage: (UIImage *) originalImage;

+ (SideMenuView *) getLeftSideViewUsing: (UIImage *) profileImage andUsername: (NSString *) userName andMenuSelections: (NSArray *) menuSelections;

+ (NSString *) generateUniqueID;

+ (int) randomNumberBetween: (int) min maxNumber: (int) max;

+ (NSInteger) currentYear;

+ (NSDate *) dateForMondayOfThisWeek;

+ (NSDate *) dateForMondayOfPreviousWeek;

+ (NSDate *) dateForFirstDayOfThisMonth;

+ (NSDate *) dateForFirstDayOfPreviousMonth;

@end