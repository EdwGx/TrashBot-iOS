//
//  TBFileManger.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-24.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

protocol TBFileMangerDelegate {
    func fileManger(fileManger: TBFileManger, isReady: Bool)
}

class TBFileManger: NSObject {
    var fileDirectory: NSURL?
    var files: [TBFile]?
    var fileOfNames: [String:TBFile]?
    var fileSystemReady = false
    
    static let sharedManger = TBFileManger()
    
    let queue = NSOperationQueue()
    
    var delegate: TBFileMangerDelegate?
    
    override init() {
        super.init()
        
        queue.qualityOfService = .UserInitiated
        queue.name = "TBFileManger-Queue"
        queue.maxConcurrentOperationCount = 1
    }
    
    func setupFileSystem() {
        let setupOperation = TBFileSystemSetupOperation(aManger: self)
        setupOperation.completionBlock = { [weak self] () -> Void in
            self?.delegate?.fileManger(self!, isReady: self!.fileSystemReady)
        }
        queue.addOperation(setupOperation)
    }
    
    func deleteFile(file: TBFile, completionBlock: (success: Bool) -> Void) {
        queue.addOperationWithBlock { [weak self] () -> Void in
            let fileManger = NSFileManager.defaultManager()
            do {
                try fileManger.removeItemAtURL(file.url)
                self?.files?.removeAtIndex((self?.files?.indexOf({$0.name == file.name}))!)
                self?.fileOfNames?.removeValueForKey(file.name)
                completionBlock(success: true)
            } catch {
               completionBlock(success: false)
            }
            
        }
    }
    
    func saveFile(name: String, contents: String) {
        queue.addOperationWithBlock { [weak self] () -> Void in
            let newFile: Bool
            var file = self?.fileOfNames![name]
            if file != nil  {
                newFile = false
            } else {
                let url = (self?.fileDirectory!.URLByAppendingPathComponent("\(name).bot", isDirectory: false))!
                file = TBFile(name: name, url: url, modificationDate: NSDate())
                newFile = true
            }
            do {
                try NSString(string: contents).writeToURL(file!.url, atomically: true, encoding: NSUTF8StringEncoding)
                if newFile {
                    self?.fileOfNames![file!.name] = file!
                    self?.files!.insert(file!, atIndex: 0)
                } else {
                    self?.files?.removeAtIndex((self?.files?.indexOf({$0.name == file!.name}))!)
                    self?.files!.insert(file!, atIndex: 0)
                }
            } catch {
                return
            }
        }
    }
}

struct TBFile {
    let name: String
    let url: NSURL
    let modificationDate: NSDate
}

class TBFileSystemSetupOperation: NSOperation {
    weak var manger: TBFileManger?
    init(aManger: TBFileManger) {
        self.manger = aManger
        super.init()
    }
    
    override func main() {
        let fileManger = NSFileManager.defaultManager()
        let url = fileManger.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileDirectory = url.URLByAppendingPathComponent("Saved-Files", isDirectory: true)
        
        if !fileManger.fileExistsAtPath(fileDirectory.path!) {
            do {
                try fileManger.createDirectoryAtURL(fileDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("\(error)")
                return
            }
        }
        
        var fileURLs: [NSURL]
        do {
            fileURLs = try fileManger.contentsOfDirectoryAtURL(fileDirectory, includingPropertiesForKeys: [], options: [])
        } catch {
            NSLog("\(error)")
            return
        }
        
        var files = [TBFile]()
        var fileOfNames = [String:TBFile]()
        for fileURL in fileURLs {
            do {
                if fileURL.pathExtension == "bot" {
                    let modificationDate = try fileManger.attributesOfItemAtPath(fileURL.path!)[NSFileModificationDate] as! NSDate
                    let name = NSString(string: fileURL.lastPathComponent!).stringByDeletingPathExtension as String
                    let file = TBFile(name: name, url: fileURL, modificationDate: modificationDate)
                    files.append(file)
                    fileOfNames[name] = file
                }
            } catch {
                NSLog("\(error)")
            }
        }
        files.sortInPlace { (fileOne, fileTwo) -> Bool in
            fileOne.modificationDate.compare(fileTwo.modificationDate) == .OrderedDescending
        }
        
        manger?.files = files
        manger?.fileOfNames = fileOfNames
        manger?.fileDirectory = fileDirectory
        manger?.fileSystemReady = true
    }
}