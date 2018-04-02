//
//  FLORichTextEditorView.m
//  ZSSRichTextEditor
//
//  Created by 360doc on 2017/3/15.
//  Copyright © 2017年 Zed Said Studio. All rights reserved.
//

#import "FLORichTextEditorView.h"

#import <objc/runtime.h>
#import "ZSSBarButtonItem.h"
#import "ZSSTextView.h"

#import <WebKit/WebKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@import JavaScriptCore;

/**
 
 UIWebView modifications for hiding the inputAccessoryView
 
 **/
@interface UIWebView (HackishAccessoryHiding)
@property (nonatomic, assign) BOOL hidesInputAccessoryView;
@end

@implementation UIWebView (HackishAccessoryHiding)

static const char * const hackishFixClassName = "UIWebBrowserViewMinusAccessoryView";
static Class hackishFixClass = Nil;

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"UIWebBrowserView"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningNil {
    return nil;
}

- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
    if (!hackishFixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

- (BOOL) hidesInputAccessoryView {
    UIView *browserView = [self hackishlyFoundBrowserView];
    return [browserView class] == hackishFixClass;
}

- (void) setHidesInputAccessoryView:(BOOL)value {
    UIView *browserView = [self hackishlyFoundBrowserView];
    if (browserView == nil) {
        return;
    }
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
    
    if (value) {
        object_setClass(browserView, hackishFixClass);
    }
    else {
        Class normalClass = objc_getClass("UIWebBrowserView");
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

@end

@interface FLORichTextEditorView () <UIWebViewDelegate, UITextViewDelegate, UIAlertViewDelegate, WKNavigationDelegate, WKScriptMessageHandler, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/*
 *  Toolbar containing ZSSBarButtonItems
 */
@property (nonatomic, strong) UIToolbar *toolbar;

/*
 *  Scroll view containing the toolbar
 */
@property (nonatomic, strong) UIScrollView *toolBarScroll;

/*
 *  Holder for all of the toolbar components
 */
@property (nonatomic, strong) UIView *toolbarHolder;

/*
 *  String for the HTML
 */
@property (nonatomic, strong) NSString *htmlString;

/*
 *  UIWebView for writing/editing/displaying the content
 */
@property (nonatomic, strong) UIWebView *editorView;
@property (nonatomic, strong) WKWebView *wkEditorView;

/*
 *  ZSSTextView for displaying the source code for what is displayed in the editor view
 */
@property (nonatomic, strong) ZSSTextView *sourceView;

/*
 *  BOOL for holding if the resources are loaded or not
 */
@property (nonatomic) BOOL resourcesLoaded;

/*
 *  Image Picker for selecting photos from users photo library
 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;

/*
 *  Array holding the enabled editor items
 */
@property (nonatomic, strong) NSArray *editorItemsEnabled;

/*
 *  Bar button item for the keyboard dismiss button in the toolbar
 */
@property (nonatomic, strong) UIBarButtonItem *keyboardItem;

/*
 *  Array for custom bar button items
 */
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;

/*
 *  Array for custom ZSSBarButtonItems
 */
@property (nonatomic, strong) NSMutableArray *customZSSBarButtonItems;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;

/*
 *  BOOL for if the editor is loaded or not
 */
@property (nonatomic) BOOL editorLoaded;

@end

@implementation FLORichTextEditorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //Initialise variables
        self.editorLoaded = NO;
        self.shouldShowKeyboard = NO;
        self.formatHTML = YES;
        
        //Initalise enabled toolbar items array
        self.enabledToolbarItems = [[NSArray alloc] init];
        
        CGRect editFrame = frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        editFrame.size.height -= 44;
        //Source View
        [self createSourceViewWithFrame:editFrame];
        
        //Editor View
        [self createEditorViewWithFrame:editFrame];
        
        //Scrolling View
        [self createToolBarScroll];
        
        //Toolbar with icons
        [self createToolbar];
        
        //Parent holding view
        [self createParentHoldingView];
        
        //Hide Keyboard
        if (![self isIpad]) {
            
            // Toolbar holder used to crop and position toolbar
            UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-44, 0, 44, 44)];
            toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            toolbarCropper.clipsToBounds = YES;
            
            // Use a toolbar so that we can tint
            UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(-7, -1, 44, 44)];
            [toolbarCropper addSubview:keyboardToolbar];
            
            self.keyboardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSkeyboard.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard)];
            keyboardToolbar.items = @[self.keyboardItem];
            [self.toolbarHolder addSubview:toolbarCropper];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6f, 44)];
            line.backgroundColor = [UIColor lightGrayColor];
            line.alpha = 0.7f;
            [toolbarCropper addSubview:line];
            
        }
        
        [self addSubview:self.toolbarHolder];
        
        //Build the toolbar
        [self buildToolbar];
        
        //Load Resources
        if (!self.resourcesLoaded) {
            
            [self loadResources];
            
        }
    }
    return self;
}

