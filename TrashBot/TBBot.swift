//
//  TBBot.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-21.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import Foundation
import AVFoundation

enum TBMotionDirection: Int, CustomStringConvertible {
    case Stop
    case Forward
    case Backward
    case TurnLeft
    case TurnRight
    
    var description: String {
        switch self {
        case .Stop: return "Stop";
        case .Forward: return "Forward";
        case .Backward: return "Backward";
        case .TurnLeft: return "TurnLeft";
        case .TurnRight: return "TurnRight";
        }
    }
}

protocol TBBotDelegate {
    func bot(bot: TBBot, print string: String)
    func bot(bot: TBBot, directionHasChanged direction: TBMotionDirection )
}

class TBBot : NSObject {
    static let sharedBot = TBBot()
    private var _direction = TBMotionDirection.Stop
    
    private var _audioPlayers = [TBMotionDirection:AVAudioPlayer]()
    private var _currentAudioPlayer: AVAudioPlayer?
    
    var delegate: TBBotDelegate?
    
    override init() {
        super.init()
        /*
        do {
            _audioPlayers[.Forward] = try audioPlayerForFile("DualX-12")
            _audioPlayers[.Backward] = try audioPlayerForFile("DualX-21")
            _audioPlayers[.TurnLeft] = try audioPlayerForFile("DualX-11")
            _audioPlayers[.TurnRight] = try audioPlayerForFile("DualX-22")
        } catch {
            NSLog("Error: \(error)")
        }
        */
    }
    
    private func audioPlayerForFile(filename: String) throws  -> AVAudioPlayer {
        let audioPlayer = try AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource(filename, withExtension: "aiff")!)
        audioPlayer.numberOfLoops = -1
        return audioPlayer
    }
    
    func update(direction direction: TBMotionDirection) {
        guard direction != _direction else { return }
        delegate?.bot(self, directionHasChanged: _direction)
        /*
        if _currentAudioPlayer != nil {
            _currentAudioPlayer!.stop()
            _currentAudioPlayer!.currentTime = 0
            _currentAudioPlayer = nil
        }
        
        if direction != .Stop {
            _currentAudioPlayer = _audioPlayers[direction]
            _currentAudioPlayer!.play()
        }
        */
    }
    
    func display(string string: String){
        delegate?.bot(self, print: string)
        NSLog(string)
    }
}
