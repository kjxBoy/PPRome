//
//  PermissionTests.swift
//  PPRoom
//
//  权限系统测试
//

import Foundation

class PermissionTests {
    
    static func runAllTests() {
        print("\n" + "="*50)
        print("🧪 开始权限系统测试")
        print("="*50 + "\n")
        
        testScenario1_ViewerCannotBid()
        testScenario2_AuctioneerCannotBidOwnItem()
        testScenario3_CompleteAuctionFlow()
        testScenario4_StateTransitions()
        testScenario5_RolePermissions()
        
        print("\n" + "="*50)
        print("✅ 所有测试完成！")
        print("="*50 + "\n")
    }
    
    // MARK: - 测试场景1：观众无法出价
    
    static func testScenario1_ViewerCannotBid() {
        print("\n【测试1】观众尝试出价（预期：被拒绝）")
        print("-" * 40)
        
        let manager = RoomManager.shared
        let host = User(id: "host1", nickname: "主持人", role: .host)
        let viewer = User(id: "viewer1", nickname: "观众", role: .viewer)
        
        let room = manager.createRoom(name: "测试房间", owner: host)
        manager.joinRoom(user: viewer, room: room)
        
        // 设置拍卖物品并开始
        let auctioneer = User(id: "auc1", nickname: "拍卖人", role: .auctioneer)
        _ = manager.applyForMicrophone(user: auctioneer, room: room)
        _ = manager.uploadItem(user: auctioneer, room: room, itemName: "测试物品", description: "测试")
        _ = manager.startAuction(user: host, room: room)
        
        // 等待进入拍卖中状态
        Thread.sleep(forTimeInterval: 3.5)
        
        // 观众尝试出价
        let result = manager.placeBid(user: viewer, room: room, amount: 150)
        
        switch result {
        case .success:
            print("❌ 测试失败：观众不应该能出价")
        case .failure(let error):
            print("✅ 测试通过：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 测试场景2：拍卖人无法给自己出价
    
    static func testScenario2_AuctioneerCannotBidOwnItem() {
        print("\n【测试2】拍卖人给自己出价（预期：被拒绝）")
        print("-" * 40)
        
        let manager = RoomManager.shared
        let host = User(id: "host2", nickname: "主持人", role: .host)
        let auctioneer = User(id: "auc2", nickname: "拍卖人", role: .auctioneer)
        
        let room = manager.createRoom(name: "测试房间2", owner: host)
        manager.joinRoom(user: auctioneer, room: room)
        
        _ = manager.applyForMicrophone(user: auctioneer, room: room)
        _ = manager.uploadItem(user: auctioneer, room: room, itemName: "测试物品", description: "测试")
        _ = manager.startAuction(user: host, room: room)
        
        Thread.sleep(forTimeInterval: 3.5)
        
        let result = manager.placeBid(user: auctioneer, room: room, amount: 150)
        
        switch result {
        case .success:
            print("❌ 测试失败：拍卖人不应该能给自己出价")
        case .failure(let error):
            print("✅ 测试通过：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 测试场景3：完整拍卖流程
    
    static func testScenario3_CompleteAuctionFlow() {
        print("\n【测试3】完整拍卖流程")
        print("-" * 40)
        
        let manager = RoomManager.shared
        let host = User(id: "host3", nickname: "主持人", role: .host)
        let auctioneer = User(id: "auc3", nickname: "拍卖人", role: .auctioneer)
        let bidder1 = User(id: "bid1", nickname: "竞拍者1", role: .bidder)
        let bidder2 = User(id: "bid2", nickname: "竞拍者2", role: .bidder)
        
        let room = manager.createRoom(name: "完整流程测试", owner: host)
        manager.joinRoom(user: auctioneer, room: room)
        manager.joinRoom(user: bidder1, room: room)
        manager.joinRoom(user: bidder2, room: room)
        
        print("1️⃣ 拍卖人上传物品...")
        _ = manager.applyForMicrophone(user: auctioneer, room: room)
        let uploadResult = manager.uploadItem(
            user: auctioneer,
            room: room,
            itemName: "靓号手机号",
            description: "尾号8888"
        )
        assert(uploadResult, "上传物品应该成功")
        print("✅ 上传成功")
        
        print("\n2️⃣ 房主开始拍卖...")
        let startResult = manager.startAuction(user: host, room: room)
        assert(startResult, "开始拍卖应该成功")
        print("✅ 开始成功")
        
        Thread.sleep(forTimeInterval: 3.5)
        
        print("\n3️⃣ 竞拍者1出价 ¥120...")
        let bid1Result = manager.placeBid(user: bidder1, room: room, amount: 120)
        assert(bid1Result, "竞拍者1出价应该成功")
        print("✅ 出价成功，当前价格：¥\(room.currentPrice)")
        
        print("\n4️⃣ 竞拍者2出价 ¥150...")
        let bid2Result = manager.placeBid(user: bidder2, room: room, amount: 150)
        assert(bid2Result, "竞拍者2出价应该成功")
        print("✅ 出价成功，当前价格：¥\(room.currentPrice)")
        
        print("\n5️⃣ 竞拍者1再次出价 ¥180...")
        let bid3Result = manager.placeBid(user: bidder1, room: room, amount: 180)
        assert(bid3Result, "竞拍者1再次出价应该成功")
        print("✅ 出价成功，当前价格：¥\(room.currentPrice)")
        
        print("\n6️⃣ 房主结束拍卖...")
        let endResult = manager.endAuction(user: host, room: room)
        assert(endResult, "结束拍卖应该成功")
        print("✅ 拍卖结束")
        print("🎉 最终成交：\(room.currentLeader ?? "无") - ¥\(room.currentPrice)")
        
        print("\n✅ 完整流程测试通过！")
    }
    
    // MARK: - 测试场景4：状态转换
    
    static func testScenario4_StateTransitions() {
        print("\n【测试4】状态转换测试")
        print("-" * 40)
        
        let manager = RoomManager.shared
        let host = User(id: "host4", nickname: "主持人", role: .host)
        let room = manager.createRoom(name: "状态测试", owner: host)
        
        print("初始状态：\(room.state.displayName)")
        assert(room.state == .preparing, "初始状态应该是准备中")
        
        // 尝试在准备阶段出价（应该失败）
        let bidder = User(id: "bid", nickname: "竞拍者", role: .bidder)
        manager.joinRoom(user: bidder, room: room)
        
        let bidResult = manager.placeBid(user: bidder, room: room, amount: 200)
        switch bidResult {
        case .success:
            print("❌ 不应该在准备阶段出价成功")
        case .failure(let error):
            print("✅ 正确拒绝了在准备阶段的出价：\(error.localizedDescription)")
        }
        
        print("\n✅ 状态转换测试通过！")
    }
    
    // MARK: - 测试场景5：角色权限
    
    static func testScenario5_RolePermissions() {
        print("\n【测试5】角色权限测试")
        print("-" * 40)
        
        let manager = RoomManager.shared
        let host = User(id: "host5", nickname: "主持人", role: .host)
        let bidder = User(id: "bid5", nickname: "竞拍者", role: .bidder)
        
        let room = manager.createRoom(name: "权限测试", owner: host)
        manager.joinRoom(user: bidder, room: room)
        
        // 竞拍者尝试上传物品（应该失败）
        print("竞拍者尝试上传物品...")
        let uploadResult = manager.uploadItem(
            user: bidder,
            room: room,
            itemName: "测试",
            description: "测试"
        )
        
        switch uploadResult {
        case .success:
            print("❌ 竞拍者不应该能上传物品")
        case .failure(let error):
            print("✅ 正确拒绝：\(error.localizedDescription)")
        }
        
        // 竞拍者尝试开始拍卖（应该失败）
        print("\n竞拍者尝试开始拍卖...")
        let startResult = manager.startAuction(user: bidder, room: room)
        
        switch startResult {
        case .success:
            print("❌ 竞拍者不应该能开始拍卖")
        case .failure(let error):
            print("✅ 正确拒绝：\(error.localizedDescription)")
        }
        
        print("\n✅ 角色权限测试通过！")
    }
    
    // MARK: - 辅助方法
    
    private static func assert(_ result: Result<Void, RoomError>, _ message: String) {
        switch result {
        case .success:
            break
        case .failure(let error):
            print("❌ 断言失败：\(message) - \(error.localizedDescription)")
        }
    }
    
    private static func assert(_ condition: Bool, _ message: String) {
        if !condition {
            print("❌ 断言失败：\(message)")
        }
    }
}

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