#pragma mark - Set Up View Section

- (void)createSourceViewWithFrame:(CGRect)frame {
    
    self.sourceView = [[ZSSTextView alloc] initWithFrame:frame];
    self.sourceView.hidden = YES;
    self.sourceView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.sourceView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.sourceView.font = [UIFont fontWithName:@"Courier" size:13.0];
    self.sourceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sourceView.autoresizesSubviews = YES;
    self.sourceView.delegate = self;
    [self addSubview:self.sourceView];
    
}

- (void)createEditorViewWithFrame:(CGRect)frame {
    
    /* WKWebView 未解决的坑
     1. 本地图片使用路径无法加载，需要转成base64，这样需要设置img的id来标识图片
     2. 点击靠下方区域键盘弹出后，editor无法准确滚动到光标处
     */
    if ([UIDevice currentDevice].systemVersion.floatValue >= MAXFLOAT) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建UserContentController（提供JavaScript向webView发送消息的方法）
        WKUserContentController* userContent = [[WKUserContentController alloc] init];
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        [userContent addScriptMessageHandler:self name:@"ConfigToolBar"];
        // 将UserConttentController设置到配置文件
        config.userContentController = userContent;
        
        
        self.wkEditorView = [[WKWebView alloc] initWithFrame:frame configuration:config];
        self.wkEditorView.navigationDelegate = self;
        self.wkEditorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.wkEditorView.scrollView.bounces = NO;
        self.wkEditorView.allowsLinkPreview = NO;
        self.wkEditorView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.wkEditorView];
    } else {
        self.editorView = [[UIWebView alloc] initWithFrame:frame];
        self.editorView.delegate = self;
        self.editorView.hidesInputAccessoryView = YES;
        self.editorView.keyboardDisplayRequiresUserAction = NO;
        self.editorView.scalesPageToFit = YES;
        self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.editorView.scrollView.bounces = NO;
        self.editorView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.editorView];
    }
}

- (void)createToolBarScroll {
    
    self.toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self isIpad] ? self.frame.size.width : self.frame.size.width - 44, 44)];
    self.toolBarScroll.backgroundColor = [UIColor clearColor];
    self.toolBarScroll.showsHorizontalScrollIndicator = NO;
    
}

- (void)createToolbar {
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.toolbar.backgroundColor = [UIColor clearColor];
    [self.toolBarScroll addSubview:self.toolbar];
    self.toolBarScroll.autoresizingMask = self.toolbar.autoresizingMask;
    
}

- (void)createParentHoldingView {
    
    //Background Toolbar
    UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //Parent holding view
    self.toolbarHolder = [[UIView alloc] init];
    self.toolbarHolder.frame = CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44);
    
    self.toolbarHolder.autoresizingMask = self.toolbar.autoresizingMask;
    [self.toolbarHolder addSubview:self.toolBarScroll];
    [self.toolbarHolder insertSubview:backgroundToolbar atIndex:0];
    
}

- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
    }
    return _imagePicker;
}

// 释放内存
- (void)releaseEditor {
    if (_wkEditorView) {
        [_wkEditorView.configuration.userContentController removeScriptMessageHandlerForName:@"ConfigToolBar"];
        [_wkEditorView stopLoading];
        _wkEditorView = nil;
    }
    if (_editorView) {
        [_editorView loadHTMLString:@"" baseURL:nil];
        [_editorView stopLoading];
        _editorView.delegate = nil;
        [_editorView removeFromSuperview];
        _editorView = nil;
    }
    _weakVC = nil;
}

#pragma mark - Resources Section

