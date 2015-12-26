//
//  RuntimeViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-21.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

class RuntimeViewController: UIViewController, TBJavaScriptMangerDelegate, TBBotDelegate {
    
    @IBOutlet weak var displayTextView: UITextView!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let manger = TBJavaScriptManger.sharedManger
        manger.delegate = self
        manger.authorizeScriptExcution()
        
        TBBot.sharedBot.delegate = self
        self.stopButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopJS(sender: AnyObject?){
        let manger = TBJavaScriptManger.sharedManger
        switch manger.state {
        case .Executing:
            TBJavaScriptManger.sharedManger.stopContext()
        case .Error:
            self.performSegueWithIdentifier("finishScript", sender: self)
        case .Idle:
            self.performSegueWithIdentifier("finishScript", sender: self)
        default:
            break
        }
        
    }
    
    func javaScriptManger(manger: TBJavaScriptManger, hasChangeTo state: TBJavaScriptMangerState) {
        appendTextToDisplay(state.description, tag: "JS")
        switch state {
        case .Idle:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.stopButton.setTitle("Done", forState: .Normal)
            }
        case .Executing:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.stopButton.enabled = true
            }
        case .Error:
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.stopButton.setTitle("Done", forState: .Normal)
            }
            let errorDescription = manger.errorDescription!
            appendTextToDisplay(errorDescription.description, tag: "Error-\(errorDescription.tag)")
        default:
            break
        }
    }
    
    func bot(bot: TBBot, directionHasChanged direction: TBMotionDirection) {
        appendTextToDisplay(direction.description, tag: "Motion")
    }
    
    func bot(bot: TBBot, print string: String) {
        appendTextToDisplay(string, tag: "Print")
    }
    
    func appendTextToDisplay(string: String, tag: String) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.displayTextView.text = self.displayTextView.text + "\n[\(tag)]\(string)"
            self.displayTextView.scrollRangeToVisible(NSMakeRange(self.displayTextView.text.characters.count - 2, 1))
        }
    }
}
