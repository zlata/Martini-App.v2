//
//  Settings.m
//  Kinopoisk
//
//  Created by zlata samarskaya on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MUtils.h"

@implementation MSettings

+ (NSString*)pushToken {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings valueForKey:@"pushToken"];        
}

+ (void)setPushTocken:(NSString*)token {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setValue:token forKey:@"pushToken"];    
}
@end

@implementation MUtils

+(NSString*)dateString:(NSDate*)date format:(NSString*)format {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"] autorelease]];
	[dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];

}

+(NSDate*)stringToDate:(NSString*)dateString format:(NSString*)format {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"] autorelease]];
	[dateFormatter setDateFormat:format];
    
    return [dateFormatter dateFromString:dateString];
    
}

+ (NSString*)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString*)documentsFilePath:(NSString*)folder name:(NSString*)fileName {
	NSString *folderPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:folder];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
	return [folderPath stringByAppendingPathComponent:fileName];
}

+ (NSString*)documentsFilePath:(NSString*)urlString folder:(NSString*)folder prefix:(NSString*)prefix {
	NSString *fileName = [prefix stringByAppendingFormat:@"_%@", [urlString lastPathComponent]];
    return [self documentsFilePath:folder name:fileName];

}

+ (NSString*)documentsFilePath:(NSString*)urlString folder:(NSString*)folder {
	NSString *fileName = [urlString lastPathComponent];
    return [self documentsFilePath:folder name:fileName];
}

+ (NSString*)saveLocalImage:(UIImage*)image filename:(NSString*)filename {
	NSString *localPath = [self documentsFilePath:filename folder:@"temp"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return localPath;
    }
	NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];	
    
	if([data writeToFile:localPath atomically:YES]) {
        return localPath;
    }
    return nil;
}

+ (NSString*)saveImageFromPath:(NSString*)remotePath name:(NSString*)imageName {
	NSString *localPath = [self documentsFilePath:@"temp" name:imageName];
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return localPath;
    }
    NSString *urlString = [kServerUrl stringByAppendingString:remotePath];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
	
	if(image == nil) {
		NSLog(@"failed load image nil %@", remotePath);
		return nil;
	}
	NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];	
    
	if([data writeToFile:localPath atomically:YES]) {
        return localPath;
    }
    return nil;
}

+ (NSString*)saveImageFromPath:(NSString*)remotePath folder:(NSString*)folder {
//    NSString *path = [folder stringByAppendingFormat:@"_%@", remotePath];
  	NSString *localPath = [self documentsFilePath:remotePath folder:@"temp"];
    if (![folder isEqualToString:@"MUser"]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            return localPath;
        }
    }
    NSString *urlString = [kServerUrl stringByAppendingString:remotePath];
	
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];	
	if(data == nil) {
		NSLog(@"failed load image nil %@", urlString);
		return nil;
	}
    
	if([data writeToFile:localPath atomically:YES]) {
        return localPath;
    }
    return nil;  
}

+ (NSString*)saveImageFromPath:(NSString*)remotePath {
	NSString *localPath = [self documentsFilePath:remotePath folder:@"temp"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return localPath;
    }
    NSString *urlString = [kServerUrl stringByAppendingString:remotePath];
	
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];	
	if(data == nil) {
		NSLog(@"failed load image nil %@", urlString);
		return nil;
	}
    
	if([data writeToFile:localPath atomically:YES]) {
        return localPath;
    }
    return nil;
}

+ (BOOL)date:(NSDate*)first equal:(NSDate*)second {
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:first];
    NSDateComponents *otherDateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:second];
    
    BOOL equal = ([dateComponents year] == [otherDateComponents year]) && ([dateComponents month] == [otherDateComponents month]) && ([dateComponents day] == [otherDateComponents day]);
    return equal;
}

+ (NSDate*)yesterday {
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval:(-3600 * 12)];
    return yesterday;
}

+ (BOOL)tomorrow:(NSDate*)date {
    NSDate *today = [NSDate date];
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    NSDateComponents *otherDateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    
    BOOL equal = ([dateComponents year] == [otherDateComponents year]) && ([dateComponents month] == [otherDateComponents month]) && (([dateComponents day] + 1) == [otherDateComponents day]);
    return equal;    
}

+ (int)dateOffset:(NSDate*)date {
    NSDate *today = [NSDate date];
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    NSDateComponents *otherDateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    
    if (([dateComponents year] >= [otherDateComponents year]) && 
        ([dateComponents month] >= [otherDateComponents month]) &&
        ([dateComponents day] < [otherDateComponents day])) {
        return 1;
    }
    BOOL equal = ([dateComponents year] == [otherDateComponents year]) && ([dateComponents month] == [otherDateComponents month]) && ([dateComponents day] == [otherDateComponents day]);
    if (equal) {
        return 0;
    }
    return -1;
}

