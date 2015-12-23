//
//  ColorInfoView.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-22.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

class ColorInfoView: UIVisualEffectView {
    init(frame: CGRect) {
        let effect = UIBlurEffect(style: .Dark)
        super.init(effect: effect)
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 44)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
