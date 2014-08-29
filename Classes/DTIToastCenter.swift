//
//  DTIAlertCenter.swift
//  tapkuclone
//
//  Created by dtissera on 22/08/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

import UIKit

private let _defaultCenter = DTIToastCenter()

@objc
class DTIToastCenter: NSObject {
    /** DTIToast inner class */
    class DTIToast {
        var message: String?
        var image: UIImage?
        
        init (message: String!) {
            self.message = message
        }
        
        init (image: UIImage!) {
            self.image = image
        }
        
        init (message: String!, image: UIImage!) {
            self.message = message
            self.image = image
        }
    }
    
    /** private members */
    private var toasts = [DTIToast]()
    private var active = false
    private var toastView = DTIToastView()
    private var registered = false
    private var keyboardFrame: CGRect = CGRectZero

    /** consts */
    private let toastDefaultDelay = NSTimeInterval(1.4)
    
    /** overrides */
    override init () {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationWillChange:", name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /** private methods */
    private func showToasts() {
        if (!registered) {
            fatalError("DTIToastCenter ~ you need to call register method in your AppDelegate:didFinishLaunchingWithOptions method !")
        }

        if (self.toasts.count == 0) {
            self.active = false
            return
        }
        self.active = true
        
        // Reset toastView
        self.toastView.alpha = 0
        self.toastView.transform = CGAffineTransformIdentity
        
        // Extract top al top
        let toast = self.toasts[0]

        // init toastView
        let windowFrame = self.toastFrameFromScreenBounds(orientation: nil).swipFromOrientation(self.currentOrientation())
        self.toastView.message = toast.message
        self.toastView.image = toast.image
        self.toastView.adjustSize(maxFrame: windowFrame)

        self.toasts.removeAtIndex(0)
        UIApplication.sharedApplication().keyWindow.addSubview(self.toastView)
        
        self.toastView.transform = CGAffineTransformConcat(self.rotationFromOrientation(), CGAffineTransformMakeScale(2.0, 2.0))
        self.toastView.center = self.availableScreenFrame(orientation: nil).centerIntegral()

        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.toastView.alpha = 1;
            self.toastView.transform = CGAffineTransformConcat(self.rotationFromOrientation(), CGAffineTransformMakeScale(1.0, 1.0))
        }) { (Bool) -> Void in
            var delay: NSTimeInterval = self.toastDefaultDelay
            if (toast.message != nil) {
                var words = toast.message!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                // avg person reads 200 words per minute - max 3s
                delay = NSTimeInterval(min(max(self.toastDefaultDelay, Double(words.count)*60.0/200.0), 5.0))
            }

            UIView.animateWithDuration(0.25, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.toastView.transform = self.rotationFromOrientation()
                self.toastView.alpha = 0;
            }, completion: { (Bool) -> Void in
                self.toastView.removeFromSuperview()
                self.showToasts()
            })
        }
    }

    private func make(#message: String?, image: UIImage?) {
        let t = DTIToast(message: message, image: image)
        
        toasts.append(t)
        if (!self.active) {
            self.showToasts()
        }
    }


    /** public methods */
    class var defaultCenter: DTIToastCenter {
        return _defaultCenter
    }
    
    func registerCenter() {
        // force register toast center to oberserve keyboard
        self.registered = true
    }

    func makeText(text: String?, image: UIImage?) {
        make(message: text, image: nil)
    }

    func makeText(text: String) {
        make(message: text, image: nil)
    }

    func makeImage(image: UIImage) {
        make(message: nil, image: image)
    }

}

/**
  * System events // notifications
  */
extension DTIToastCenter {
    func keyboardWillAppear(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary;
        let value: NSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue
        self.keyboardFrame = value.CGRectValue()
        let windowFrame = self.toastFrameFromScreenBounds(orientation: nil).swipFromOrientation(self.currentOrientation())
        
        var center = self.availableScreenFrame(orientation: nil).centerIntegral()

        UIView.beginAnimations(nil, context: nil)
        self.toastView.adjustSize(maxFrame: windowFrame)
        self.toastView.center = center
        UIView.commitAnimations()
    }
    
    func keyboardWillDisappear(notification: NSNotification) {
        self.keyboardFrame = CGRectZero
        let windowFrame = self.toastFrameFromScreenBounds(orientation: nil).swipFromOrientation(self.currentOrientation())

        var center = self.availableScreenFrame(orientation: nil).centerIntegral()

        UIView.beginAnimations(nil, context: nil)
        self.toastView.adjustSize(maxFrame: windowFrame)
        self.toastView.center = center
        UIView.commitAnimations()
    }
    
