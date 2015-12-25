//
//  MainTableViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-25.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, TBFileMangerDelegate {
    var newFileName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        let manger = TBFileManger.sharedManger
        manger.delegate = self
        manger.setupFileSystem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fileManger(fileManger: TBFileManger, isReady: Bool) {
        if isReady {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TBFileManger.sharedManger.fileSystemReady {
            return TBFileManger.sharedManger.files!.count
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = TBFileManger.sharedManger.files![indexPath.row].name

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            TBFileManger.sharedManger.deleteFile(TBFileManger.sharedManger.files![indexPath.row],
                completionBlock: { (success) -> Void in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        })
                    }
                }
            )
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoadSavedFile" {
            let programmingViewController = segue.destinationViewController as! ProgrammingViewController
            let file = TBFileManger.sharedManger.files![tableView.indexPathForSelectedRow!.row]
            programmingViewController.title = file.name
            do {
                programmingViewController.script = try NSString(contentsOfFile: file.url.path!, encoding: NSUTF8StringEncoding) as String
            } catch {
                programmingViewController.textView.text = "\(error)"
            }
        } else if segue.identifier == "NewFile" {
            let programmingViewController = segue.destinationViewController as! ProgrammingViewController
            programmingViewController.title = newFileName
            programmingViewController.script = "function setup() {\n    //code before loops\n}\n\nfunction loop() {\n    //main loop\n\n    //return false to end the program\n    return false;\n}"
        }
    }
    
    @IBAction func newFile(sender: AnyObject) {
        let alert = UIAlertController(title: "New File", message: nil, preferredStyle: .Alert)
        weak var weakAlert = alert
        
        let create = UIAlertAction(title: "Create", style: .Default) { (action) -> Void in
            self.newFileName = weakAlert!.textFields!.first?.text
            self.performSegueWithIdentifier("NewFile", sender: self)
        }
        alert.addAction(create)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
