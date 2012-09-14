//
//  FPXmlParser.m
//  flirt
//
//  Created by zlata samarskaya on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MXmlParser.h"
#import "TBXML.h"
#import "MUser.h"

@implementation MXmlParser

/* <array>
 <dict>
 <id>1303</id>
 <login>salata3</login>
 <email/>
 <name/>
 <interests/>
 <status/>
 <picurl/>
 <type>app</type>
 </dict>
 </array>*/
+ (void)userInfoFromXml:(NSString*)xml {
	TBXML *tbxml = [[TBXML tbxmlWithXMLString:xml] retain];
	TBXMLElement *root = tbxml.rootXMLElement;
    if ([[TBXML elementName:root] isEqualToString:@"error"]) {
        return;
    }
	TBXMLElement *record = [TBXML childElementNamed:@"dict" parentElement:root];
 
    MCurrentUser *user = [MCurrentUser sharedInstance];
    user.user.name = [TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:record]];
    user.user.email = [TBXML textForElement:[TBXML childElementNamed:@"email" parentElement:record]];
    user.user.interests = [TBXML textForElement:[TBXML childElementNamed:@"interests" parentElement:record]];
    user.login = [TBXML textForElement:[TBXML childElementNamed:@"login" parentElement:record]];
    user.user.status = [TBXML textForElement:[TBXML childElementNamed:@"status" parentElement:record]];
    user.user.imageUrl = [TBXML textForElement:[TBXML childElementNamed:@"picurl" parentElement:record]];
    user.user.databaseId = [[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:record]] intValue];
	if (user.user.name == nil || [user.user.name length] == 0) {
        user.user.name = user.login;
    }
    [tbxml release];	
}

 @end
