//
//  RuntimeViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-21.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

class RuntimeViewController: UIViewController, TBJavaScriptMangerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        TBJavaScriptManger.sharedManger.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopJS(sender: AnyObject?){
        TBJavaScriptManger.sharedManger.stopContext()
    }
    
    func javaScriptManger(manger: TBJavaScriptManger, hasChangTo state: TBJavaScriptMangerState) {
        NSLog("JSManger Change:\(state)")
    }
}
