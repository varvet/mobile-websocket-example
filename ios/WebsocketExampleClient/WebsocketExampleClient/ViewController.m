//
//  ViewController.m
//  WebsocketExampleClient
//
//  Created by Elabs Developer on 2/10/14.
//  Copyright (c) 2014 Elabs. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController {
  SRWebSocket *webSocket;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self connectWebSocket];

  UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
  [self.messagesTextView addGestureRecognizer:tgr];

  [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    UIViewAnimationOptions options = curve << 16;

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
      CGRect frame = self.containerView.frame;
      frame.origin.y = CGRectGetMinY(endFrame) - CGRectGetHeight(self.containerView.frame);
      self.containerView.frame = frame;

      frame = self.messagesTextView.frame;
      frame.size.height = CGRectGetMinY(self.containerView.frame) - CGRectGetMinY(frame);
      self.messagesTextView.frame = frame;
    } completion:nil];
  }];
}

- (void)hideKeyboard {
  [self.view endEditing:YES];
}


#pragma mark - Connection

- (void)connectWebSocket {
  webSocket.delegate = nil;
  webSocket = nil;

  NSString *urlString = @"ws://localhost:8080";
  SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
  newWebSocket.delegate = self;

  [newWebSocket open];
}


#pragma mark - SRWebSocket delegate

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
  webSocket = newWebSocket;
  [webSocket send:[NSString stringWithFormat:@"Hello from %@", [UIDevice currentDevice].name]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  self.messagesTextView.text = [NSString stringWithFormat:@"%@\n%@", self.messagesTextView.text, message];
}

- (IBAction)sendMessage:(id)sender {
  [webSocket send:self.messageTextField.text];
  self.messageTextField.text = nil;
}


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self sendMessage:nil];
  return YES;
}

@end
