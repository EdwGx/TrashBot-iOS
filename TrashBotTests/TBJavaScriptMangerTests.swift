//
//  TBJavaScriptMangerTests.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-21.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import XCTest

class TBJavaScriptMangerTests: XCTestCase {
    
    let manger = TBJavaScriptManger()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStandaloneLoopInjection() {
        var injectedScript : String
        
        injectedScript = try! manger.injectStopGuard("while(1==1);")
        XCTAssertEqual(injectedScript, "while(1==1){\(manger.stopGuardSubscript)();}")
        
        injectedScript = try! manger.injectStopGuard("for(var i = 0;i < 1;i++);")
        XCTAssertEqual(injectedScript, "for(var i = 0;i < 1;i++){\(manger.stopGuardSubscript)();}")
    }
    
    func testOneLineLoopInjection() {
        var injectedScript : String
        
        injectedScript = try! manger.injectStopGuard("while(1==1) console.log('');")
        XCTAssertEqual(injectedScript, "while(1==1){\(manger.stopGuardSubscript)(); console.log('')}")
        
        injectedScript = try! manger.injectStopGuard("for(var i = 0;i < 1;i++) console.log('');")
        XCTAssertEqual(injectedScript, "for(var i = 0;i < 1;i++){\(manger.stopGuardSubscript)(); console.log('')}")
    }
    
    func testComplexLoopInjection() {
        var injectedScript : String
        
        injectedScript = try! manger.injectStopGuard("while(1==1){console.log('');1+1;}")
        XCTAssertEqual(injectedScript, "while(1==1){\(manger.stopGuardSubscript)();console.log('');1+1;}")
        
        injectedScript = try! manger.injectStopGuard("for(var i = 0;i < 1;i++){console.log('');1+1;}")
        XCTAssertEqual(injectedScript, "for(var i = 0;i < 1;i++){\(manger.stopGuardSubscript)();console.log('');1+1;}")
    }
    
    func testFalsePositive() {
        var injectedScript : String
        
        injectedScript = try! manger.injectStopGuard("while")
        XCTAssertEqual(injectedScript, "while")
        
        injectedScript = try! manger.injectStopGuard("for")
        XCTAssertEqual(injectedScript, "for")
        
        injectedScript = try! manger.injectStopGuard("awhile()")
        XCTAssertEqual(injectedScript, "awhile()")
        
        injectedScript = try! manger.injectStopGuard("forever()")
        XCTAssertEqual(injectedScript, "forever()")
        
    }
    
    func testFalsePositiveInString() {
        var injectedScript : String
        
        injectedScript = try! manger.injectStopGuard("'while(1+1);'")
        XCTAssertEqual(injectedScript, "while(1+1);")
        
        injectedScript = try! manger.injectStopGuard("\"while(1+1);\"")
        XCTAssertEqual(injectedScript, "\"while(1+1);\"")
    }
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
