//
//  UIView+Layout.swift
//  SpotifyTurtorial
//
//  Created by 竹ノ内愛斗 on 2020/03/14.
//  Copyright © 2020 竹ノ内愛斗. All rights reserved.
//

import UIKit

extension UIView {
    
    func layout(_ modifier: (inout CGRect)->Void) {
        var f = bounds
        
        modifier(&f)
        f = f.integral
        
        if frame != f {
            frame = f
        }
    }
    
    func floatLayout(_ modifier: (inout CGRect)->Void) {
        var f = bounds
        
        modifier(&f)
        
        if frame != f {
            frame = f
        }
    }
    
    func sizeJustFit() -> CGSize {
        return sizeThatFits(.zero)
    }
}
