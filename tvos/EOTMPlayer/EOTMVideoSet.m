//
//  EOTMConfiguration.m
//  EOTMPlayer
//
//  Created by Shawn Roske on 10/10/16.
//  Copyright © 2016 space150. All rights reserved.
//

#import "EOTMVideoSet.h"
#import <AFNetworking/AFNetworking.h>

#define SITE_BASE_URL       @"https://s3.amazonaws.com/s150-eotm/"
#define MANIFEST_FILE_NAME  @"manifest.json"

#define EOTMErrorDomain     @"com.s150.EOTMPlayer.error"

#define CACHE_DIRECTORY     NSCachesDirectory

@interface EOTMVideoSet ()

@property (nonatomic, strong) NSURL *manifestFileURL;
@property (nonatomic, assign) NSInteger manifestVersion;
@property (nonatomic, strong) NSURL *manifestBaseURL;

@end

@implementation EOTMVideoSet

- (NSString *)currentFilename
{
    // depending on settings, portrait or landscape? for now just landscape!
    return self.currentLandscapeFilename;
}

- (void)load
{
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:CACHE_DIRECTORY inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    self.manifestFileURL = [documentsDirectoryURL URLByAppendingPathComponent:MANIFEST_FILE_NAME];
    
    // do we have a locally stored json file?
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( [fileManager fileExistsAtPath:self.manifestFileURL.path] )
    {
        // if so, load it
        [self parseManifestFile];
    }
    else
    {
        // if not, or if we haven't check it in some time, download it
        [self downloadManifestFile];
    }
}

- (void)downloadManifestFile
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [[NSURL URLWithString:SITE_BASE_URL] URLByAppendingPathComponent:MANIFEST_FILE_NAME];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return self.manifestFileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if ( error ) {
            if ( self.delegate != nil )
                [self.delegate errorLoadingVideoSet:error];
        } else {
            NSLog(@"manifest file downloaded to: %@", filePath);
            [self parseManifestFile];
        }
    }];
    [downloadTask resume];
}

- (void)parseManifestFile
{
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:self.manifestFileURL.path];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    NSLog(@"jsonObject: %@", jsonObject);
    if ( error ) {
        if ( self.delegate != nil )
            [self.delegate errorLoadingVideoSet:error];
    } else {
        NSDictionary *config = (NSDictionary *)jsonObject;
        NSLog(@"config: %@", config);
        
        // if we have a version and we have a current entry, we are probably OK?
        if ( [config objectForKey:@"version"] && [config objectForKey:@"current"] ) {
            
            self.manifestVersion = [[config objectForKey:@"version"] integerValue];
            self.manifestBaseURL = [NSURL URLWithString:[config objectForKey:@"base-url"]];
            
            NSDictionary *currentEntry = (NSDictionary *)[config objectForKey:@"current"];
            self.currentDateString = [self dateStringToFormattedDate:[currentEntry objectForKey:@"date"]];
            self.currentEmployeeName = [currentEntry objectForKey:@"employee-name"];
            self.currentPortraitFilename = [currentEntry objectForKey:@"portrait-filename"];
            self.currentLandscapeFilename = [currentEntry objectForKey:@"landscape-filename"];
            
            NSLog(@"self.currentDateString: %@", self.currentDateString);
            
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:CACHE_DIRECTORY inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
            NSURL *localVideoURL = [documentsDirectoryURL URLByAppendingPathComponent:[self currentFilename]];
            NSURL *remoteVideoURL = [self.manifestBaseURL URLByAppendingPathComponent:[self currentFilename]];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger lastDownloadedVersion = [defaults integerForKey:@"lastDownloadedManifestVersion"];
            
            // check the version, if it is different than what we loaded, download the new video!
            if ( lastDownloadedVersion != self.manifestVersion ) {
                [self downloadRemoteVideoAtURL:remoteVideoURL];
            } else {
                // otherwise see if we have it stored locally
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ( [fileManager fileExistsAtPath:localVideoURL.path] )
                {
                    // we have it, so load it up!
                    if ( self.delegate != nil )
                        [self.delegate videoSetLoaded:localVideoURL];
                }
                else
                {
                    // if we don't have one, download the video!
                    [self downloadRemoteVideoAtURL:remoteVideoURL];
                }
            }
        } else {
            if ( self.delegate != nil ) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Manifest was invalid.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Manifest was invalid.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please check the manifest format for errors!", nil)
                                           };
                NSError *err = [NSError errorWithDomain:EOTMErrorDomain
                                                     code:-42
                                                 userInfo:userInfo];
                [self.delegate errorLoadingVideoSet:err];
            }
            
        }
    }
}

- (void)downloadRemoteVideoAtURL:(NSURL *)remoteVideoURL
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteVideoURL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:CACHE_DIRECTORY inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[self currentFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if ( error ) {
            if ( self.delegate != nil )
                [self.delegate errorLoadingVideoSet:error];
        } else {
            NSLog(@"video file downloaded to: %@", filePath);
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:self.manifestVersion forKey:@"lastDownloadedManifestVersion"];
            [defaults synchronize];
            
            if ( self.delegate != nil )
                [self.delegate videoSetLoaded:filePath];
        }
    }];
    [downloadTask resume];
}

-(NSString *)dateStringToFormattedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMyyyy"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:@"MMM YYYY"];
    return [dateFormatter stringFromDate:date];
}

@end
