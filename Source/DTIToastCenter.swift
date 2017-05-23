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
open class DTIToastCenter: NSObject {
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
    fileprivate var toasts = [DTIToast]()
    fileprivate var active = false
    fileprivate var toastView = DTIToastView()
    fileprivate var registered = false
    fileprivate var keyboardFrame: CGRect = CGRect.zero

    /** consts */
    fileprivate let toastDefaultDelay = TimeInterval(1.4)
    
    /** overrides */
    override init () {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(DTIToastCenter.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DTIToastCenter.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DTIToastCenter.orientationWillChange(_:)), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /** private methods */
    fileprivate func showToasts() {
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
        self.toastView.transform = CGAffineTransform.identity
        
        // Extract top al top
        let toast = self.toasts[0]

        // init toastView
        var windowFrame = self.availableScreenFrame(orientation: nil)
        if (self.iosVersionLessThan8()) {
            windowFrame = windowFrame.swipFromOrientation(self.currentOrientation())
        }
        
        self.toastView.message = toast.message
        self.toastView.image = toast.image
        self.toastView.adjustSize(maxFrame: windowFrame)

        self.toasts.remove(at: 0)
        UIApplication.shared.keyWindow!.addSubview(self.toastView)

        var transform: CGAffineTransform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        if (self.iosVersionLessThan8()) {
            transform = self.rotationFromOrientation().concatenating(transform)
        }
        self.toastView.transform = transform
        self.toastView.center = self.availableScreenFrame(orientation: nil).centerIntegral()

        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.toastView.alpha = 1;
            var transform: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            if (self.iosVersionLessThan8()) {
                transform = self.rotationFromOrientation().concatenating(transform)
            }
            self.toastView.transform = transform
        }, completion: { (Bool) -> Void in
            var delay: TimeInterval = self.toastDefaultDelay
            if (toast.message != nil) {
                let words = toast.message!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                // avg person reads 200 words per minute - max 3s
                delay = TimeInterval(min(max(self.toastDefaultDelay, Double(words.count)*60.0/200.0), 5.0))
            }

            UIView.animate(withDuration: 0.25, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                if (self.iosVersionLessThan8()) {
                    self.toastView.transform = self.rotationFromOrientation()
                }
                self.toastView.alpha = 0;
            }, completion: { (Bool) -> Void in
                self.toastView.removeFromSuperview()
                self.showToasts()
            })
        }) 
    }

    fileprivate func make(message: String?, image: UIImage?) {
        let t = DTIToast(message: message, image: image)
        
        toasts.append(t)
        if (!self.active) {
            self.showToasts()
        }
    }


    /** public methods */
    open class var defaultCenter: DTIToastCenter {
        return _defaultCenter
    }
    
    open func registerCenter() {
        // force register toast center to oberserve keyboard
        self.registered = true
    }

    open func makeText(_ text: String?, image: UIImage?) {
        make(message: text, image: image)
    }

    open func makeText(_ text: String) {
        make(message: text, image: nil)
    }

    open func makeImage(_ image: UIImage) {
        make(message: nil, image: image)
    }

}

/**
  * System events // notifications
  */
extension DTIToastCenter {
    func keyboardWillAppear(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary;
        let value: NSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        self.keyboardFrame = value.cgRectValue
        
        var windowFrame = self.availableScreenFrame(orientation: nil)
        if (self.iosVersionLessThan8()) {
            windowFrame = windowFrame.swipFromOrientation(self.currentOrientation())
        }
        
        let center = self.availableScreenFrame(orientation: nil).centerIntegral()

        UIView.beginAnimations(nil, context: nil)
        self.toastView.adjustSize(maxFrame: windowFrame)
        self.toastView.center = center
        UIView.commitAnimations()
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        self.keyboardFrame = CGRect.zero
        
        var windowFrame = self.availableScreenFrame(orientation: nil)
        if (self.iosVersionLessThan8()) {
            windowFrame = windowFrame.swipFromOrientation(self.currentOrientation())
        }

        let center = self.availableScreenFrame(orientation: nil).centerIntegral()

        UIView.beginAnimations(nil, context: nil)
        self.toastView.adjustSize(maxFrame: windowFrame)
        self.toastView.center = center
        UIView.commitAnimations()
    }
    
    func orientationWillChange(_ notification: Notification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary;
        let value: NSNumber = userInfo[UIApplicationStatusBarOrientationUserInfoKey] as! NSNumber
        
        let orientation: UIInterfaceOrientation = UIInterfaceOrientation(rawValue: Int(value.int32Value))!

        var toastFrame = self.availableScreenFrame(orientation: orientation)
        var center = toastFrame.centerIntegral() // .swipFromOrientation(orientation)
        if (self.iosVersionLessThan8()) {
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                toastFrame = toastFrame.swip()
            }
            center = UIScreen.main.bounds.centerIntegral()
        }

        self.toastView.adjustSize(maxFrame: toastFrame)

        UIView.beginAnimations(nil, context: nil)
        self.toastView.transform = CGAffineTransform.identity
        if (self.iosVersionLessThan8()) {
            self.toastView.transform = self.rotationFromOrientation(orientation)
        }
        self.toastView.center = center
        UIView.commitAnimations()
    }
}

/**
 * Utilities extension
 */
extension DTIToastCenter {
    /**
    * ios version < ios8
    */
    fileprivate func iosVersionLessThan8() -> Bool {
        let os_version: String = UIDevice.current.systemVersion;
        return os_version.doubleValue() < 8.0
    }

    /**
      * current orientation of device
      */
    fileprivate func currentOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    /**
      * calculate available frame depending of keyboard visibility
      */
    fileprivate func availableScreenFrame(orientation: UIInterfaceOrientation?) -> CGRect {
        var res:CGRect = self.keyboardFrame == CGRect.zero ? UIScreen.main.bounds : self.subtractKeyBoardFrameToWindowFrame(windowFrame: UIScreen.main.bounds, keyboardFrame: self.keyboardFrame)
        if (orientation != nil) {
            // we are in rotating event - keyboard is always hidden
            res = UIScreen.main.bounds.swip()
        }
        return res
    }

    /**
      * return an affine transformation depending of orientation
      */
    fileprivate func rotationFromOrientation(_ orientation: UIInterfaceOrientation) -> CGAffineTransform {
        var angle: CGFloat = 0.0;

        if (orientation == UIInterfaceOrientation.landscapeLeft ) {
            angle = CGFloat(-(Double.pi/2))
        }
        else if (orientation == UIInterfaceOrientation.landscapeRight ) {
            angle = CGFloat(Double.pi/2)
        }
        else if (orientation == UIInterfaceOrientation.portraitUpsideDown) {
            angle = CGFloat(Double.pi/2)
        }
        return CGAffineTransform(rotationAngle: angle)
    }

    /**
      * return an affine transformation depending of orientation
      */
    fileprivate func rotationFromOrientation() -> CGAffineTransform {
        let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation

        return self.rotationFromOrientation(orientation)
    }

    fileprivate func subtractKeyBoardFrameToWindowFrame(windowFrame: CGRect, keyboardFrame: CGRect) -> CGRect {
        var kf = keyboardFrame
        if (!CGPoint.zero.equalTo(kf.origin)) {
            if (kf.origin.x > 0) {
                kf.size.width = kf.origin.x
            }
            if (kf.origin.y > 0) {
                kf.size.height = kf.origin.y
            }
            kf.origin = CGPoint.zero;
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
        return windowFrame.intersection(kf);
    }
    

}

