//
//  PermissionCenter.swift
//  PPRoom
//
//  权限中心 - 基于规则引擎
//

import Foundation

// MARK: - 权限结果
enum PermissionResult {
    case allowed
    case denied(reason: String)
    
    var isAllowed: Bool {
        if case .allowed = self {
            return true
        }
        return false
    }
    
    var deniedReason: String? {
        if case .denied(let reason) = self {
            return reason
        }
        return nil
    }
}

// MARK: - 权限上下文
struct PermissionContext {
    let user: User
    let room: Room
    let action: RoomAction
    let metadata: [String: Any]?
    
    init(user: User, room: Room, action: RoomAction, metadata: [String: Any]? = nil) {
        self.user = user
        self.room = room
        self.action = action
        self.metadata = metadata
    }
}

// MARK: - 权限规则
struct PermissionRule {
    let action: RoomAction
    let priority: Int
    let description: String
    let condition: (PermissionContext) -> PermissionResult
    
    init(action: RoomAction, priority: Int, description: String = "", condition: @escaping (PermissionContext) -> PermissionResult) {
        self.action = action
        self.priority = priority
        self.description = description
        self.condition = condition
    }
}

// MARK: - 规则引擎
class PermissionRuleEngine {
    private var rules: [RoomAction: [PermissionRule]] = [:]
    
    init() {
        setupRules()
    }
    
