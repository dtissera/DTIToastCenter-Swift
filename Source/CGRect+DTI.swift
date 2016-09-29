//
//  UIView+DTI.swift
//  tapkuclone
//
//  Created by dtissera on 23/08/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

import UIKit

extension CGRect {
    func swip() -> CGRect {
        var f: CGRect = self
        f.origin = CGPoint(x: f.origin.y, y: f.origin.x)
        f.size = CGSize(width: f.size.height, height: f.size.width)
        return f
    }
    
    func swipFromOrientation(_ orientation: UIInterfaceOrientation) -> CGRect {
        var f: CGRect = self
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            f = f.swip()
        }
        return f
    }

    func centerIntegral() -> CGPoint {

        return CGPoint(x: Int(self.origin.x.isInfinite ? CGFloat(Int.max) : self.midX),
                       y: Int(self.origin.y.isInfinite ? CGFloat(Int.max) : self.midY))
    }

    func centerInRect(_ rect: CGRect) -> CGRect {
        let center = self.centerIntegral()

        let origin = CGPoint(x: center.x-rect.width/2.0, y: center.y-rect.height/2.0)

        return CGRect(origin: origin, size: self.size)
    }

    func centerXInRect(_ rect: CGRect) -> CGRect {
        let center = self.centerIntegral()
        let origin = CGPoint(x: center.x-rect.width/2.0, y: self.origin.y)

        return CGRect(origin: origin, size: self.size)
    }

}
