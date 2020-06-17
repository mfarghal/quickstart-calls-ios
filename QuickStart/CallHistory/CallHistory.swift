//
//  CallHistory.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/05/14.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
import SendBirdCalls

struct CallHistory: Codable {
    let callTypeImageURL: String
    let remoteUserProfileURL: String?
    let remoteUserID: String
    let duration: String
    let endResult: String
    let startedAt: String
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/d HH:mm"
        return dateFormatter
    }
    
    static func fetchAll() -> [CallHistory] {
        return UserDefaults.standard.callHistories
    }
    
    init(callLog: DirectCallLog) {
        self.callTypeImageURL = callLog.isVideoCall ? callLog.myRole == .caller ? "iconCallVideoOutgoingFilled" : "iconCallVideoIncomingFilled" : callLog.myRole == .callee ? "iconCallVoiceOutgoingFilled" : "iconCallVoiceIncomingFilled"
        let remoteUser = callLog.myRole == .caller ? callLog.callee : callLog.caller
        self.remoteUserProfileURL = remoteUser?.profileURL
        self.remoteUserID = remoteUser?.userId ?? "Unknown"
        
        self.startedAt = CallHistory.dateFormatter.string(from: Date(timeIntervalSince1970: Double(callLog.startedAt) / 1000))
        self.duration = callLog.duration.timerText()
        self.endResult = callLog.endResult.rawValue
    }
}

extension CallHistory: Hashable, Comparable {
    static func < (lhs: CallHistory, rhs: CallHistory) -> Bool {
        return lhs.startedAt < rhs.startedAt
    }
}