- (void)loadResources {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle mainBundle];
    
    //Create a string with the contents of editor.html
    NSString *filePath = [bundle pathForResource:@"editor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *jquery = [bundle pathForResource:@"jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];
    
    //Add JSBeautifier.js to the html file
    NSString *beautifier = [bundle pathForResource:@"JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];
    
    //Add ZSSRichTextEditor.js to the html file
    NSString *source = [bundle pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    
    if (_editorView) {
        [self.editorView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@""]];
    } else if (_wkEditorView) {
        [self.wkEditorView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@""]];
    }
    
    self.resourcesLoaded = YES;
}

#pragma mark - webView mothod
- (void)evaluatingJavaScript:(NSString *)js {
    if (_editorView) {
        [_editorView stringByEvaluatingJavaScriptFromString:js];
    } else if (_wkEditorView) {
        [_wkEditorView evaluateJavaScript:js completionHandler:nil];
    }
}

#pragma mark - Toolbar Section

- (void)setEnabledToolbarItems:(NSArray *)enabledToolbarItems {
    
    _enabledToolbarItems = enabledToolbarItems;
    [self buildToolbar];
    
}


- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor {
    
    _toolbarItemTintColor = toolbarItemTintColor;
    
    // Update the color
    for (ZSSBarButtonItem *item in self.toolbar.items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    self.keyboardItem.tintColor = toolbarItemTintColor;
    
}


- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor {
    
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
    
}

- (NSArray *)itemsForToolbar {
    
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // None
    if(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])
    {
        return items;
    }
    
    BOOL customOrder = NO;
    if (_enabledToolbarItems && ![_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll]){
        customOrder = YES;
        for(int i=0; i < _enabledToolbarItems.count;i++){
            [items addObject:@""];
        }
    }
    
    // Bold
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBold]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bold = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbold.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setBold)];
        bold.label = @"bold";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarBold] withObject:bold];
        } else {
            [items addObject:bold];
        }
    }
    
    // Italic
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarItalic]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *italic = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSitalic.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setItalic)];
        italic.label = @"italic";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarItalic] withObject:italic];
        } else {
            [items addObject:italic];
        }
    }
    
    // Subscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSubscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *subscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsubscript.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setSubscript)];
        subscript.label = @"subscript";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarSubscript] withObject:subscript];
        } else {
            [items addObject:subscript];
        }
    }
    
    // Superscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSuperscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *superscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsuperscript.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setSuperscript)];
        superscript.label = @"superscript";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarSuperscript] withObject:superscript];
        } else {
            [items addObject:superscript];
        }
    }
    
    // Strike Through
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarStrikeThrough]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *strikeThrough = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSstrikethrough.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setStrikethrough)];
        strikeThrough.label = @"strikeThrough";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarStrikeThrough] withObject:strikeThrough];
        } else {
            [items addObject:strikeThrough];
        }
    }
    
    // Underline
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnderline]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *underline = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunderline.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setUnderline)];
        underline.label = @"underline";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarUnderline] withObject:underline];
        } else {
            [items addObject:underline];
        }
    }
    
    // Undo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUndo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *undoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSundo.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
        undoButton.label = @"undo";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarUndo] withObject:undoButton];
        } else {
            [items addObject:undoButton];
        }
    }
    
    // Redo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRedo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *redoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSredo.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
        redoButton.label = @"redo";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarRedo] withObject:redoButton];
        } else {
            [items addObject:redoButton];
        }
    }
    
    // Align Left
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyLeft]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignLeft = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSleftjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignLeft)];
        alignLeft.label = @"justifyLeft";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyLeft] withObject:alignLeft];
        } else {
            [items addObject:alignLeft];
        }
    }
    
    // Align Center
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyCenter]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignCenter = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSScenterjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignCenter)];
        alignCenter.label = @"justifyCenter";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyCenter] withObject:alignCenter];
        } else {
            [items addObject:alignCenter];
        }
    }
    
    // Align Right
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyRight]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignRight = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSrightjustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignRight)];
        alignRight.label = @"justifyRight";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyRight] withObject:alignRight];
        } else {
            [items addObject:alignRight];
        }
    }
    
    // Align Justify
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyFull]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignFull = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSforcejustify.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(alignFull)];
        alignFull.label = @"justifyFull";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarJustifyFull] withObject:alignFull];
        } else {
            [items addObject:alignFull];
        }
    }
    
    // Paragraph
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarParagraph]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *paragraph = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSparagraph.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(paragraph)];
        paragraph.label = @"p";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarParagraph] withObject:paragraph];
        } else {
            [items addObject:paragraph];
        }
    }
    
    // Header 1
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH1]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh1.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading1)];
        h1.label = @"h1";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH1] withObject:h1];
        } else {
            [items addObject:h1];
        }
    }
    
    // Header 2
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH2]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h2 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh2.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading2)];
        h2.label = @"h2";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH2] withObject:h2];
        } else {
            [items addObject:h2];
        }
    }
    
    // Header 3
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH3]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h3 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh3.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading3)];
        h3.label = @"h3";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH3] withObject:h3];
        } else {
            [items addObject:h3];
        }
    }
    
    // Heading 4
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH4]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h4 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh4.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading4)];
        h4.label = @"h4";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH4] withObject:h4];
        } else {
            [items addObject:h4];
        }
    }
    
    // Header 5
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH5]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h5 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh5.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading5)];
        h5.label = @"h5";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH5] withObject:h5];
        } else {
            [items addObject:h5];
        }
    }
    
    // Heading 6
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH6]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h6 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh6.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(heading6)];
        h6.label = @"h6";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarH6] withObject:h6];
        } else {
            [items addObject:h6];
        }
    }
    
    // Unordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnorderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ul = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setUnorderedList)];
        ul.label = @"unorderedList";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarUnorderedList] withObject:ul];
        } else {
            [items addObject:ul];
        }
    }
    
    // Ordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOrderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ol = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setOrderedList)];
        ol.label = @"orderedList";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarOrderedList] withObject:ol];
        } else {
            [items addObject:ol];
        }
    }
    
    // Horizontal Rule
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarHorizontalRule]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *hr = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSShorizontalrule.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setHR)];
        hr.label = @"horizontalRule";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarHorizontalRule] withObject:hr];
        } else {
            [items addObject:hr];
        }
    }
    
    // Indent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarIndent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *indent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSindent.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setIndent)];
        indent.label = @"indent";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarIndent] withObject:indent];
        } else {
            [items addObject:indent];
        }
    }
    
    // Outdent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOutdent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *outdent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSoutdent.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(setOutdent)];
        outdent.label = @"outdent";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarOutdent] withObject:outdent];
        } else {
            [items addObject:outdent];
        }
    }
    
    // Image
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertImageFromCamera]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertImage = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSimageDevice.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertImage)];
        insertImage.label = @"image";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarInsertImageFromCamera] withObject:insertImage];
        } else {
            [items addObject:insertImage];
        }
    }
    
    // Image From Device
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertImageFromPhotoLibrary]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertImageFromDevice = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSimage.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertImageFromDevice)];
        insertImageFromDevice.label = @"imageFromDevice";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarInsertImageFromPhotoLibrary] withObject:insertImageFromDevice];
        } else {
            [items addObject:insertImageFromDevice];
        }
    }
    
    // Insert Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSlink.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(insertLink)];
        insertLink.label = @"link";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarInsertLink] withObject:insertLink];
        } else {
            [items addObject:insertLink];
        }
    }
    
    // Show Source
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarViewSource]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *showSource = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSviewsource.png" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(showHTMLSource:)];
        showSource.label = @"source";
        if (customOrder) {
            [items replaceObjectAtIndex:[_enabledToolbarItems indexOfObject:ZSSRichTextEditorToolbarViewSource] withObject:showSource];
        } else {
            [items addObject:showSource];
        }
    }
    
    return [NSArray arrayWithArray:items];
    
}