+ (int)timeOffset:(NSString*)timeStr {
    NSDate *today = [NSDate date];
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    NSString *dateStr = [NSString stringWithFormat:@"%02i.%02i.%i %@", [dateComponents day],
                         [dateComponents month], [dateComponents year], timeStr];
    NSDate *timeDate = [self stringToDate:dateStr format:@"dd.MM.yyyy HH:mm"];
    return [timeDate timeIntervalSinceNow];
}

+ (BOOL)emailValid:(NSString*)email {
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regExPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
	return [regExPredicate evaluateWithObject:[email lowercaseString]];
}

+ (BOOL)numericValid:(NSString*)text minLength:(int)min maxLength:(int)max {
	NSString *emailRegEx = [NSString stringWithFormat:@"[0-9]{%i,%i}", min, max];
    NSPredicate *regExPredicate =
	[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
	return [regExPredicate evaluateWithObject:text];
}

+ (BOOL)alphaNumericValid:(NSString*)text minLength:(int)min maxLength:(int)max {
	NSString *emailRegEx = [NSString stringWithFormat:@"[0-9a-zA-Z_]{%i,%i}", min, max];
    NSPredicate *regExPredicate =
	[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
	return [regExPredicate evaluateWithObject:text];
}

+ (CGSize)sizeForLabel:(UILabel*)label text:(NSString*)text {
    CGSize size = CGSizeMake(label.frame.size.width, 1000);
    return [text sizeWithFont:label.font 
                constrainedToSize:size 
                   lineBreakMode:UILineBreakModeWordWrap];
}

+ (NSMutableDictionary *)dictionaryFromQueryComponents:(NSString*)urlString {
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    NSArray *array = [urlString componentsSeparatedByString:@"&"];
    for (NSString *keyValuePairString in array) {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        NSString *key = [keyValuePairArray objectAtIndex:0];
        NSString *value = [keyValuePairArray objectAtIndex:1];
        [queryComponents setValue:value forKey:key];
    }
    return queryComponents;
}

+ (UIImage*)resizeImage:(UIImage*)image maxSide:(int)side {
	CGSize scaledSize;
	if (image.size.width > image.size.height) {
		scaledSize.width = image.size.width > side ? side : image.size.width;
		scaledSize.height = image.size.height / (image.size.width / scaledSize.width); 
	} else {
		scaledSize.height = image.size.height > side ? side : image.size.height;
		scaledSize.width = image.size.width / (image.size.height / scaledSize.height); 
	}		
	UIGraphicsBeginImageContext(scaledSize);
	
	[image drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;	
}

+ (void)clearImage:(NSString*)imagePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return;
    }
  
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:imagePath
                                               error:&error];
    if (error != nil) {
        NSLog(@"error delete file %@ %@", imagePath, [error localizedDescription]);
    }
}

+ (void)clearCache:(NSString*)folderName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *saveImagePath_ = [basePath stringByAppendingPathComponent:folderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:saveImagePath_]) {
        return;
    }
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:saveImagePath_ error:&error];
    if (error != nil) {
        NSLog(@"error save directory %@ %@", saveImagePath_, [error localizedDescription]);
        return;
    }
    for (NSString *path in files) {
        error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[saveImagePath_ stringByAppendingPathComponent:path]
                                                   error:&error];
        if (error != nil) {
            NSLog(@"error delete file %@ %@", path, [error localizedDescription]);
        }
    }
}

+ (NSString*)friendsStringForValue:(int)val {
    NSString* value = [NSString stringWithFormat:@"%i", val];
	unichar last = [value characterAtIndex:([value length] - 1)];
    if ([value length] > 1) {
        unichar preLast = [value characterAtIndex:([value length] - 2)];
        if (preLast == '1') {
            return @"друзей";
        }
    }
    
	switch (last) {
		case '1':
			return @"друг";
			break;
		case '2':
		case '3':
		case '4':
			return @"друга";
			break;
		default:
			return @"друзей";
			break;
	}
}

+ (NSString*)mapUrl:(CLLocationCoordinate2D)coordinate {
    
    NSString* url = [NSString stringWithFormat:@"http://maps.google.com/staticmap?center=%f,%f&markers=%f,%f,green&zoom=16&size=200x200&maptype=mobile%@", coordinate.latitude, coordinate.longitude, coordinate.latitude, coordinate.longitude, @""];
    return url;
}

@end

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5)

- (NSString *) MD5 
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end