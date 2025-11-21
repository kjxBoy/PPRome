//
//  RoomManager.swift
//  PPRoom
//
//  房间管理器 - 整合权限中心和状态模式
//

import Foundation

class RoomManager {
    static let shared = RoomManager()
    
    private let permissionCenter = PermissionCenter.shared
    private var currentRoom: Room?
    
    private init() {}
    
    // MARK: - 房间操作
    
    /// 创建房间
    func createRoom(name: String, owner: User) -> Room {
        let room = Room(
            id: UUID().uuidString,
            name: name,
            owner: owner
        )
        currentRoom = room
        print("🏠 创建房间成功：\(name)")
        return room
    }
    
    /// 获取当前房间
    func getCurrentRoom() -> Room? {
        return currentRoom
    }
    
    // MARK: - 拍卖流程操作（带权限检查）
    
    /// 上传拍卖物品
    func uploadItem(
        user: User,
        room: Room,
        itemName: String,
        description: String,
        startPrice: Decimal = 100,
        incrementStep: Decimal = 10
    ) -> Result<Void, RoomError> {
        // 1. 权限检查
        let result = permissionCenter.checkPermission(
            action: .uploadItem,
            user: user,
            room: room
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        // 2. 执行业务逻辑
        let item = AuctionItem(
            id: UUID().uuidString,
            name: itemName,
            description: description,
            auctioneerId: user.id,
            auctioneerName: user.nickname
        )
        
        let rules = AuctionRules(
            startPrice: startPrice,
            incrementStep: incrementStep,
            countdownSeconds: 30
        )
        
        let success = room.stateObject.uploadItem(room: room, item: item, rules: rules)
        
        if success {
            return .success(())
        } else {
            return .failure(.operationFailed("上传失败"))
        }
    }
    
    /// 开始拍卖
    func startAuction(user: User, room: Room) -> Result<Void, RoomError> {
        // 1. 权限检查
        let result = permissionCenter.checkPermission(
            action: .startAuction,
            user: user,
            room: room
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        // 2. 执行状态转换
        let success = room.stateObject.startAuction(room: room)
        
        if success {
            return .success(())
        } else {
            return .failure(.operationFailed("开始拍卖失败"))
        }
    }
    
    /// 出价
    func placeBid(
        user: User,
        room: Room,
        amount: Decimal
    ) -> Result<Void, RoomError> {
        // 1. 权限检查
        let result = permissionCenter.checkPermission(
            action: .placeBid,
            user: user,
            room: room,
            metadata: ["amount": amount]
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        // 2. 执行出价逻辑
        let success = room.stateObject.placeBid(room: room, user: user, amount: amount)
        
        if success {
            return .success(())
        } else {
            return .failure(.operationFailed("出价失败"))
        }
    }
    
    /// 结束拍卖
    func endAuction(user: User, room: Room) -> Result<Void, RoomError> {
        // 1. 权限检查
        let result = permissionCenter.checkPermission(
            action: .forceEndAuction,
            user: user,
            room: room
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        // 2. 执行状态转换
        let success = room.stateObject.endAuction(room: room)
        
        if success {
            return .success(())
        } else {
            return .failure(.operationFailed("结束拍卖失败"))
        }
    }
    
    // MARK: - 麦位操作（带权限检查）
    
    /// 申请上麦
    func applyForMicrophone(user: User, room: Room) -> Result<Int, RoomError> {
        // 1. 权限检查
        let result = permissionCenter.checkPermission(
            action: .applyForMicrophone,
            user: user,
            room: room
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        // 2. 分配麦位
        guard let mic = room.getAvailableMicrophone() else {
            return .failure(.operationFailed("没有可用麦位"))
        }
        
        let success = room.assignMicrophone(to: user, seatNumber: mic.seatNumber)
        
        if success {
            return .success(mic.seatNumber)
        } else {
            return .failure(.operationFailed("上麦失败"))
        }
    }
    
    /// 下麦
    func leaveMicrophone(user: User, room: Room) -> Result<Void, RoomError> {
        guard user.isOnMicrophone else {
            return .failure(.invalidState("您不在麦位上"))
        }
        
        room.removeMicrophone(userId: user.id)
        return .success(())
    }
    
    /// 踢下麦
    func kickFromMicrophone(operatorUser: User, targetUserId: String, room: Room) -> Result<Void, RoomError> {
        // 1. 权限检查
        let result = permissionCenter.checkPermission(
            action: .kickFromMicrophone,
            user: operatorUser,
            room: room,
            metadata: ["targetUserId": targetUserId]
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        // 2. 踢下麦
        room.removeMicrophone(userId: targetUserId)
        return .success(())
    }
    
    // MARK: - 消息操作
    
    /// 发送文字消息
    func sendMessage(user: User, room: Room, content: String) -> Result<Void, RoomError> {
        let result = permissionCenter.checkPermission(
            action: .sendMessage,
            user: user,
            room: room
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        room.addMessage(from: user, content: content)
        return .success(())
    }
    
    /// 发送语音
    func sendVoice(user: User, room: Room) -> Result<Void, RoomError> {
        let result = permissionCenter.checkPermission(
            action: .sendVoice,
            user: user,
            room: room
        )
        
        guard result.isAllowed else {
            return .failure(.permissionDenied(result.deniedReason ?? "权限不足"))
        }
        
        print("🎤 \(user.nickname) 正在语音中...")
        return .success(())
    }
    
    // MARK: - 用户操作
    
    /// 用户加入房间
    func joinRoom(user: User, room: Room) {
        room.addUser(user)
    }
    
    /// 切换角色
    func changeRole(user: User, newRole: UserRole) {
        user.role = newRole
        print("👤 \(user.nickname) 切换角色为：\(newRole.displayName)")
    }
}