- (void)buildToolbar {
    
    // Check to see if we have any toolbar items, if not, add them all
    NSArray *items = [self itemsForToolbar];
    if (items.count == 0 && !(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])) {
        _enabledToolbarItems = @[ZSSRichTextEditorToolbarAll];
        items = [self itemsForToolbar];
    }
    
    if (self.customZSSBarButtonItems != nil) {
        items = [items arrayByAddingObjectsFromArray:self.customZSSBarButtonItems];
    }
    
    // get the width before we add custom buttons
    CGFloat toolbarWidth = items.count == 0 ? 0.0f : (CGFloat)(items.count * 39) - 10;
    
    if(self.customBarButtonItems != nil)
    {
        items = [items arrayByAddingObjectsFromArray:self.customBarButtonItems];
        for(ZSSBarButtonItem *buttonItem in self.customBarButtonItems)
        {
            toolbarWidth += buttonItem.customView.frame.size.width + 11.0f;
        }
    }
    
    self.toolbar.items = items;
    for (ZSSBarButtonItem *item in items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    
    self.toolbar.frame = CGRectMake(0, 0, toolbarWidth, 44);
    self.toolBarScroll.contentSize = CGSizeMake(self.toolbar.frame.size.width, 44);
}


#pragma mark - Editor Modification Section

