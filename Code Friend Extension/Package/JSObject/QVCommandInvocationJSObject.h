//
//  QVCommandInvocation.h
//  ToolBox
//
//  Created by everettjf on 2018/11/4.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;
#import <XcodeKit/XcodeKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QVCommandInvocationJSExport <JSExport>

@property (readonly, copy) NSString *contentUTI;
@property (readonly) NSInteger tabWidth;
@property (readonly) NSInteger indentationWidth;
@property (readonly) BOOL usesTabsForIndentation;

@property (readonly) BOOL selectionExist;
@property (strong) NSArray<NSArray<NSNumber*>*> *selections; // array of [beginLine,beginCol,endLine,endCol]
@property (strong, readonly) NSArray<NSNumber*> *firstSelection; // first selection range [beginLine,beginCol,endLine,endCol]
@property (readonly) NSArray<NSString*> *selectionStrings;
@property (readonly) NSArray<NSString*> *selectionLines;

@property (copy) NSString* completeBuffer;

@property (readonly) NSArray<NSString*> *lines;
@property (readonly) NSUInteger lineCount;

- (void)insertLines:(NSArray<NSString*>*)lines atIndex:(NSUInteger)index;
- (void)appendLines:(NSArray<NSString*>*)lines;
- (void)removeLinesFrom:(NSUInteger)startLine to:(NSUInteger)endLine;
- (void)assignLine:(NSString*)line atIndex:(NSUInteger)index;

@end

@interface QVCommandInvocationJSObject : NSObject<QVCommandInvocationJSExport>

@property (strong) XCSourceEditorCommandInvocation *invocation;

@end

NS_ASSUME_NONNULL_END
