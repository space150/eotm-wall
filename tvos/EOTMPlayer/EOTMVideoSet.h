//
//  EOTMConfiguration.h
//  EOTMPlayer
//
//  Created by Shawn Roske on 10/10/16.
//  Copyright © 2016 space150. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EOTMVideoSetDelegate

- (void)videoSetLoaded:(NSURL *)videoURL;
- (void)errorLoadingVideoSet:(NSError *)error;

@end

@interface EOTMVideoSet : NSObject

@property (nonatomic, strong) NSString *currentDateString;
@property (nonatomic, strong) NSString *currentEmployeeName;
@property (nonatomic, strong) NSString *currentPortraitFilename;
@property (nonatomic, strong) NSString *currentLandscapeFilename;

@property (nonatomic, assign) id<EOTMVideoSetDelegate> delegate;

- (void)load;

@end
