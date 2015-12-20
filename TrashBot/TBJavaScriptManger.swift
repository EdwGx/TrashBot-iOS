//
//  TBJavaScript.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-20.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import Foundation
import JavaScriptCore

class TBJavaScriptManger{
    let context = JSContext()
    let queue = NSOperationQueue()
    
    init(script: String){
        queue.qualityOfService = .UserInitiated
        queue.name = "TBJavaScriptManger-Queue"
        
        queue.addOperationWithBlock { () -> Void in
            let jsPrint: @convention(block) String -> Void = { output in
                print(output)
            }
            
            self.context.setObject(unsafeBitCast(jsPrint, AnyObject.self), forKeyedSubscript: "print")
            
            self.context.evaluateScript(script)
        }
    }
}