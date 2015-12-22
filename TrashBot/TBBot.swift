//
//  TBBot.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-21.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import Foundation

enum TBMotionDirection {
    case Stop
    case Forward
    case Backward
    case TurnLeft
    case TurnRight
}

class TBBot : NSObject {
    static let sharedBot = TBBot()
    var direction = TBMotionDirection.Stop
    
    override init() {
        super.init()
    }
    
    func display(string string: String){
        NSLog(string)
    }
}
