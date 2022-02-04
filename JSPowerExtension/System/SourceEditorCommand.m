//
//  SourceEditorCommand.m
//  ToolBox
//
//  Created by everettjf on 2018/10/30.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "QVSharedUtil.h"
#import "QVPackageManager.h"
#import "QVCommandAction.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSError *error = [self syncRunCommand:invocation];
    completionHandler(error);
}

- (NSError*)syncRunCommand:(XCSourceEditorCommandInvocation *)invocation
{
    NSString *identifier = invocation.commandIdentifier;
    
    QVPackage * package = [QVPackageManager sharedManager].packageMap[identifier];
    if(!package) {
        return [QVSharedUtil createInternalError:@"failed to find package"];
    }
    
    QVMenu * menu = package.menuMap[identifier];
    if(! menu) {
        return [QVSharedUtil createInternalError:@"failed to find menu"];
    }
    
    NSLog(@"menu clicked : %@", menu.name);
    
    QVCommandAction *action = [[QVCommandAction alloc] init];
    action.menu = menu;
    action.invocation = invocation;
    
    if(! [action fire] ) {
        return action.error;
    }
    
    return nil;
}
@end