- (void)setPlaceholderText {
    //Call the setPlaceholder javascript method if a placeholder has been set
    if (self.placeholder != NULL && [self.placeholder length] != 0) {
        NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
        [self evaluatingJavaScript:js];
    }
}

- (void)setFooterHeight:(float)footerHeight {
    
    //Call the setFooterHeight javascript method
    NSString *js = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self evaluatingJavaScript:js];
    
}

- (void)setContentHeight:(float)contentHeight {
    
    //Call the contentHeight javascript method
    NSString *js = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self evaluatingJavaScript:js];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    if (_placeholder) {
        [self setPlaceholderText];
    }
}

#pragma mark - Editor Interaction

- (void)focusTextEditor {
    if (_editorView) {
        self.editorView.keyboardDisplayRequiresUserAction = NO;
    }
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self evaluatingJavaScript:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self evaluatingJavaScript:js];
}

- (void)setHTML:(NSString *)html {
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
}

- (void)updateHTML {
    NSString *html = self.internalHTML;
    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self evaluatingJavaScript:trigger];
    
}

- (void)getHTML:(void(^)(NSString *))completion {
    NSString *js = @"zss_editor.getHTML();";
    
    if (_editorView) {
        NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:js];
        html = [self removeQuotesFromHTML:html];
        
        [self tidyHTML:html completion:^(NSString *tidyHTML) {
            if (completion) {
                completion(tidyHTML);
            }
        }];
    } else if (_wkEditorView) {
        [_wkEditorView evaluateJavaScript:@"zss_editor.getHTML();" completionHandler:^(NSString * _Nullable jsResult, NSError * _Nullable error) {
            NSString *html = @"";
            if (jsResult && [jsResult isKindOfClass:[NSString class]] && jsResult.length) {
                html = jsResult;
                html = [self removeQuotesFromHTML:html];
            }
            
            [self tidyHTML:html completion:^(NSString *tidyHTML) {
                if (completion) {
                    completion(tidyHTML);
                }
            }];
        }];
    }
}

- (void)getText:(void(^)(NSString *))completion {
    NSString *js = @"zss_editor.getText();";
    
    if (_editorView) {
        NSString *text = [self.editorView stringByEvaluatingJavaScriptFromString:js];
        
        if (completion) {
            completion(text);
        }
    } else if (_wkEditorView) {
        [_wkEditorView evaluateJavaScript:js completionHandler:^(NSString * _Nullable jsResult, NSError * _Nullable error) {
            NSString *text = @"";
            if (jsResult && [jsResult isKindOfClass:[NSString class]] && jsResult.length) {
                text = jsResult;
            }
            
            if (completion) {
                completion(text);
            }
        }];
    }
}

- (void)insertHTML:(NSString *)html {
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self evaluatingJavaScript:trigger];
}

- (void)dismissKeyboard {
    [self endEditing:YES];
}

- (void)showHTMLSource:(ZSSBarButtonItem *)barButtonItem {
    if (self.sourceView.hidden) {
        [self getHTML:^(NSString *html) {
            self.sourceView.text = html;
            self.sourceView.hidden = NO;
            barButtonItem.tintColor = [UIColor blackColor];
            self.editorView.hidden = YES;
            self.wkEditorView.hidden = YES;
            [self enableToolbarItems:NO];
            
            if (CGRectGetMaxY(self.toolbarHolder.frame) < CGRectGetHeight(self.bounds)) {
                [self.sourceView becomeFirstResponder];
            }
        }];
    } else {
        [self setHTML:self.sourceView.text];
        barButtonItem.tintColor = [self barButtonItemDefaultColor];
        [self.sourceView resignFirstResponder];
        self.sourceView.hidden = YES;
        self.editorView.hidden = NO;
        self.wkEditorView.hidden = NO;
        [self enableToolbarItems:YES];
    }
}

- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self evaluatingJavaScript:trigger];
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self evaluatingJavaScript:trigger];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self evaluatingJavaScript:trigger];
}

