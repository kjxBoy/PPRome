//
//  ViewController.swift
//  PPRoom
//
//  拍拍房 Demo 界面
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI组件
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let stateLabel = UILabel()
    private let itemLabel = UILabel()
    private let priceLabel = UILabel()
    private let leaderLabel = UILabel()
    
    private let messageTextView = UITextView()
    private let actionStackView = UIStackView()
    
    // MARK: - 数据
    private let roomManager = RoomManager.shared
    private var currentRoom: Room?
    private var currentUser: User?
    
    // 模拟的用户
    private var host: User!
    private var auctioneer: User!
    private var bidder1: User!
    private var bidder2: User!
    private var viewer: User!
    
    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeDemo()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 标题
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 状态标签
        stateLabel.font = .systemFont(ofSize: 18, weight: .medium)
        stateLabel.textAlignment = .center
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stateLabel)
        
        // 物品标签
        itemLabel.font = .systemFont(ofSize: 16)
        itemLabel.numberOfLines = 0
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemLabel)
        
        // 价格标签
        priceLabel.font = .systemFont(ofSize: 28, weight: .heavy)
        priceLabel.textColor = .systemRed
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        // 领先者标签
        leaderLabel.font = .systemFont(ofSize: 14)
        leaderLabel.textAlignment = .center
        leaderLabel.textColor = .systemGray
        leaderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leaderLabel)
        
        // 消息文本框
        messageTextView.font = .systemFont(ofSize: 12)
        messageTextView.backgroundColor = .systemGray6
        messageTextView.layer.cornerRadius = 8
        messageTextView.isEditable = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageTextView)
        
        // 操作按钮区域
        actionStackView.axis = .vertical
        actionStackView.spacing = 12
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionStackView)
        
        // 约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            itemLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 20),
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 20),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            leaderLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            leaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            leaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            messageTextView.topAnchor.constraint(equalTo: leaderLabel.bottomAnchor, constant: 20),
            messageTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageTextView.heightAnchor.constraint(equalToConstant: 200),
            
            actionStackView.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 20),
            actionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 初始化Demo
    
    private func initializeDemo() {
        // 创建模拟用户
        host = User(id: "host_001", nickname: "主持人小王", role: .host)
        auctioneer = User(id: "auc_001", nickname: "拍卖人老李", role: .auctioneer)
        bidder1 = User(id: "bid_001", nickname: "竞拍者张三", role: .bidder)
        bidder2 = User(id: "bid_002", nickname: "竞拍者李四", role: .bidder)
        viewer = User(id: "view_001", nickname: "观众小明", role: .viewer)
        
        // 默认当前用户是房主
        currentUser = host
        
        // 创建房间
        let room = roomManager.createRoom(name: "今晚靓号专场", owner: host)
        currentRoom = room
        
        // 其他用户加入房间
        roomManager.joinRoom(user: auctioneer, room: room)
        roomManager.joinRoom(user: bidder1, room: room)
        roomManager.joinRoom(user: bidder2, room: room)
        roomManager.joinRoom(user: viewer, room: room)
        
        // 拍卖人上麦（2号麦位）
        _ = roomManager.applyForMicrophone(user: auctioneer, room: room)
        
        // 设置按钮
        setupActionButtons()
        
        // 刷新UI
        updateUI()
    }
    
    // MARK: - 设置操作按钮
    
    private func setupActionButtons() {
        // 清空
        actionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 切换用户
        let userSection = createSectionLabel("切换当前用户")
        actionStackView.addArrangedSubview(userSection)
        
        let userButtons = UIStackView()
        userButtons.axis = .horizontal
        userButtons.spacing = 8
        userButtons.distribution = .fillEqually
        
        for user in [host!, auctioneer!, bidder1!, bidder2!, viewer!] {
            let btn = createButton(title: user.nickname, color: .systemBlue)
            btn.addTarget(self, action: #selector(switchUser(_:)), for: .touchUpInside)
            btn.tag = getUserTag(user)
            userButtons.addArrangedSubview(btn)
        }
        actionStackView.addArrangedSubview(userButtons)
        
        // 拍卖操作
        let auctionSection = createSectionLabel("拍卖操作")
        actionStackView.addArrangedSubview(auctionSection)
        
        let uploadBtn = createButton(title: "📦 拍卖人上传物品", color: .systemGreen)
        uploadBtn.addTarget(self, action: #selector(uploadItem), for: .touchUpInside)
        actionStackView.addArrangedSubview(uploadBtn)
        
        let startBtn = createButton(title: "▶️ 房主开始拍卖", color: .systemOrange)
        startBtn.addTarget(self, action: #selector(startAuction), for: .touchUpInside)
        actionStackView.addArrangedSubview(startBtn)
        
        let endBtn = createButton(title: "⏹ 房主结束拍卖", color: .systemRed)
        endBtn.addTarget(self, action: #selector(endAuction), for: .touchUpInside)
        actionStackView.addArrangedSubview(endBtn)
        
        // 出价操作
        let bidSection = createSectionLabel("出价操作")
        actionStackView.addArrangedSubview(bidSection)
        
        let bidButtons = UIStackView()
        bidButtons.axis = .horizontal
        bidButtons.spacing = 8
        bidButtons.distribution = .fillEqually
        
        for amount in [110, 150, 200] {
            let btn = createButton(title: "出价¥\(amount)", color: .systemPurple)
            btn.tag = amount
            btn.addTarget(self, action: #selector(placeBid(_:)), for: .touchUpInside)
            bidButtons.addArrangedSubview(btn)
        }
        actionStackView.addArrangedSubview(bidButtons)
        
        // 测试场景
        let scenarioSection = createSectionLabel("测试场景")
        actionStackView.addArrangedSubview(scenarioSection)
        
        let scenario1Btn = createButton(title: "🎬 场景1：观众尝试出价（应被拒绝）", color: .systemGray)
        scenario1Btn.addTarget(self, action: #selector(testScenario1), for: .touchUpInside)
        actionStackView.addArrangedSubview(scenario1Btn)
        
        let scenario2Btn = createButton(title: "🎬 场景2：拍卖人给自己出价（应被拒绝）", color: .systemGray)
        scenario2Btn.addTarget(self, action: #selector(testScenario2), for: .touchUpInside)
        actionStackView.addArrangedSubview(scenario2Btn)
        
        let scenario3Btn = createButton(title: "🎬 场景3：完整拍卖流程", color: .systemIndigo)
        scenario3Btn.addTarget(self, action: #selector(testScenario3), for: .touchUpInside)
        actionStackView.addArrangedSubview(scenario3Btn)
    }
    
    // MARK: - 创建UI元素
    
    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }
    
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return button
    }
    
    // MARK: - 操作方法
    
    @objc private func switchUser(_ sender: UIButton) {
        let users = [host!, auctioneer!, bidder1!, bidder2!, viewer!]
        currentUser = users[sender.tag]
        updateUI()
        showAlert(title: "切换用户", message: "当前用户：\(currentUser!.nickname) [\(currentUser!.role.displayName)]")
    }
    
    @objc private func uploadItem() {
        guard let room = currentRoom, let user = currentUser else { return }
        
        let result = roomManager.uploadItem(
            user: user,
            room: room,
            itemName: "靓号手机号 13888888888",
            description: "尾号8888，非常吉利",
            startPrice: 100,
            incrementStep: 10
        )
        
        handleResult(result, action: "上传物品")
        updateUI()
    }
    
    @objc private func startAuction() {
        guard let room = currentRoom, let user = currentUser else { return }
        
        let result = roomManager.startAuction(user: user, room: room)
        handleResult(result, action: "开始拍卖")
        
        // 延迟刷新UI（等待状态转换完成）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateUI()
        }
        
        // 再延迟刷新一次（等待自动进入拍卖中）
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.updateUI()
        }
    }
    
    @objc private func endAuction() {
        guard let room = currentRoom, let user = currentUser else { return }
        
        let result = roomManager.endAuction(user: user, room: room)
        handleResult(result, action: "结束拍卖")
        updateUI()
    }
    
    @objc private func placeBid(_ sender: UIButton) {
        guard let room = currentRoom, let user = currentUser else { return }
        
        let amount = Decimal(sender.tag)
        let result = roomManager.placeBid(user: user, room: room, amount: amount)
        handleResult(result, action: "出价")
        updateUI()
    }
    
    // MARK: - 测试场景
    
    @objc private func testScenario1() {
        guard let room = currentRoom else { return }
        
        showAlert(title: "测试场景1", message: "观众尝试出价（预期：被权限中心拒绝）")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = self.roomManager.placeBid(user: self.viewer, room: room, amount: 200)
            self.handleResult(result, action: "观众出价")
            self.updateUI()
        }
    }
    
    @objc private func testScenario2() {
        guard let room = currentRoom else { return }
        
        showAlert(title: "测试场景2", message: "拍卖人给自己出价（预期：被权限中心拒绝）")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 先确保拍卖在进行中
            if room.state != .auctioning {
                _ = self.roomManager.startAuction(user: self.host, room: room)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    let result = self.roomManager.placeBid(user: self.auctioneer, room: room, amount: 200)
                    self.handleResult(result, action: "拍卖人出价")
                    self.updateUI()
                }
            } else {
                let result = self.roomManager.placeBid(user: self.auctioneer, room: room, amount: 200)
                self.handleResult(result, action: "拍卖人出价")
                self.updateUI()
            }
        }
    }
    
    @objc private func testScenario3() {
        showAlert(title: "测试场景3", message: "完整拍卖流程演示（自动执行）")
        
        guard let room = currentRoom else { return }
        
        // 重置房间到准备阶段
        if room.state == .closed {
            _ = roomManager.startAuction(user: host, room: room)
        }
        
        var delay: TimeInterval = 1.0
        
        // 1. 拍卖人上传物品
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _ = self.roomManager.uploadItem(
                user: self.auctioneer,
                room: room,
                itemName: "靓号手机号 13888888888",
                description: "尾号8888，非常吉利"
            )
            self.updateUI()
        }
        delay += 1.5
        
        // 2. 房主开始拍卖
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _ = self.roomManager.startAuction(user: self.host, room: room)
            self.updateUI()
        }
        delay += 3.5
        
        // 3. 竞拍者1出价
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _ = self.roomManager.placeBid(user: self.bidder1, room: room, amount: 120)
            self.updateUI()
        }
        delay += 1.5
        
        // 4. 竞拍者2出价
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _ = self.roomManager.placeBid(user: self.bidder2, room: room, amount: 150)
            self.updateUI()
        }
        delay += 1.5
        
        // 5. 竞拍者1再次出价
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _ = self.roomManager.placeBid(user: self.bidder1, room: room, amount: 180)
            self.updateUI()
        }
        delay += 1.5
        
        // 6. 房主结束拍卖
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _ = self.roomManager.endAuction(user: self.host, room: room)
            self.updateUI()
        }
    }
    
    // MARK: - UI更新
    
    private func updateUI() {
        guard let room = currentRoom, let user = currentUser else { return }
        
        // 更新标题
        titleLabel.text = "🏠 \(room.name)\n在线：\(room.onlineCount)人"
        
        // 更新状态
        stateLabel.text = "\(room.state.color) \(room.state.displayName)"
        
        // 更新物品信息
        if let item = room.currentItem {
            itemLabel.text = "📦 \(item.displayInfo)\n拍卖人：\(item.auctioneerName)"
        } else {
            itemLabel.text = "暂无拍卖物品"
        }
        
        // 更新价格
        priceLabel.text = "¥\(room.currentPrice)"
        
        // 更新领先者
        if let leader = room.currentLeader {
            leaderLabel.text = "当前领先：\(leader)"
        } else {
            leaderLabel.text = "暂无出价"
        }
        
        // 更新消息
        var messageText = "📢 当前用户：\(user.nickname) [\(user.role.displayName)]\n"
        messageText += "麦位状态：\(user.isOnMicrophone ? "在麦上" : "麦下")\n"
        messageText += "\n--- 房间消息 ---\n\n"
        
        for message in room.messages.suffix(15) {
            messageText += message.displayText + "\n"
        }
        
        messageTextView.text = messageText
        
        // 滚动到底部
        let range = NSRange(location: messageText.count, length: 0)
        messageTextView.scrollRangeToVisible(range)
    }
    
    // MARK: - 辅助方法
    
    private func handleResult(_ result: Result<Void, RoomError>, action: String) {
        switch result {
        case .success:
            showAlert(title: "✅ 成功", message: "\(action) 成功！")
        case .failure(let error):
            showAlert(title: "⚠️ 失败", message: "\(action) 失败：\(error.localizedDescription)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func getUserTag(_ user: User) -> Int {
        let users = [host!, auctioneer!, bidder1!, bidder2!, viewer!]
        return users.firstIndex(where: { $0.id == user.id }) ?? 0
    }
}