    private func setupRules() {
        // ===== 出价规则 =====
        
        addRule(PermissionRule(
            action: .placeBid,
            priority: 100,
            description: "只能在拍卖中状态出价"
        ) { context in
            guard context.room.state == .auctioning else {
                return .denied(reason: "❌ 当前不在拍卖阶段，无法出价")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .placeBid,
            priority: 90,
            description: "拍卖人不能给自己出价"
        ) { context in
            if context.user.role == .auctioneer,
               let item = context.room.currentItem,
               context.user.id == item.auctioneerId {
                return .denied(reason: "❌ 您是拍卖人，不能对自己的物品出价")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .placeBid,
            priority: 80,
            description: "观众不能出价"
        ) { context in
            guard context.user.role != .viewer else {
                return .denied(reason: "❌ 观众无法出价，请升级为竞拍者")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .placeBid,
            priority: 70,
            description: "出价金额必须满足要求"
        ) { context in
            guard let amount = context.metadata?["amount"] as? Decimal else {
                return .denied(reason: "❌ 出价金额无效")
            }
            
            let currentPrice = context.room.currentPrice
            let minIncrement = context.room.rules.incrementStep
            let minValidPrice = currentPrice + minIncrement
            
            guard amount >= minValidPrice else {
                return .denied(reason: "❌ 出价至少为 ¥\(minValidPrice)")
            }
            
            return .allowed
        })
        
        // ===== 开始拍卖规则 =====
        
        addRule(PermissionRule(
            action: .startAuction,
            priority: 100,
            description: "只有房主能开始拍卖"
        ) { context in
            guard context.user.id == context.room.owner.id else {
                return .denied(reason: "❌ 只有房主可以开始拍卖")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .startAuction,
            priority: 90,
            description: "只能在准备阶段或上拍阶段开始"
        ) { context in
            guard context.room.state == .preparing || context.room.state == .listing else {
                return .denied(reason: "❌ 拍卖已经开始或已结束")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .startAuction,
            priority: 80,
            description: "必须有拍卖物品"
        ) { context in
            guard context.room.currentItem != nil else {
                return .denied(reason: "❌ 请先上传拍卖物品")
            }
            return .allowed
        })
        
        // ===== 上传物品规则 =====
        
        addRule(PermissionRule(
            action: .uploadItem,
            priority: 100,
            description: "只能在准备阶段上传物品"
        ) { context in
            guard context.room.state == .preparing else {
                return .denied(reason: "❌ 只能在准备阶段上传物品")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .uploadItem,
            priority: 90,
            description: "只有拍卖人能上传物品"
        ) { context in
            guard context.user.role == .auctioneer else {
                return .denied(reason: "❌ 只有拍卖人可以上传物品")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .uploadItem,
            priority: 80,
            description: "拍卖人必须在麦上"
        ) { context in
            guard context.user.isOnMicrophone else {
                return .denied(reason: "❌ 请先上麦再上传物品")
            }
            return .allowed
        })
        
        // ===== 上麦规则 =====
        
        addRule(PermissionRule(
            action: .applyForMicrophone,
            priority: 100,
            description: "麦位必须有空位"
        ) { context in
            guard context.room.getAvailableMicrophone() != nil else {
                return .denied(reason: "❌ 麦位已满，请稍后再试")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .applyForMicrophone,
            priority: 90,
            description: "不能重复上麦"
        ) { context in
            guard !context.user.isOnMicrophone else {
                return .denied(reason: "❌ 您已经在麦位上了")
            }
            return .allowed
        })
        
        // ===== 同意上麦规则 =====
        
        addRule(PermissionRule(
            action: .acceptMicrophoneRequest,
            priority: 100,
            description: "只有房主能同意上麦"
        ) { context in
            guard context.user.id == context.room.owner.id else {
                return .denied(reason: "❌ 只有房主可以管理麦位")
            }
            return .allowed
        })
        
        // ===== 踢下麦规则 =====
        
        addRule(PermissionRule(
            action: .kickFromMicrophone,
            priority: 100,
            description: "只有房主能踢人下麦"
        ) { context in
            guard context.user.id == context.room.owner.id else {
                return .denied(reason: "❌ 只有房主可以管理麦位")
            }
            return .allowed
        })
        
        // ===== 强制结束规则 =====
        
        addRule(PermissionRule(
            action: .forceEndAuction,
            priority: 100,
            description: "只有房主能强制结束"
        ) { context in
            guard context.user.id == context.room.owner.id else {
                return .denied(reason: "❌ 只有房主可以强制结束拍卖")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .forceEndAuction,
            priority: 90,
            description: "只能在拍卖中强制结束"
        ) { context in
            guard context.room.state == .auctioning else {
                return .denied(reason: "❌ 拍卖未开始或已结束")
            }
            return .allowed
        })
        
        // ===== 发语音规则 =====
        
        addRule(PermissionRule(
            action: .sendVoice,
            priority: 100,
            description: "只有麦上用户可以发语音"
        ) { context in
            guard context.user.isOnMicrophone else {
                return .denied(reason: "❌ 请先上麦才能语音交流")
            }
            return .allowed
        })
        
        addRule(PermissionRule(
            action: .sendVoice,
            priority: 90,
            description: "被禁言不能发语音"
        ) { context in
            guard !context.user.isMuted else {
                return .denied(reason: "❌ 您已被禁言")
            }
            return .allowed
        })
        
        // ===== 发消息规则（基本所有人都可以） =====
        
        addRule(PermissionRule(
            action: .sendMessage,
            priority: 100,
            description: "所有人都可以发文字消息"
        ) { context in
            return .allowed
        })
    }
    
    func addRule(_ rule: PermissionRule) {
        if rules[rule.action] == nil {
            rules[rule.action] = []
        }
        rules[rule.action]?.append(rule)
    }
    
    func evaluate(context: PermissionContext) -> PermissionResult {
        guard let actionRules = rules[context.action] else {
            return .denied(reason: "❌ 该操作暂未开放")
        }
        
        let sortedRules = actionRules.sorted { $0.priority > $1.priority }
        
        for rule in sortedRules {
            let result = rule.condition(context)
            if case .denied = result {
                return result
            }
        }
        
        return .allowed
    }
}

// MARK: - 权限中心
class PermissionCenter {
    static let shared = PermissionCenter()
    
    private let ruleEngine = PermissionRuleEngine()
    
    private init() {}
    
    /// 检查权限
    func checkPermission(
        action: RoomAction,
        user: User,
        room: Room,
        metadata: [String: Any]? = nil
    ) -> PermissionResult {
        let context = PermissionContext(
            user: user,
            room: room,
            action: action,
            metadata: metadata
        )
        
        let result = ruleEngine.evaluate(context: context)
        
        // 记录日志（可选）
        logPermissionCheck(context: context, result: result)
        
        return result
    }
    
    /// 便捷方法：检查是否允许
    func canPerform(
        action: RoomAction,
        user: User,
        room: Room,
        metadata: [String: Any]? = nil
    ) -> Bool {
        return checkPermission(action: action, user: user, room: room, metadata: metadata).isAllowed
    }
    
    /// 便捷方法：获取拒绝原因
    func getDeniedReason(
        action: RoomAction,
        user: User,
        room: Room,
        metadata: [String: Any]? = nil
    ) -> String? {
        return checkPermission(action: action, user: user, room: room, metadata: metadata).deniedReason
    }
    
    private func logPermissionCheck(context: PermissionContext, result: PermissionResult) {
        let resultText = result.isAllowed ? "✅ 允许" : "❌ 拒绝"
        let reason = result.deniedReason ?? ""
        print("🔐 权限检查: [\(context.user.nickname)] [\(context.action.rawValue)] [\(context.room.state.displayName)] -> \(resultText) \(reason)")
    }
}

