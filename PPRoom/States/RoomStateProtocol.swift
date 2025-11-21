//
//  RoomStateProtocol.swift
//  PPRoom
//
//  房间状态协议和状态实现
//

import Foundation

// MARK: - 状态协议
protocol RoomStateProtocol {
    var stateName: RoomState { get }
    
    // 状态转换
    func startAuction(room: Room) -> Bool
    func endAuction(room: Room) -> Bool
    
    // 业务操作
    func placeBid(room: Room, user: User, amount: Decimal) -> Bool
    func uploadItem(room: Room, item: AuctionItem, rules: AuctionRules) -> Bool
    
    // 获取状态描述
    func getStateDescription() -> String
}

// MARK: - 准备阶段状态
class PreparingState: RoomStateProtocol {
    var stateName: RoomState { return .preparing }
    
    func startAuction(room: Room) -> Bool {
        // 检查是否有拍卖物品
        guard room.currentItem != nil else {
            print("⚠️ 没有拍卖物品，无法开始")
            return false
        }
        
        // 状态转换：准备阶段 -> 上拍
        room.changeState(to: .listing)
        
        // 开始上拍倒计时（这里简化，直接进入拍卖中）
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            room.changeState(to: .auctioning)
        }
        
        return true
    }
    
    func endAuction(room: Room) -> Bool {
        print("⚠️ 拍卖还未开始")
        return false
    }
    
    func placeBid(room: Room, user: User, amount: Decimal) -> Bool {
        print("⚠️ 拍卖还未开始，无法出价")
        return false
    }
    
    func uploadItem(room: Room, item: AuctionItem, rules: AuctionRules) -> Bool {
        room.setAuctionItem(item, rules: rules)
        return true
    }
    
    func getStateDescription() -> String {
        return "准备阶段：拍卖人可以上传物品并设置规则"
    }
}

// MARK: - 上拍状态
class ListingState: RoomStateProtocol {
    var stateName: RoomState { return .listing }
    
    func startAuction(room: Room) -> Bool {
        // 房主可以提前开始
        room.changeState(to: .auctioning)
        return true
    }
    
    func endAuction(room: Room) -> Bool {
        print("⚠️ 拍卖还未正式开始")
        return false
    }
    
    func placeBid(room: Room, user: User, amount: Decimal) -> Bool {
        print("⚠️ 拍卖还未正式开始，无法出价")
        return false
    }
    
    func uploadItem(room: Room, item: AuctionItem, rules: AuctionRules) -> Bool {
        print("⚠️ 上拍阶段无法修改物品")
        return false
    }
    
    func getStateDescription() -> String {
        return "上拍中：展示拍卖物品，倒计时后自动开始"
    }
}

// MARK: - 拍卖中状态
class AuctioningState: RoomStateProtocol {
    var stateName: RoomState { return .auctioning }
    
    func startAuction(room: Room) -> Bool {
        print("⚠️ 拍卖已经在进行中")
        return false
    }
    
    func endAuction(room: Room) -> Bool {
        // 结束拍卖，进入定拍状态
        room.changeState(to: .closed)
        
        if let winner = room.currentBid {
            room.addSystemMessage("🎉 成交！恭喜 \(winner.bidderName) 以 ¥\(winner.price) 拍得")
        } else {
            room.addSystemMessage("流拍：没有人出价")
        }
        
        return true
    }
    
    func placeBid(room: Room, user: User, amount: Decimal) -> Bool {
        // 创建出价记录
        let bid = Bid(
            id: UUID().uuidString,
            price: amount,
            bidderId: user.id,
            bidderName: user.nickname,
            timestamp: Date()
        )
        
        // 记录出价
        room.addBid(bid)
        
        print("💰 \(user.nickname) 出价 ¥\(amount)")
        return true
    }
    
    func uploadItem(room: Room, item: AuctionItem, rules: AuctionRules) -> Bool {
        print("⚠️ 拍卖进行中，无法修改物品")
        return false
    }
    
    func getStateDescription() -> String {
        return "拍卖中：竞拍者可以出价，倒计时结束后定拍"
    }
}

// MARK: - 定拍状态
class ClosedState: RoomStateProtocol {
    var stateName: RoomState { return .closed }
    
    func startAuction(room: Room) -> Bool {
        // 可以开启下一轮拍卖
        room.changeState(to: .preparing)
        room.currentItem = nil
        room.currentBid = nil
        room.addSystemMessage("🔄 准备下一轮拍卖")
        return true
    }
    
    func endAuction(room: Room) -> Bool {
        print("⚠️ 拍卖已经结束")
        return false
    }
    
    func placeBid(room: Room, user: User, amount: Decimal) -> Bool {
        print("⚠️ 拍卖已经结束，无法出价")
        return false
    }
    
    func uploadItem(room: Room, item: AuctionItem, rules: AuctionRules) -> Bool {
        print("⚠️ 拍卖已结束，请开启下一轮")
        return false
    }
    
    func getStateDescription() -> String {
        return "已定拍：拍卖结束，可以开启下一轮"
    }
}