- (void)alignFull {
    NSString *trigger = @"zss_editor.setJustifyFull();";
    [self evaluatingJavaScript:trigger];
}

- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self evaluatingJavaScript:trigger];
}

- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self evaluatingJavaScript:trigger];
}

- (void)setSubscript {
    NSString *trigger = @"zss_editor.setSubscript();";
    [self evaluatingJavaScript:trigger];
}

- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self evaluatingJavaScript:trigger];
}

- (void)setSuperscript {
    NSString *trigger = @"zss_editor.setSuperscript();";
    [self evaluatingJavaScript:trigger];
}

- (void)setStrikethrough {
    NSString *trigger = @"zss_editor.setStrikeThrough();";
    [self evaluatingJavaScript:trigger];
}

- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self evaluatingJavaScript:trigger];
}

- (void)setOrderedList {
    NSString *trigger = @"zss_editor.setOrderedList();";
    [self evaluatingJavaScript:trigger];
}

- (void)setHR {
    NSString *trigger = @"zss_editor.setHorizontalRule();";
    [self evaluatingJavaScript:trigger];
}

- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self evaluatingJavaScript:trigger];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self evaluatingJavaScript:trigger];
}

- (void)heading1 {
    NSString *trigger = @"zss_editor.setHeading('h1');";
    [self evaluatingJavaScript:trigger];
}

- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self evaluatingJavaScript:trigger];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self evaluatingJavaScript:trigger];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
    [self evaluatingJavaScript:trigger];
}

- (void)heading5 {
    NSString *trigger = @"zss_editor.setHeading('h5');";
    [self evaluatingJavaScript:trigger];
}

- (void)heading6 {
    NSString *trigger = @"zss_editor.setHeading('h6');";
    [self evaluatingJavaScript:trigger];
}

- (void)paragraph {
    NSString *trigger = @"zss_editor.setParagraph();";
    [self evaluatingJavaScript:trigger];
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem {
    NSString *trigger = @"zss_editor.undo();";
    [self evaluatingJavaScript:trigger];
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem {
    NSString *trigger = @"zss_editor.redo();";
    [self evaluatingJavaScript:trigger];
}

- (void)insertLink {
    NSString *trigger = @"zss_editor.prepareInsert();";
    [self evaluatingJavaScript:trigger];
    
    if (_weakVC) {
        [self showInsertLinkDialog];
    }
}

- (void)insertLink:(NSString *)url title:(NSString *)title {
    if (url && url.length) {
        if (title && title.length) {
            // 去除首尾空格
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (title.length) {
                NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
                [self evaluatingJavaScript:trigger];
            }
        }
    }
}

- (void)showInsertLinkDialog {
    // Insert Title
    NSString *insertButtonTitle = NSLocalizedString(@"Insert", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"URL (required)", nil);
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Title", nil);
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.secureTextEntry = NO;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *linkURL = [alertController.textFields objectAtIndex:0];
        UITextField *title = [alertController.textFields objectAtIndex:1];
        
        [self insertLink:linkURL.text title:title.text];
    }]];
    [_weakVC presentViewController:alertController animated:YES completion:NULL];
}

- (void)insertImage {
    NSString *trigger = @"zss_editor.prepareInsert();";
    [self evaluatingJavaScript:trigger];
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.weakVC presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)insertImageFromDevice {
    NSString *trigger = @"zss_editor.prepareInsert();";
    [self evaluatingJavaScript:trigger];
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.weakVC presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)insertImageLocalPath:(NSString *)imgPath width:(CGFloat)width height:(CGFloat)height {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", imgPath, @"img"];
    [self evaluatingJavaScript:trigger];
}

- (void)addCustomToolbarItemWithButton:(UIButton *)button {
    
    if(self.customBarButtonItems == nil)
    {
        self.customBarButtonItems = [NSMutableArray array];
    }
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.5f];
    [button setTitleColor:[self barButtonItemDefaultColor] forState:UIControlStateNormal];
    [button setTitleColor:[self barButtonItemSelectedDefaultColor] forState:UIControlStateHighlighted];
    
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithCustomView:button];
    
    [self.customBarButtonItems addObject:barButtonItem];
    
    [self buildToolbar];
}

- (void)addCustomToolbarItem:(ZSSBarButtonItem *)item {
    
    if(self.customZSSBarButtonItems == nil)
    {
        self.customZSSBarButtonItems = [NSMutableArray array];
    }
    [self.customZSSBarButtonItems addObject:item];
    
    [self buildToolbar];
}

