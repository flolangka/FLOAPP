//
//  ActionViewController.m
//  FLOAction
//
//  Created by 沈敏 on 2016/12/18.
//  Copyright © 2016年 Flolangka. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [imageView setImage:image];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if(url) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"链接地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.text = [url absoluteString];
                        }];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[UIPasteboard generalPasteboard] setString:alertController.textFields[0].text];
                            [self performSelector:@selector(done) withObject:nil afterDelay:0.5];
                        }]];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {                            
                            [self performSelector:@selector(done) withObject:nil afterDelay:0.5];
                        }]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(NSString *string, NSError *error) {
                    if(string) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"FLOAPP" message:string preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [[UIPasteboard generalPasteboard] setString:string];
                            [self performSelector:@selector(done) withObject:nil afterDelay:0.5];
                        }]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