    func orientationWillChange(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary;
        let value: NSNumber = userInfo[UIApplicationStatusBarOrientationUserInfoKey] as NSNumber
        
        let orientation: UIInterfaceOrientation = UIInterfaceOrientation.fromRaw(Int(value.intValue))!
        let windowFrame = self.toastFrameFromScreenBounds(orientation: orientation).swipFromOrientation(orientation)

        var center = self.availableScreenFrame(orientation: orientation).swipFromOrientation(orientation).centerIntegral()
        self.toastView.adjustSize(maxFrame: windowFrame)

        UIView.beginAnimations(nil, context: nil)
        self.toastView.transform = self.rotationFromOrientation(orientation)
        self.toastView.center = center
        UIView.commitAnimations()
    }
}

/**
 * Utilities extension
 */
extension DTIToastCenter {
    /**
      * current orientation of device
      */
    private func currentOrientation() -> UIInterfaceOrientation {
        return UIApplication.sharedApplication().statusBarOrientation
    }

    /**
      * calculate available frame depending of keyboard visibility
      */
    private func availableScreenFrame(#orientation: UIInterfaceOrientation?) -> CGRect {
        let o: UIInterfaceOrientation = orientation == nil ? self.currentOrientation() : orientation!
        // println("self.keyboardFrame: \(self.keyboardFrame)")
        var res:CGRect = self.keyboardFrame == CGRectZero ? UIScreen.mainScreen().bounds : self.subtractKeyBoardFrameToWindowFrame(windowFrame: UIScreen.mainScreen().bounds, keyboardFrame: self.keyboardFrame)
        if (orientation != nil) {
            // we are in rotating event - keyboard is always hidden
            res = UIScreen.mainScreen().bounds.swipFromOrientation(o)
        }
        return res
    }

    /**
      * calculate toast frame from screen bounds
      */
    private func toastFrameFromScreenBounds(#orientation: UIInterfaceOrientation?) -> CGRect {
        let o: UIInterfaceOrientation = orientation == nil ? self.currentOrientation() : orientation!
        var available: CGRect = self.availableScreenFrame(orientation: orientation)
        // println("available: \(available)")

        let minScreenValue: CGFloat = min(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        var f: CGRect = CGRect(x: available.origin.x, y: available.origin.y, width: minScreenValue, height: available.height)
        if (UIInterfaceOrientationIsLandscape(o)) {
            f = CGRect(x: available.origin.x, y: available.origin.y, width: available.width , height: minScreenValue)
        }

        // println("f:\(f)")
        return f
    }

    /**
      * return transformed point depending of orientation parameter
      */
    private func pointFromOrientation(orientation: UIInterfaceOrientation, point: CGPoint) -> CGPoint {
        var p: CGPoint = point
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            p = CGPoint(x: point.y, y: point.x)
        }
        return p
    }

    /**
      * return center of screen depending of orientation parameter
      */
    private func centerOfScreen(orientation: UIInterfaceOrientation) -> CGPoint {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let rect: CGRect = UIScreen.mainScreen().bounds.swipFromOrientation(orientation)
        let res = self.pointFromOrientation(orientation, point:CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect)))

        return res
    }

    /**
      * return center of screen depending of current orientation
      */
    private func centerOfScreen() -> CGPoint {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation

        return centerOfScreen(orientation)
    }

    /**
      * return an affine transformation depending of orientation
      */
    private func rotationFromOrientation(orientation: UIInterfaceOrientation) -> CGAffineTransform {
        var angle: CGFloat = 0.0;

        if (orientation == UIInterfaceOrientation.LandscapeLeft ) {
            angle = CGFloat(-M_PI_2)
        }
        else if (orientation == UIInterfaceOrientation.LandscapeRight ) {
            angle = CGFloat(M_PI_2)
        }
        else if (orientation == UIInterfaceOrientation.PortraitUpsideDown) {
            angle = CGFloat(M_PI)
        }
        return CGAffineTransformMakeRotation(angle)
    }

    /**
      * return an affine transformation depending of orientation
      */
    private func rotationFromOrientation() -> CGAffineTransform {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation

        return self.rotationFromOrientation(orientation)
    }

    private func subtractKeyBoardFrameToWindowFrame(#windowFrame: CGRect, keyboardFrame: CGRect) -> CGRect {
        var kf = keyboardFrame
        if (!CGPointEqualToPoint(CGPointZero, kf.origin)) {
            if (kf.origin.x > 0) {
                kf.size.width = kf.origin.x
            }
            if (kf.origin.y > 0) {
                kf.size.height = kf.origin.y
            }
            kf.origin = CGPointZero;
        }
        else {
            kf.origin.x = abs(kf.size.width - windowFrame.size.width);
            kf.origin.y = abs(kf.size.height - windowFrame.size.height);
            
            
            if (kf.origin.x > 0){
                let temp: CGFloat = kf.origin.x;
                kf.origin.x = kf.size.width;
                kf.size.width = temp;
            }
            else if (kf.origin.y > 0){
                let temp: CGFloat = kf.origin.y;
                kf.origin.y = kf.size.height;
                kf.size.height = temp;
            }
        }
        return CGRectIntersection(windowFrame, kf);
    }
    

}

