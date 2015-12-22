//
//  ProgrammingViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-18.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation

class ProgrammingViewController : UIViewController, AVAudioPlayerDelegate {
    @IBOutlet weak var textView: UITextView!
    
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func run(sender: AnyObject) {
        TBJavaScriptManger.sharedManger.reset(textView.text)
    }
}