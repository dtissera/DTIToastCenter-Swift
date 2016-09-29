//
//  DTIAlertView.swift
//  tapkuclone
//
//  Created by dtissera on 22/08/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

import UIKit

class DTIToastView: UIView {
    /** consts */
    fileprivate let boxPadding: CGFloat = 10.0
    fileprivate let horizontalPadding: CGFloat = 10.0
    fileprivate let verticalPadding: CGFloat = 5.0
    fileprivate let imageSpacer: CGFloat = 7.0
    
    fileprivate var label: UILabel = UILabel()
    fileprivate var imageView: UIImageView = UIImageView()
    fileprivate var maxFrameSize: CGSize = CGSize(width: 100.0, height: 100.0)
    
    var image: UIImage? {
        didSet {
            self.imageView.image = nil;
            if (image != nil) {
                self.imageView.image = self.image!
            }
            //self.adjustSize()
        }
    }
    
    var message: String? {
        didSet {
            self.label.text = self.message == nil ? "" : self.message!
            //self.adjustSize()
        }
    }

    init() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        super.init(frame: rect)
        
        self.layer.cornerRadius = 6.0
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        self.label.font = UIFont.boldSystemFont(ofSize: 14.0)
        self.label.textColor = UIColor.white
        self.label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.label.numberOfLines = 0
        self.label.textAlignment = NSTextAlignment.center

        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView.tintColor = UIColor.white
        self.addSubview(self.label)
        self.addSubview(self.imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        // calculate image size
        let imageSize = self.imageSize()
        
        var rect = CGRect.zero
        rect.size = imageSize
        
        self.imageView.frame = CGRect(origin: CGPoint(x: self.bounds.centerXInRect(rect).origin.x, y: self.verticalPadding), size: imageSize).integral

        // calculate text size
        let textSize = self.textSize(imageSize: imageSize)
        rect = CGRect.zero
        rect.size = self.textSize(imageSize: imageSize)
        
        var imageAdjustment: CGFloat = 0.0
        if (imageSize != CGSize.zero) {
            imageAdjustment += self.imageSpacer + imageSize.height
        }
        self.label.frame = CGRect(origin: CGPoint(x: self.bounds.centerXInRect(rect).origin.x, y: self.verticalPadding+imageAdjustment), size: textSize).integral
    }
    
    func maxViewSize() -> CGSize {
        // max box size
        return CGRect(origin: CGPoint.zero, size: self.maxFrameSize).insetBy(dx: boxPadding + self.horizontalPadding,
            dy: boxPadding + self.verticalPadding).size
    }
    
    func imageSize() -> CGSize {
        var imageSize = CGSize.zero
        if (self.image != nil) {
            imageSize = self.image!.size
            let maxViewSize = self.maxViewSize()
            if (imageSize.width > maxViewSize.width) {
                imageSize.width = CGFloat(Int(maxViewSize.width))
            }
            if (imageSize.height > maxViewSize.height / 2) {
                imageSize.height = CGFloat(Int(maxViewSize.height / 2))
            }
        }
        return imageSize
    }
    
    func textSize(imageSize: CGSize) -> CGSize {
        var messageSize = CGSize.zero
        if (self.message != nil) {
            let maxViewSize = self.maxViewSize()
            let maxTextSize = CGRect(origin: CGPoint.zero, size: maxViewSize).insetBy(dx: 0.0,
                dy: imageSize == CGSize.zero ? 0.0 : (imageSize.height+self.imageSpacer)/2.0).size
            
            messageSize = self.label.sizeThatFits(maxTextSize)
            if (messageSize.height > maxTextSize.height) {
                messageSize.height = maxTextSize.height
            }
        }
        
        return messageSize
    }
    
    func adjustSize(maxFrame: CGRect) {
        self.imageView.isHidden = self.image == nil
        self.label.isHidden = self.message == nil
        self.maxFrameSize = maxFrame.size

        // calculate image size
        let imageSize = self.imageSize()
        
        var rect = CGRect.zero
        rect.size = imageSize
        
        // let imageViewFrame = CGRect(origin: CGPoint(x: 0.0, y: self.verticalPadding), size: imageSize).integerRect

        // calculate text size
        let textSize = self.textSize(imageSize: imageSize)
        rect = CGRect.zero
        rect.size = self.textSize(imageSize: imageSize)
        
        var imageAdjustment: CGFloat = 0.0
        if (imageSize != CGSize.zero) {
            imageAdjustment += self.imageSpacer + imageSize.height
        }
        // let textFrame = CGRect(origin: CGPoint(x: 0.0, y: self.verticalPadding+imageAdjustment), size: textSize).integerRect

        // calculate view size
        self.bounds = CGRect(x: 0.0, y: 0.0,
            width: max(imageSize.width, textSize.width)+2*self.horizontalPadding,
            height: textSize.height+imageAdjustment+2*self.verticalPadding)
        
        self.setNeedsLayout()
    }
}
