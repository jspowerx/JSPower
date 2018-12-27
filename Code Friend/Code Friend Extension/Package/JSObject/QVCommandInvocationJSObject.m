//
//  QVCommandInvocation.m
//  ToolBox
//
//  Created by everettjf on 2018/11/4.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "QVCommandInvocationJSObject.h"


@implementation QVCommandInvocationJSObject

- (NSString *)contentUTI
{
    return self.invocation.buffer.contentUTI;
}

- (NSInteger)tabWidth
{
    return self.invocation.buffer.tabWidth;
}

- (NSInteger)indentationWidth
{
    return self.invocation.buffer.indentationWidth;
}

- (BOOL)usesTabsForIndentation
{
    return self.invocation.buffer.usesTabsForIndentation;
}
- (BOOL)selectionExist
{
    if(self.invocation.buffer.selections.count == 0){
        return NO;
    }
    XCSourceTextRange *range = self.invocation.buffer.selections[0];
    if(range.start.line == range.end.line
       && range.start.column == range.end.column){
        return NO;
    }
    return YES;
}
- (NSArray<NSArray<NSNumber *> *> *)selections
{
    if(self.invocation.buffer.selections.count == 0){
        return @[];
    }
    
    NSMutableArray* result = [[NSMutableArray alloc]initWithCapacity:self.invocation.buffer.selections.count];
    for(XCSourceTextRange *range in self.invocation.buffer.selections){
        [result addObject:@[
                            @(range.start.line),
                            @(range.start.column),
                            @(range.end.line),
                            @(range.end.column)
                            ]];
    }
    
    return result;
}

- (void)setSelections:(NSArray<NSArray<NSNumber *> *> *)selections
{
    [self.invocation.buffer.selections removeAllObjects];
    for(NSArray<NSNumber*>* sel in selections){
        if(sel.count != 4){
            // error format
            return;
        }
        XCSourceTextPosition start,end;
        start.line = sel[0].integerValue;
        start.column = sel[1].integerValue;
        end.line = sel[2].integerValue;
        end.column = sel[3].integerValue;
        
        XCSourceTextRange *range = [[XCSourceTextRange alloc]initWithStart:start end:end];
        [self.invocation.buffer.selections addObject:range];
    }
}

- (NSArray<NSNumber *> *)firstSelection
{
    if(self.invocation.buffer.selections.count == 0){
        return @[];
    }
    XCSourceTextRange * range = self.invocation.buffer.selections.firstObject;
    return @[
      @(range.start.line),
      @(range.start.column),
      @(range.end.line),
      @(range.end.column)
      ];
}

- (NSArray<NSString *> *)selectionStrings
{
    if(self.invocation.buffer.selections.count == 0){
        return @[];
    }
    NSMutableArray<NSString*> *lines = self.invocation.buffer.lines;
    NSMutableArray<NSString*>* result = [[NSMutableArray alloc] initWithCapacity:self.invocation.buffer.selections.count];
    for(XCSourceTextRange *range in self.invocation.buffer.selections){
        if(range.start.line == range.end.line && range.start.column == range.end.column){
            // no selection, only cursor at that line
            continue;
        }
        
        NSMutableString *currentString = [[NSMutableString alloc]init];
        
        if(range.start.line == range.end.line){
            // singleline
            NSString *currentLine = lines[range.start.line];
            currentString = [[currentLine substringWithRange:NSMakeRange(range.start.column, range.end.column - range.start.column)] mutableCopy];
        } else {
            // multiline
            for(NSInteger currentLineIndex = range.start.line; currentLineIndex <= range.end.line; currentLineIndex++) {
                NSString *currentLine = lines[currentLineIndex];
                if(currentLineIndex == range.start.line){
                    [currentString appendString:[currentLine substringFromIndex:range.start.column]];
                } else if(currentLineIndex == range.end.line) {
                    [currentString appendString:[currentLine substringToIndex:range.end.column]];
                } else{
                    [currentString appendString:currentLine];
                }
            }
        }
        
        [result addObject:currentString];
    }
    return result;
}

- (NSArray<NSString *> *)selectionLines
{
    if(self.invocation.buffer.selections.count == 0){
        return @[];
    }
    NSMutableArray<NSString*> *lines = self.invocation.buffer.lines;
    NSMutableArray<NSString*>* result = [[NSMutableArray alloc] initWithCapacity:self.invocation.buffer.selections.count];

    for(XCSourceTextRange *range in self.invocation.buffer.selections){
        if(range.start.line == range.end.line && range.start.column == range.end.column){
            // no selection, only cursor at that line
            continue;
        }
        
        for(NSInteger currentLineIndex = range.start.line; currentLineIndex <= range.end.line; currentLineIndex++) {
            if(currentLineIndex >= lines.count){
                continue;
            }
            NSString *currentLine = lines[currentLineIndex];
            [result addObject:currentLine];
        }
    }
    return result;
}

- (NSString *)completeBuffer
{
    return self.invocation.buffer.completeBuffer;
}

- (void)setCompleteBuffer:(NSString *)completeBuffer
{
    self.invocation.buffer.completeBuffer = completeBuffer;
}

- (NSArray<NSString *> *)lines
{
    return self.invocation.buffer.lines;
}
- (NSUInteger)lineCount
{
    return self.invocation.buffer.lines.count;
}

- (void)insertLines:(NSArray<NSString *> *)lines atIndex:(NSUInteger)index
{
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, lines.count)];
    [self.invocation.buffer.lines insertObjects:lines atIndexes:set];
}

- (void)appendLines:(NSArray<NSString *> *)lines
{
    [self.invocation.buffer.lines addObjectsFromArray:lines];
}

- (void)removeLinesFrom:(NSUInteger)startLine to:(NSUInteger)endLine
{
    NSUInteger length = endLine - startLine + 1;
    
    if(startLine + length > self.invocation.buffer.lines.count){
        length--;
    }
    [self.invocation.buffer.lines removeObjectsInRange:NSMakeRange(startLine, length)];
}

- (void)assignLine:(NSString*)line atIndex:(NSUInteger)index
{
    if(index + 1 > self.invocation.buffer.lines.count){
        return;
    }
    [self.invocation.buffer.lines setObject:line atIndexedSubscript:index];
}


@end
