//
//  Room.swift
//  PPRoom
//
//  房间模型
//

import Foundation

class Room {
    let id: String
    let name: String
    let owner: User
    
    // 状态
    private(set) var state: RoomState = .preparing
    private(set) var stateObject: RoomStateProtocol
    
    // 麦位
    private(set) var microphones: [Microphone] = []
    
    // 当前拍卖
    var currentItem: AuctionItem?
    var rules: AuctionRules = .default
    var currentBid: Bid?
    var bidHistory: [Bid] = []
    
    // 参与者
    private(set) var participants: [User] = []
    
    // 消息
    private(set) var messages: [Message] = []
    
    // 创建时间
    let createdAt: Date
    
    init(id: String, name: String, owner: User, microphoneCount: Int = 6) {
        self.id = id
        self.name = name
        self.owner = owner
        self.createdAt = Date()
        
        // 初始化状态
        self.stateObject = PreparingState()
        
        // 初始化麦位
        for i in 1...microphoneCount {
            let mic = Microphone(seatNumber: i)
            if i == 1 {
                // 1号麦位给房主
                mic.status = .occupied
                mic.user = owner
                mic.isLocked = true
                owner.isOnMicrophone = true
            }
            microphones.append(mic)
        }
        
        // 房主加入参与者
        participants.append(owner)
        
        // 添加欢迎消息
        addSystemMessage("欢迎来到\(name)！")
    }
    
    // MARK: - 状态管理
    
    func changeState(to newState: RoomState) {
        self.state = newState
        
        // 更新状态对象
        switch newState {
        case .preparing:
            self.stateObject = PreparingState()
        case .listing:
            self.stateObject = ListingState()
        case .auctioning:
            self.stateObject = AuctioningState()
        case .closed:
            self.stateObject = ClosedState()
        }
        
        addSystemMessage("房间状态变更为：\(newState.displayName)")
    }
    
    // MARK: - 用户管理
    
    func addUser(_ user: User) {
        guard !participants.contains(where: { $0.id == user.id }) else { return }
        participants.append(user)
        addSystemMessage("\(user.nickname) 加入了房间")
    }
    
    func removeUser(_ userId: String) {
        participants.removeAll { $0.id == userId }
    }
    
    func getUser(byId userId: String) -> User? {
        return participants.first { $0.id == userId }
    }
    
    // MARK: - 麦位管理
    
    func getAvailableMicrophone() -> Microphone? {
        return microphones.first { $0.status == .empty && !$0.isLocked }
    }
    
    func assignMicrophone(to user: User, seatNumber: Int) -> Bool {
        guard let mic = microphones.first(where: { $0.seatNumber == seatNumber }),
              mic.status == .empty || mic.status == .locked && !mic.isLocked else {
            return false
        }
        
        mic.status = .occupied
        mic.user = user
        user.isOnMicrophone = true
        
        addSystemMessage("\(user.nickname) 上麦了（\(seatNumber)号麦位）")
        return true
    }
    
    func removeMicrophone(userId: String) {
        guard let mic = microphones.first(where: { $0.user?.id == userId }) else {
            return
        }
        
        let username = mic.user?.nickname ?? "用户"
        mic.user?.isOnMicrophone = false
        mic.user = nil
        mic.status = .empty
        
        addSystemMessage("\(username) 下麦了")
    }
    
    // MARK: - 拍卖管理
    
    func setAuctionItem(_ item: AuctionItem, rules: AuctionRules) {
        self.currentItem = item
        self.rules = rules
        addSystemMessage("📦 新的拍卖品：\(item.name)")
    }
    
    func addBid(_ bid: Bid) {
        self.currentBid = bid
        self.bidHistory.append(bid)
        
        let message = Message(
            id: UUID().uuidString,
            userId: bid.bidderId,
            username: bid.bidderName,
            content: bid.displayText,
            type: .bid,
            timestamp: bid.timestamp
        )
        messages.append(message)
    }
    
    // MARK: - 消息管理
    
    func addMessage(from user: User, content: String, type: Message.MessageType = .text) {
        let message = Message(
            id: UUID().uuidString,
            userId: user.id,
            username: user.nickname,
            content: content,
            type: type,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    func addSystemMessage(_ content: String) {
        let message = Message(
            id: UUID().uuidString,
            userId: "system",
            username: "系统",
            content: content,
            type: .system,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    // MARK: - 便捷属性
    
    var currentPrice: Decimal {
        return currentBid?.price ?? rules.startPrice
    }
    
    var currentLeader: String? {
        return currentBid?.bidderName
    }
    
    var onlineCount: Int {
        return participants.count
    }
    
    var currentAuctioneer: User? {
        return participants.first { $0.role == .auctioneer && $0.isOnMicrophone }
    }
}

