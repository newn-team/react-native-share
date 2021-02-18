//
//  InstagramStoriesSfm.m
//  RNShare
//
//  Created by Shota Saito on 2021/02/12.
//  Copyright © 2021 Facebook. All rights reserved.
//

// import RCTLog
#if __has_include(<React/RCTLog.h>)
#import <React/RCTLog.h>
#elif __has_include("RCTLog.h")
#import "RCTLog.h"
#else
#import "React/RCTLog.h"   // Required when used as a Pod in a Swift project
#endif

#import "InstagramStoriesSfm.h"

@implementation InstagramStoriesSfm
RCT_EXPORT_MODULE();

- (void)backgroundVideo:(NSData *)backgroundVideo stickerImage:(NSData *)stickerImage attributionURL:(NSString *)attributionURL
{
    // Verify app can open custom URL scheme. If able,
    // assign assets to pasteboard, open scheme.
    NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
        // Assign background video and sticker image and
        // attribution link URL to pasteboard
        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundVideo" : backgroundVideo, @"com.instagram.sharedSticker.stickerImage" : stickerImage, @"com.instagram.sharedSticker.contentURL" : attributionURL}];
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        // This call is iOS 10+, can use 'setItems' depending on what versions you support
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else { // Handle older app versions or app not installed case
        [self fallbackInstagram];
    }
}

- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback {
    
    NSString *attrURL = [RCTConvert NSString:options[@"attributionURL"]];
    if (attrURL == nil) {
        attrURL = @"";
    }
    
    NSString *method = [RCTConvert NSString:options[@"method"]];
    if (method) {
        if([method isEqualToString:@"shareBackgroundVideoAndStickerImage"]) {
            RCTLog(@"method shareBackgroundVideoAndStickerImage");
            
            NSURL *backgroundVideoURL = [RCTConvert NSURL:options[@"backgroundVideo"]];
            NSURL *stickerURL = [RCTConvert NSURL:options[@"stickerImage"]];

            if (backgroundVideoURL == nil || stickerURL == nil) {
                RCTLogError(@"key 'backgroundVideo' or 'stickerImage' missing in options");
            } else {
                NSData *backgroundVideo = [NSData dataWithContentsOfURL:backgroundVideoURL];
                NSData *stickerImage = [NSData dataWithContentsOfURL:stickerURL];

                [self backgroundVideo:backgroundVideo stickerImage:stickerImage attributionURL:attrURL];
            }
        }
    } else {
        RCTLogError(@"key 'method' missing in options");
    }
}

- (void)fallbackInstagram {
    // Cannot open instagram
    NSString *stringURL = @"http://itunes.apple.com/app/instagram/id389801252";
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
    
    NSString *errorMessage = @"Not installed";
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
    NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
    
    NSLog(errorMessage);
}
// https://instagram.fhrk1-1.fna.fbcdn.net/vp/80c479ffc246a9320e614fa4def6a3dc/5C667D3F/t51.12442-15/e35/50679864_1663709050595244_6964601913751831460_n.jpg?_nc_ht=instagram.fhrk1-1.fna.fbcdn.net
@end


