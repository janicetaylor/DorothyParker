//
//  AlgonquinViewController.m
//  DorothyParker
//
//  Created by Janice Garingo on 11/21/13.
//  Copyright (c) 2013 Janice Garingo. All rights reserved.
//

#import "AlgonquinViewController.h"

@interface AlgonquinViewController ()

@end

@implementation AlgonquinViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadJson];
    [self styleView];
}


- (void)styleView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = kUIColorMedGrey;
    
    self.navigationItem.title = @"The Algonquin Round Table";
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      kNovellaFont, NSFontAttributeName,
                                                                      [UIColor whiteColor],NSForegroundColorAttributeName,
                                                                      nil]];
    
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
}


- (void)loadJson
{
    NSURL *url = [NSURL URLWithString:kAlgonquinURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *dictionary = (NSDictionary *) JSON;
        
        NSArray *data = [dictionary objectForKey:@"data"];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *dataLoaded = [obj objectForKey:@"algonquin"];
            NSString *thumbnail = [NSString stringWithFormat:@"%@%@", kBaseImageURL, [obj objectForKey:@"thumbnail"]];
            NSString *thumbnailRetina = [NSString stringWithFormat:@"%@%@", kBaseImageURL, [obj objectForKey:@"thumbnail-retina"]];
            
            NSString *path = [[NSBundle mainBundle] pathForResource: @"webView" ofType: @"html"];
            NSError *error;
            NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            html = [html stringByReplacingOccurrencesOfString:@"<!-- body -->" withString:dataLoaded];
            
            if([UIScreen isRetina]) {
                html = [html stringByReplacingOccurrencesOfString:@"<!-- image -->" withString:thumbnailRetina];
            }
            else {
                html = [html stringByReplacingOccurrencesOfString:@"<!-- image -->" withString:thumbnail];
            }
            
            [self.webView loadHTMLString:html baseURL:nil];
            
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error : %@", [error localizedDescription]);
    }];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    [operation start];
    
}

@end
