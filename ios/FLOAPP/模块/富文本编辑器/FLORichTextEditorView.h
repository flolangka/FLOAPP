//
//  FLORichTextEditorView.h
//  ZSSRichTextEditor
//
//  Created by 360doc on 2017/3/15.
//  Copyright © 2017年 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The types of toolbar items that can be added
 */
static NSString * const ZSSRichTextEditorToolbarBold = @"com.zedsaid.toolbaritem.bold";
static NSString * const ZSSRichTextEditorToolbarItalic = @"com.zedsaid.toolbaritem.italic";
static NSString * const ZSSRichTextEditorToolbarSubscript = @"com.zedsaid.toolbaritem.subscript";
static NSString * const ZSSRichTextEditorToolbarSuperscript = @"com.zedsaid.toolbaritem.superscript";
static NSString * const ZSSRichTextEditorToolbarStrikeThrough = @"com.zedsaid.toolbaritem.strikeThrough";
static NSString * const ZSSRichTextEditorToolbarUnderline = @"com.zedsaid.toolbaritem.underline";
static NSString * const ZSSRichTextEditorToolbarJustifyLeft = @"com.zedsaid.toolbaritem.justifyLeft";
static NSString * const ZSSRichTextEditorToolbarJustifyCenter = @"com.zedsaid.toolbaritem.justifyCenter";
static NSString * const ZSSRichTextEditorToolbarJustifyRight = @"com.zedsaid.toolbaritem.justifyRight";
static NSString * const ZSSRichTextEditorToolbarJustifyFull = @"com.zedsaid.toolbaritem.justifyFull";
static NSString * const ZSSRichTextEditorToolbarH1 = @"com.zedsaid.toolbaritem.h1";
static NSString * const ZSSRichTextEditorToolbarH2 = @"com.zedsaid.toolbaritem.h2";
static NSString * const ZSSRichTextEditorToolbarH3 = @"com.zedsaid.toolbaritem.h3";
static NSString * const ZSSRichTextEditorToolbarH4 = @"com.zedsaid.toolbaritem.h4";
static NSString * const ZSSRichTextEditorToolbarH5 = @"com.zedsaid.toolbaritem.h5";
static NSString * const ZSSRichTextEditorToolbarH6 = @"com.zedsaid.toolbaritem.h6";
static NSString * const ZSSRichTextEditorToolbarUnorderedList = @"com.zedsaid.toolbaritem.unorderedList";
static NSString * const ZSSRichTextEditorToolbarOrderedList = @"com.zedsaid.toolbaritem.orderedList";
static NSString * const ZSSRichTextEditorToolbarHorizontalRule = @"com.zedsaid.toolbaritem.horizontalRule";
static NSString * const ZSSRichTextEditorToolbarIndent = @"com.zedsaid.toolbaritem.indent";
static NSString * const ZSSRichTextEditorToolbarOutdent = @"com.zedsaid.toolbaritem.outdent";
static NSString * const ZSSRichTextEditorToolbarInsertImageFromPhotoLibrary = @"com.zedsaid.toolbaritem.insertImageFromPhotoLibrary";
static NSString * const ZSSRichTextEditorToolbarInsertImageFromCamera = @"com.zedsaid.toolbaritem.insertImageFromCamera";
static NSString * const ZSSRichTextEditorToolbarInsertLink = @"com.zedsaid.toolbaritem.insertLink";
static NSString * const ZSSRichTextEditorToolbarUndo = @"com.zedsaid.toolbaritem.undo";
static NSString * const ZSSRichTextEditorToolbarRedo = @"com.zedsaid.toolbaritem.redo";
static NSString * const ZSSRichTextEditorToolbarViewSource = @"com.zedsaid.toolbaritem.viewSource";
static NSString * const ZSSRichTextEditorToolbarParagraph = @"com.zedsaid.toolbaritem.paragraph";
static NSString * const ZSSRichTextEditorToolbarAll = @"com.zedsaid.toolbaritem.all";
static NSString * const ZSSRichTextEditorToolbarNone = @"com.zedsaid.toolbaritem.none";

@class ZSSBarButtonItem;

@interface FLORichTextEditorView : UIView

/**
 弱引用的ViewController
 */
@property (nonatomic, weak) UIViewController *weakVC;

/**
 *  Returns the HTML from the Rich Text Editor
 *
 */
- (void)getHTML:(void(^)(NSString *))completion;

/**
 *  Returns the plain text from the Rich Text Editor
 *
 */
- (void)getText:(void(^)(NSString *))completion;

// 键盘通知
- (void)keyboardWillShowOrHide:(NSNotification *)notification;

// 释放内存
- (void)releaseEditor;

/**
 插入图片的路径
 
 @param imageName 图片保存名称
 @return 路径
 */
- (NSString *)imagePathWithName:(NSString *)imageName;


#pragma mark - ZSS Native
/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;

/**
 *  If the keyboard should be shown when the editor loads
 */
@property (nonatomic) BOOL shouldShowKeyboard;

/**
 *  The placeholder text to use if there is no editor content
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 *  Toolbar items to include
 */
@property (nonatomic, strong) NSArray *enabledToolbarItems;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *toolbarItemTintColor;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *toolbarItemSelectedTintColor;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(NSString *)html;

/**
 *  Inserts HTML at the caret position
 *
 *  @param html  HTML string to insert
 *
 */
- (void)insertHTML:(NSString *)html;

/**
 *  Add a custom UIBarButtonItem by using a UIButton
 */
- (void)addCustomToolbarItemWithButton:(UIButton*)button;

/**
 *  Add a custom ZSSBarButtonItem
 */
- (void)addCustomToolbarItem:(ZSSBarButtonItem *)item;

@end
