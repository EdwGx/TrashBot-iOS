//
//  ProgrammingViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-18.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation

class ProgrammingViewController : UIViewController, AVAudioPlayerDelegate, CodeSuggestionViewDelegate {
    @IBOutlet weak var textView: UITextView!
    
    var audioPlayer : AVAudioPlayer?
    var script: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let accessoryView = CodeSuggestionView(frame: CGRectMake(0,0,self.view.frame.width,0))
        accessoryView.delegate = self
        textView.inputAccessoryView = accessoryView
        textView.text = script
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification){
        let userInfo = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = UIViewAnimationCurve(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue)!
        let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: frame.size.height, right: 0)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
        
        UIView.commitAnimations()
    }
    
    @IBAction func run(sender: AnyObject) {
        TBJavaScriptManger.sharedManger.loadScript(textView.text)
        performSegueWithIdentifier("runScript", sender: nil)
    }
    
    @IBAction func unwindToProgramming(segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func saveFile(send: AnyObject) {
        TBFileManger.sharedManger.saveFile(self.title!, contents: textView.text)
    }
    
    func editingEndInCodeSuggestionView(view: CodeSuggestionView) {
        textView.resignFirstResponder()
    }
}