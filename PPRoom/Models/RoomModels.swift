//
//  RoomModels.swift
//  PPRoom
//
//  核心模型定义
//

import Foundation

// MARK: - 用户角色
enum UserRole: String, CaseIterable {
    case host           // 房主/主持人
    case auctioneer     // 拍卖人
    case bidder         // 竞拍者
    case viewer         // 观众
    
    var displayName: String {
        switch self {
        case .host: return "房主"
        case .auctioneer: return "拍卖人"
        case .bidder: return "竞拍者"
        case .viewer: return "观众"
        }
    }
}

// MARK: - 房间操作
enum RoomAction: String, CaseIterable {
    // 房间管理
    case createRoom = "创建房间"
    case closeRoom = "关闭房间"
    
    // 麦位管理
    case applyForMicrophone = "申请上麦"
    case acceptMicrophoneRequest = "同意上麦"
    case kickFromMicrophone = "踢下麦"
    
    // 拍卖流程
    case uploadItem = "上传物品"
    case setAuctionRules = "设置规则"
    case startAuction = "开始拍卖"
    case placeBid = "出价"
    case forceEndAuction = "强制结束"
    
    // 交互
    case sendMessage = "发消息"
    case sendVoice = "发语音"
}

// MARK: - 房间状态
enum RoomState: String {
    case preparing      // 准备阶段
    case listing        // 上拍
    case auctioning     // 拍卖中
    case closed         // 定拍
    
    var displayName: String {
        switch self {
        case .preparing: return "准备中"
        case .listing: return "上拍中"
        case .auctioning: return "拍卖中"
        case .closed: return "已定拍"
        }
    }
    
    var color: String {
        switch self {
        case .preparing: return "🟡"
        case .listing: return "🟠"
        case .auctioning: return "🔴"
        case .closed: return "🟢"
        }
    }
}

// MARK: - 用户模型
class User {
    let id: String
    let nickname: String
    var role: UserRole
    var isOnMicrophone: Bool = false
    var isMuted: Bool = false
    
    init(id: String, nickname: String, role: UserRole) {
        self.id = id
        self.nickname = nickname
        self.role = role
    }
    
    var isCurrentAuctioneer: Bool {
        return role == .auctioneer
    }
}

// MARK: - 拍卖物品
struct AuctionItem {
    let id: String
    let name: String
    let description: String
    let auctioneerId: String
    let auctioneerName: String
    
    var displayInfo: String {
        return "\(name) - \(description)"
    }
}

// MARK: - 拍卖规则
struct AuctionRules {
    let startPrice: Decimal       // 起拍价
    let incrementStep: Decimal    // 加价幅度
    let countdownSeconds: Int     // 倒计时秒数
    
    static var `default`: AuctionRules {
        return AuctionRules(
            startPrice: 100,
            incrementStep: 10,
            countdownSeconds: 30
        )
    }
}

// MARK: - 出价记录
struct Bid {
    let id: String
    let price: Decimal
    let bidderId: String
    let bidderName: String
    let timestamp: Date
    
    var displayText: String {
        return "\(bidderName) 出价 ¥\(price)"
    }
}

// MARK: - 麦位模型
class Microphone {
    let seatNumber: Int
    var status: MicrophoneStatus
    var user: User?
    var isLocked: Bool
    
    init(seatNumber: Int, status: MicrophoneStatus = .empty, user: User? = nil, isLocked: Bool = false) {
        self.seatNumber = seatNumber
        self.status = status
        self.user = user
        self.isLocked = isLocked
    }
    
    enum MicrophoneStatus {
        case empty      // 空闲
        case occupied   // 占用
        case locked     // 锁定
    }
}

// MARK: - 消息模型
struct Message {
    let id: String
    let userId: String
    let username: String
    let content: String
    let type: MessageType
    let timestamp: Date
    
    enum MessageType {
        case text       // 文字消息
        case bid        // 出价消息
        case system     // 系统消息
    }
    
    var displayText: String {
        switch type {
        case .text:
            return "[\(username)]: \(content)"
        case .bid:
            return "💰 \(content)"
        case .system:
            return "📢 \(content)"
        }
    }
}

