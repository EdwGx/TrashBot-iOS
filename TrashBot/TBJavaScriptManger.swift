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
    init(script: String){
        let jsPrint: @convention(block) String -> Void = { output in
            print(output)
        }
        context.setObject(unsafeBitCast(jsPrint, AnyObject.self), forKeyedSubscript: "print")
        
        context.evaluateScript(script)
    }
}