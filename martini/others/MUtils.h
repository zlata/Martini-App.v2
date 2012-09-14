//
//  Settings.h
//  Kinopoisk
//
//  Created by zlata samarskaya on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSettings : NSObject

+ (NSString*)pushToken;
+ (void)setPushTocken:(NSString*)token;

@end


@interface MUtils : NSObject

+(NSString*)dateString:(NSDate*)date format:(NSString*)format;
+(NSString*)saveLocalImage:(UIImage*)image filename:(NSString*)filename;
+(NSDate*)stringToDate:(NSString*)dateString format:(NSString*)format;
+(NSString*)saveImageFromPath:(NSString*)remotePath name:(NSString*)imageName;
//+(NSString*)saveImageFromPath:(NSString*)remotePath;
+(NSString*)saveImageFromPath:(NSString*)remotePath folder:(NSString*)folder;
+ (BOOL)date:(NSDate*)first equal:(NSDate*)second;
+ (NSDate*)yesterday;
+(int)dateOffset:(NSDate*)date;
+(int)timeOffset:(NSString*)timeStr;
+ (BOOL)emailValid:(NSString*)email;
+ (BOOL)numericValid:(NSString*)text minLength:(int)min maxLength:(int)max;
+ (BOOL)alphaNumericValid:(NSString*)text minLength:(int)min maxLength:(int)max;
+ (CGSize)sizeForLabel:(UILabel*)label text:(NSString*)text;
+ (NSMutableDictionary *)dictionaryFromQueryComponents:(NSURL*)url;
+ (UIImage*)resizeImage:(UIImage*)image maxSide:(int)side;
+ (void)clearCache:(NSString*)folderName;
+ (NSString*)friendsStringForValue:(int)val;
+ (void)clearImage:(NSString*)imagePath;
+ (NSString*)mapUrl:(CLLocationCoordinate2D)coordinate;
@end

@interface NSString (md5)

- (NSString *) MD5;

@end