- (void)updateToolBarWithButtonName:(NSString *)name {
    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];
    
    self.editorItemsEnabled = itemNames;
    
    // Highlight items
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if ([itemNames containsObject:item.label]) {
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }
}


#pragma mark - UITextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}


#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [[request URL] absoluteString];
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self finishLoad];
}

#pragma mark - WKWebViewDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self finishLoad];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // 判断是否是调用原生的
    if ([@"ConfigToolBar" isEqualToString:message.name]) {
        [self updateToolBarWithButtonName:message.body];
    }
}

- (void)finishLoad {
    self.editorLoaded = YES;
    
    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];
    
    if(self.placeholder) {
        [self setPlaceholderText];
    }
    
    if (self.shouldShowKeyboard) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self focusTextEditor];
        });
    }
}

#pragma mark - Keyboard status

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    // Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // User Info
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Keyboard Size
    //Checks if IOS8, gets correct keyboard height
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
            CGFloat width = CGRectGetWidth(self.bounds);
            CGFloat height = CGRectGetHeight(self.bounds);
            
            // Toolbar
            [self.toolbarHolder setFrame:CGRectMake(0, height-44-keyboardHeight, width, 44)];
            
            // Editor View
            CGRect rect = CGRectMake(0, 0, width, height-44-keyboardHeight);
            if (_editorView) {
                [self.editorView setFrame:rect];
                
                self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
                self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            } else if (_wkEditorView) {
                [self.wkEditorView setFrame:rect];
                
                self.wkEditorView.scrollView.contentInset = UIEdgeInsetsZero;
                self.wkEditorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            }
            
            // Source View
            self.sourceView.frame = rect;
            
            // 防止在最后一行输入时页面活蹦乱跳
            [self setFooterHeight:(keyboardHeight - 8)];
            [self setContentHeight:rect.size.height-8];
            
        } completion:nil];
        
    } else {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            
            CGFloat width = CGRectGetWidth(self.bounds);
            CGFloat height = CGRectGetHeight(self.bounds);
            
            // Toolbar
            [self.toolbarHolder setFrame:CGRectMake(0, height-44, width, 44)];
            
            // Editor View
            CGRect rect = CGRectMake(0, 0, width, height-44);
            if (_editorView) {
                [self.editorView setFrame:rect];
                
                self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
                self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            } else if (_wkEditorView) {
                [self.wkEditorView setFrame:rect];
                
                self.wkEditorView.scrollView.contentInset = UIEdgeInsetsZero;
                self.wkEditorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            }
            
            // Source View
            self.sourceView.frame = rect;
            
            [self setFooterHeight:0];
            [self setContentHeight:rect.size.height-8];
            
        } completion:^(BOOL finished) {
            if (_wkEditorView) {
                [self focusTextEditor];
            }
        }];
    }
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info{
    
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *)kUTTypeImage]){
        UIImage *Selectimage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (Selectimage.imageOrientation != UIImageOrientationUp){
            CGAffineTransform transform = CGAffineTransformIdentity;
            
            switch (Selectimage.imageOrientation) {
                case UIImageOrientationDown:
                case UIImageOrientationDownMirrored:
                    transform = CGAffineTransformTranslate(transform, Selectimage.size.width, Selectimage.size.height);
                    transform = CGAffineTransformRotate(transform, M_PI);
                    break;
                    
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                    transform = CGAffineTransformTranslate(transform, Selectimage.size.width, 0);
                    transform = CGAffineTransformRotate(transform, M_PI_2);
                    break;
                    
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, 0, Selectimage.size.height);
                    transform = CGAffineTransformRotate(transform, -M_PI_2);
                    break;
                default:
                    break;
            }
            
            switch (Selectimage.imageOrientation) {
                case UIImageOrientationUpMirrored:
                case UIImageOrientationDownMirrored:
                    transform = CGAffineTransformTranslate(transform, Selectimage.size.width, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
                    
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, Selectimage.size.height, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
                default:
                    break;
            }
            
            // Now we draw the underlying CGImage into a new context, applying the transform
            // calculated above.
            CGContextRef ctx = CGBitmapContextCreate(NULL, Selectimage.size.width, Selectimage.size.height,
                                                     CGImageGetBitsPerComponent(Selectimage.CGImage), 0,
                                                     CGImageGetColorSpace(Selectimage.CGImage),
                                                     CGImageGetBitmapInfo(Selectimage.CGImage));
            CGContextConcatCTM(ctx, transform);
            switch (Selectimage.imageOrientation) {
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    // Grr...
                    CGContextDrawImage(ctx, CGRectMake(0,0,Selectimage.size.height,Selectimage.size.width), Selectimage.CGImage);
                    break;
                    
                default:
                    CGContextDrawImage(ctx, CGRectMake(0,0,Selectimage.size.width,Selectimage.size.height), Selectimage.CGImage);
                    break;
            }
            // And now we just create a new UIImage from the drawing context
            CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
            Selectimage = [UIImage imageWithCGImage:cgimg];
            CGImageRelease(cgimg);
            CGContextRelease(ctx);
        }
        
        UIImage *SaveImage = Selectimage;
        
        //同比缩放,一律缩放到宽300一下
        float scale = SaveImage.size.width/SaveImage.size.height;
        if (SaveImage.size.width > 720) {
            float height = 720/scale;
            
            CGSize targetSize = CGSizeMake(720, height);
            UIGraphicsBeginImageContextWithOptions(targetSize, NO, scale);
            
            // 绘制改变大小的图片
            [SaveImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            // 从当前context中创建一个改变大小后的图片
            UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            // 使当前的context出堆栈
            UIGraphicsEndImageContext();
            
            SaveImage = scaledImage;
        }
        
        CGSize InsertImageSize;
        if (Selectimage.size.width > 300) {
            InsertImageSize.width = 300;
            InsertImageSize.height = 300/scale;
        }else{
            InsertImageSize.width = Selectimage.size.width;
            InsertImageSize.height = Selectimage.size.height;
        }
        
        NSData *imageData = UIImageJPEGRepresentation(SaveImage, 1);
        
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[self FindNowTimeYYYYMMDDHHmmssfff]];
        NSString *ImagePath = [self imagePathWithName:imageName];
        [imageData writeToFile:ImagePath atomically:YES];
        
        [self insertImageLocalPath:ImagePath width:InsertImageSize.width height:InsertImageSize.height];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        /*
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"格式错误"
                                                            message:@"不支持的格式"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertview show];
         */
    }
}

