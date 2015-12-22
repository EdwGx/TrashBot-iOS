//
//  TBJavaScript.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-20.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import Foundation
import JavaScriptCore

enum TBJavaScriptMangerState {
    case Idle
    case Excuting
    case Canceling
}

protocol TBJavaScriptMangerDelegate {
    func javaScriptManger(manger: TBJavaScriptManger, hasChangTo state: TBJavaScriptMangerState)
}

class TBJavaScriptManger : NSObject {
    static let sharedManger = TBJavaScriptManger()
    var javaScriptContext : JSContext?
    let queue = NSOperationQueue()
    var state = TBJavaScriptMangerState.Idle {
        didSet {
            delegate?.javaScriptManger(self, hasChangTo: state)
        }
    }
    
    let isCancelingSubscript = "_isCanceling"
    let stopGuardSubscript = "_stopGuard"
    
    var stopGuardFunction : String
    var waitFunction : String
    
    var delegate : TBJavaScriptMangerDelegate?
    
    override init() {
        waitFunction = "function wait(time){\(stopGuardSubscript)();while(time > 0.25){time -= 0.25;_wait(0.25);\(stopGuardSubscript)();} _wait(time);\(stopGuardSubscript)();}"
        stopGuardFunction = "function \(stopGuardSubscript)(){if(\(isCancelingSubscript)()){throw \"SystemExit\"}}"
        
        super.init()
        queue.qualityOfService = .UserInitiated
        queue.name = "TBJavaScriptManger-Queue"
        queue.maxConcurrentOperationCount = 1
    }
    
    func reset(script: String) {
        state = .Excuting
        
        javaScriptContext = JSContext()
        javaScriptContext!.exceptionHandler = { context, exception in
            NSLog("JS Error:\(exception)")
            TBJavaScriptManger.sharedManger.state = .Idle
        }
        
        queue.addOperationWithBlock { () -> Void in
            let manger = TBJavaScriptManger.sharedManger
            do {
                let processedScript = try manger.injectStopGuard(script)
                    
                let jsPrint: @convention(block) String -> Void = { output in
                    TBBot.sharedBot.display(string: output)
                }
                manger.javaScriptContext!.setObject(unsafeBitCast(jsPrint, AnyObject.self), forKeyedSubscript: "print")
                
                let jsWait: @convention(block) Double -> Void = { ti in
                    NSThread.sleepForTimeInterval(ti)
                }
                manger.javaScriptContext!.setObject(unsafeBitCast(jsWait, AnyObject.self), forKeyedSubscript: "_wait")
                
                let jsIsCanceling: @convention(block) Void -> Bool = {
                    return (TBJavaScriptManger.sharedManger.state == .Canceling)
                }
                manger.javaScriptContext!.setObject(unsafeBitCast(jsIsCanceling, AnyObject.self), forKeyedSubscript: manger.isCancelingSubscript)
                
                manger.javaScriptContext!.evaluateScript(manger.waitFunction)
                manger.javaScriptContext!.evaluateScript(manger.stopGuardFunction)
                manger.javaScriptContext!.evaluateScript(processedScript)
            } catch StopGuardInjectionError.InvalidSyntax {
                NSLog("StopGuard:Invalid Syntax")
            } catch StopGuardInjectionError.Unknown {
                NSLog("StopGuard:Unknown")
            } catch {
                NSLog("Unknown")
            }
        }
    }
    
    enum StopGuardInjectionError : ErrorType {
        case InvalidSyntax
        case Unknown
    }
    
    private struct InjectionFlag {
        var wrap : Bool
        
        var index : Int
        var endIndex : Int
    }
    
    func injectStopGuard(rawScript: String) throws -> String {
        let script = NSMutableString(string: "JS \(rawScript)")
        let scanner = NSScanner(string: script as String)
        
        var insertFlags : [InjectionFlag] = try scanStopGuardInjection("while", script: script, scanner: scanner)
        insertFlags.appendContentsOf(try scanStopGuardInjection("for", script: script, scanner: scanner))
        
        insertFlags.sortInPlace { (a, b) -> Bool in
            a.index > b.index
        }
        for flag in insertFlags{
            if flag.wrap {
                script.replaceCharactersInRange(NSMakeRange(flag.endIndex, 1), withString: "}")
                script.insertString("{\(stopGuardSubscript)();", atIndex: flag.index)
            } else {
                script.insertString("\(stopGuardSubscript)();", atIndex: flag.index)
            }
        }
        
        script.replaceCharactersInRange(NSMakeRange(0, 3), withString: "")
        
        return script as String
    }
    
    private func scanStopGuardInjection(loopName: String, script: NSMutableString, scanner: NSScanner) throws -> [InjectionFlag] {
        scanner.scanLocation = 0
        var insertFlags = [InjectionFlag]()
        let charSet = NSCharacterSet(charactersInString: " ;")
        let loopNameLength = loopName.characters.count
        let invWhitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet().invertedSet
        
        while( scanner.scanUpToString(loopName, intoString: nil) && !scanner.atEnd ) {
            
            if !charSet.characterIsMember(script.characterAtIndex(scanner.scanLocation - 1)){
                continue
            }
            var beforeBracket : NSString?
            scanner.scanLocation += loopNameLength
            if scanner.atEnd {
                continue
            }
            if script.substringWithRange(NSMakeRange(scanner.scanLocation, 1)) != "("{
                if scanner.scanUpToString("(", intoString: &beforeBracket) {
                    if beforeBracket?.rangeOfCharacterFromSet(invWhitespaceSet).location != NSNotFound {
                        continue
                    }
                } else {
                    throw StopGuardInjectionError.InvalidSyntax
                }
            }
            
            var netLeftBrackCount = 0
            while (netLeftBrackCount != 1 && scanner.scanUpToString(")", intoString: &beforeBracket)) {
                netLeftBrackCount += beforeBracket!.componentsSeparatedByString("(").count
                netLeftBrackCount -= beforeBracket!.componentsSeparatedByString(")").count
            }
            let lastBracketLocation = scanner.scanLocation
            if netLeftBrackCount == 1 {
                if(scanner.scanUpToCharactersFromSet(NSCharacterSet(charactersInString: "{;"), intoString: nil)){
                    switch script.substringWithRange(NSMakeRange(scanner.scanLocation, 1)) {
                    case "{":
                        insertFlags.append(InjectionFlag(wrap: false, index: scanner.scanLocation + 1, endIndex: 0))
                    case ";":
                        insertFlags.append(InjectionFlag(wrap: true, index: lastBracketLocation + 1, endIndex: scanner.scanLocation))
                    default:
                        throw StopGuardInjectionError.Unknown
                    }
                } else {
                    throw StopGuardInjectionError.InvalidSyntax
                }
            } else {
                throw StopGuardInjectionError.InvalidSyntax
            }
        }
        return insertFlags
    }
    
    func stopContext(){
        state = .Canceling
    }
}