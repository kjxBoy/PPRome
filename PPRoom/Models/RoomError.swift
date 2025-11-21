//
//  RoomError.swift
//  PPRoom
//
//  自定义错误类型
//

import Foundation

enum RoomError: Error {
    case permissionDenied(String)
    case operationFailed(String)
    case invalidState(String)
    case invalidInput(String)
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied(let message):
            return message
        case .operationFailed(let message):
            return message
        case .invalidState(let message):
            return message
        case .invalidInput(let message):
            return message
        }
    }
}