/**
 插入图片的路径

 @param imageName 图片保存名称
 @return 路径
 */
- (NSString *)imagePathWithName:(NSString *)imageName {
    // 将图片存储到Caches下
    NSString *EditorTempPath = [FLOUtil FilePathInCachesWithName:@"TextEditorResources"];
    [FLOUtil CreatFilePathInCaches:@"TextEditorResources"];
    
    return [EditorTempPath stringByAppendingPathComponent:imageName];
}

/**
 *  获得当前时间以"yyyyMMddHHmmssfff"返回字符串
 *
 *  @return "yyyyMMddHHmmssfff"字符串
 */
- (NSString *)FindNowTimeYYYYMMDDHHmmssfff{
    NSDate* nowDate = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyyMMddHHmmssfff"];
    [outputFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *datestring = [outputFormatter stringFromDate:nowDate];
    
    return datestring;
}

#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (void)tidyHTML:(NSString *)html completion:(void(^)(NSString *))completion {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        NSString *format = [NSString stringWithFormat:@"style_html(\"%@\");", html];
        
        if (_editorView) {
            NSString *result = [self.editorView stringByEvaluatingJavaScriptFromString:format];
            
            if (completion) {
                completion(result);
            }
        } else if (_wkEditorView) {
            [_wkEditorView evaluateJavaScript:format completionHandler:^(NSString * _Nullable jsResult, NSError * _Nullable error) {
                NSString *result = @"";
                if (jsResult && [jsResult isKindOfClass:[NSString class]] && jsResult.length) {
                    result = jsResult;
                }
                
                if (completion) {
                    completion(result);
                }
            }];
        }
    }
}


- (UIColor *)barButtonItemDefaultColor {
    
    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }
    
    return [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}


- (UIColor *)barButtonItemSelectedDefaultColor {
    
    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }
    
    return [UIColor blackColor];
}


- (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = result.stringByRemovingPercentEncoding;
    return result;
}

- (void)enableToolbarItems:(BOOL)enable {
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if (![item.label isEqualToString:@"source"]) {
            item.enabled = enable;
        }
    }
}

@end
