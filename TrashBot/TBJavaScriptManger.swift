//
//  TBJavaScript.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-20.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import Foundation
import JavaScriptCore

enum TBJavaScriptMangerState: CustomStringConvertible {
    case Idle
    case LoadingScript
    case Ready
    case Executing
    case Canceling
    case Error
    
    var description: String {
        switch self {
        case .Idle: return "Idle";
        case .LoadingScript: return "LoadingScript";
        case .Ready: return "Ready";
        case .Executing: return "Executing";
        case .Canceling: return "Canceling";
        case .Error: return "Error";
        }
    }
}

protocol TBJavaScriptMangerDelegate {
    func javaScriptManger(manger: TBJavaScriptManger, hasChangeTo state: TBJavaScriptMangerState)
}

class TBJavaScriptManger : NSObject {
    static let sharedManger = TBJavaScriptManger()
    var javaScriptContext : JSContext?
    let queue = NSOperationQueue()
    var state = TBJavaScriptMangerState.Idle {
        didSet {
            delegate?.javaScriptManger(self, hasChangeTo: state)
        }
    }
    
    var errorDescription: TBJavaScriptErrorDescription?
    
    let isCancelingSubscript = "_isCanceling"
    let stopGuardSubscript = "_stopGuard"
    
    var stopGuardFunction : String
    var waitFunction : String
    
    var jsSetupFunctionAvailable = false
    var jsLoopFunctionAvailable = false
    
    var rawScript: String?
    var processedScript: String?
    
    var delegate : TBJavaScriptMangerDelegate?
    
    override init() {
        waitFunction = "function wait(time){\(stopGuardSubscript)();while(time > 0.25){time -= 0.25;_wait(0.25);\(stopGuardSubscript)();} _wait(time);\(stopGuardSubscript)();}"
        stopGuardFunction = "function \(stopGuardSubscript)(){if(\(isCancelingSubscript)()){throw \"SystemExit\"}}"
        
        super.init()
        queue.qualityOfService = .UserInitiated
        queue.name = "TBJavaScriptManger-Queue"
        queue.maxConcurrentOperationCount = 1
    }
    
    func loadScript(script: String) {
        if state == .Idle {
            state = .LoadingScript
            javaScriptContext = nil
            rawScript = script
            processedScript = nil
            queue.addOperation(TBJavaScriptLoadOperation())
        } else {
            fatalError("JS only can be reseted when manger is idle")
        }
    }
    
    func excuteScript() {
        if state == .Ready {
            queue.addOperation(TBJavaScriptSetupOperation())
        } else {
            fatalError("JS only can be excuted when manger is ready")
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
    
    func injectStopGuard() throws {
        guard rawScript != nil else { fatalError("rawScript can't be nil") }
        
        let script = NSMutableString(string: "JS \(rawScript!)")
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
        processedScript = script as String
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
    
    func handleException(exception: JSValue) {
        NSLog("JS Error:\(exception)")
        errorDescription = TBJavaScriptErrorDescription(description: "\(exception)", tag: "Runtime")
        state = .Error
    }
}

struct TBJavaScriptErrorDescription {
    var description: String
    var tag: String
}

class TBJavaScriptLoopOperation: NSOperation {
    override func main () {
        let manger = TBJavaScriptManger.sharedManger
        if manger.state == .Executing {
            let result = manger.javaScriptContext!.evaluateScript("loop")
            if result.isBoolean && !result.toBool() {
                manger.state = .Idle
            } else {
                manger.queue.addOperation(TBJavaScriptLoopOperation())
            }
        }
    }
}

class TBJavaScriptLoadOperation: NSOperation {
    override func main () {
        let manger = TBJavaScriptManger.sharedManger
        do {
            try manger.injectStopGuard()
        } catch TBJavaScriptManger.StopGuardInjectionError.InvalidSyntax {
            manger.errorDescription = TBJavaScriptErrorDescription(description: "Invalid Syntax", tag: "Complie")
            manger.state = .Error
            return
        } catch TBJavaScriptManger.StopGuardInjectionError.Unknown {
            manger.errorDescription = TBJavaScriptErrorDescription(description: "Injection Error", tag: "Complie")
            manger.state = .Error
            return
        } catch {
            manger.errorDescription = TBJavaScriptErrorDescription(description: "Unknown Error: \(error)", tag: "Complie")
            manger.state = .Error
            return
        }
        
        let context = JSContext()
        
        context.exceptionHandler = { context, exception in
            TBJavaScriptManger.sharedManger.handleException(exception)
        }
        
        //Internal - _wait()
        let jsWait: @convention(block) Double -> Void = { ti in
            NSThread.sleepForTimeInterval(ti)
        }
        context.setObject(unsafeBitCast(jsWait, AnyObject.self), forKeyedSubscript: "_wait")
        
        //Internal - _isCanceling()
        let jsIsCanceling: @convention(block) Void -> Bool = {
            return (TBJavaScriptManger.sharedManger.state == TBJavaScriptMangerState.Canceling)
        }
        context.setObject(unsafeBitCast(jsIsCanceling, AnyObject.self), forKeyedSubscript: manger.isCancelingSubscript)
        
        //Public - print()
        let jsPrint: @convention(block) String -> Void = { output in
            TBBot.sharedBot.display(string: output)
        }
        context.setObject(unsafeBitCast(jsPrint, AnyObject.self), forKeyedSubscript: "print")
        
        //Public - moveForward()
        let moveForward: @convention(block) Void -> Void = {
            TBBot.sharedBot.update(direction: .Forward)
        }
        context.setObject(unsafeBitCast(moveForward, AnyObject.self), forKeyedSubscript: "moveForward")
        
        //Public - moveBackward()
        let moveBackward: @convention(block) Void -> Void = {
            TBBot.sharedBot.update(direction: .Backward)
        }
        context.setObject(unsafeBitCast(moveBackward, AnyObject.self), forKeyedSubscript: "moveBackward")
        
        //Public - turnLeft()
        let turnLeft: @convention(block) Void -> Void = {
            TBBot.sharedBot.update(direction: .TurnLeft)
        }
        context.setObject(unsafeBitCast(turnLeft, AnyObject.self), forKeyedSubscript: "turnLeft")
        
        //Public - turnRight()
        let turnRight: @convention(block) Void -> Void = {
            TBBot.sharedBot.update(direction: .TurnRight)
        }
        context.setObject(unsafeBitCast(turnRight, AnyObject.self), forKeyedSubscript: "turnRight")
        
        context.evaluateScript(manger.waitFunction)
        context.evaluateScript(manger.stopGuardFunction)
        
        manger.javaScriptContext = context
        
        manger.state = .Ready
    }
}

class TBJavaScriptSetupOperation: NSOperation {
    override func main () {
        let manger = TBJavaScriptManger.sharedManger
        manger.state = .Executing
        manger.javaScriptContext!.evaluateScript(manger.processedScript!)
        
        manger.jsSetupFunctionAvailable = manger.javaScriptContext!.evaluateScript("typeof setup == 'function'").toBool()
        manger.jsLoopFunctionAvailable = manger.javaScriptContext!.evaluateScript("typeof loop == 'function'").toBool()
        
        if manger.jsSetupFunctionAvailable && manger.state == .Executing {
            manger.javaScriptContext!.evaluateScript("setup()")
            if manger.jsLoopFunctionAvailable {
                manger.queue.addOperation(TBJavaScriptLoopOperation())
            }
        } else {
            manger.state = .Idle
        }
    }
}