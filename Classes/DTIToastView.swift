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
    private let boxPadding: CGFloat = 10.0
    private let horizontalPadding: CGFloat = 10.0
    private let verticalPadding: CGFloat = 5.0
    private let imageSpacer: CGFloat = 7.0
    
    private var label: UILabel = UILabel()
    private var imageView: UIImageView = UIImageView()
    private var maxFrameSize: CGSize = CGSize(width: 100.0, height: 100.0)
    
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

    override init() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        super.init(frame: rect)
        
        self.layer.cornerRadius = 6.0
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        self.label.font = UIFont.boldSystemFontOfSize(14.0)
        self.label.textColor = UIColor.whiteColor()
        self.label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.label.numberOfLines = 0
        self.label.textAlignment = NSTextAlignment.Center

        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.label)
        self.addSubview(self.imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        // calculate image size
        let imageSize = self.imageSize()
        
        var rect = CGRectZero
        rect.size = imageSize
        
        self.imageView.frame = CGRect(origin: CGPoint(x: self.bounds.centerXInRect(rect).origin.x, y: self.verticalPadding), size: imageSize).integerRect

        // calculate text size
        let textSize = self.textSize(imageSize: imageSize)
        rect = CGRectZero
        rect.size = self.textSize(imageSize: imageSize)
        
        var imageAdjustment: CGFloat = 0.0
        if (imageSize != CGSizeZero) {
            imageAdjustment += self.imageSpacer + imageSize.height
        }
        self.label.frame = CGRect(origin: CGPoint(x: self.bounds.centerXInRect(rect).origin.x, y: self.verticalPadding+imageAdjustment), size: textSize).integerRect
    }
    
    func maxViewSize() -> CGSize {
        // max box size
        return CGRectInset(CGRect(origin: CGPointZero, size: self.maxFrameSize),
            boxPadding + self.horizontalPadding,
            boxPadding + self.verticalPadding).size
    }
    
    func imageSize() -> CGSize {
        var imageSize = CGSizeZero
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
    
    func textSize(#imageSize: CGSize) -> CGSize {
        var messageSize = CGSizeZero
        if (self.message != nil) {
            let maxViewSize = self.maxViewSize()
            let maxTextSize = CGRectInset(CGRect(origin: CGPointZero, size: maxViewSize),
                0.0,
                imageSize == CGSizeZero ? 0.0 : (imageSize.height+self.imageSpacer)/2.0).size
            
            messageSize = self.label.sizeThatFits(maxTextSize)
            if (messageSize.height > maxTextSize.height) {
                messageSize.height = maxTextSize.height
            }
        }
        
        return messageSize
    }
    
    func adjustSize(#maxFrame: CGRect) {
        self.imageView.hidden = self.image == nil
        self.label.hidden = self.message == nil
        self.maxFrameSize = maxFrame.size

        // calculate image size
        var imageSize = self.imageSize()
        
        var rect = CGRectZero
        rect.size = imageSize
        
        let imageViewFrame = CGRect(origin: CGPoint(x: 0.0, y: self.verticalPadding), size: imageSize).integerRect

        // calculate text size
        let textSize = self.textSize(imageSize: imageSize)
        rect = CGRectZero
        rect.size = self.textSize(imageSize: imageSize)
        
        var imageAdjustment: CGFloat = 0.0
        if (imageSize != CGSizeZero) {
            imageAdjustment += self.imageSpacer + imageSize.height
        }
        let textFrame = CGRect(origin: CGPoint(x: 0.0, y: self.verticalPadding+imageAdjustment), size: textSize).integerRect

        // calculate view size
        self.bounds = CGRect(x: 0.0, y: 0.0,
            width: max(imageSize.width, textSize.width)+2*self.horizontalPadding,
            height: textSize.height+imageAdjustment+2*self.verticalPadding)
        
        self.setNeedsLayout()
    }
}
