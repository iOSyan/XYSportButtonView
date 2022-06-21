//
//  XYPopButtonView.swift
//  LuoNengWatch
//
//  Created by ecsage on 2021/11/2.
//  Copyright © 2021 iOSyan. All rights reserved.
//

import UIKit

class XYPopButtonView: UIView {
    
    var mapClickBlock: (() -> Void)?
    var continueClickBlock: (() -> Void)?
    var pauseClickBlock: (() -> Void)?
    var stopClickBlock: (() -> Void)?
    
    lazy var play: UIButton = UIButton(type: .custom)
    lazy var stop: XYPopButton = XYPopButton()
    lazy var map: UIButton = UIButton(type: .custom)
    lazy var lock: UIButton = UIButton(type: .custom)
    lazy var unlock: XYPopButton = XYPopButton()
    
    lazy var margin: CGFloat = 8
    
    lazy var buttonHeight = self.height
    var buttonWidth: CGFloat {
        buttonHeight
    }
    var selfCenterX: CGFloat {
        UIScreen.main.bounds.size.width/2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        print("deinit")
    }
    
    func setup() {
        
        setupBtn()
        setupOtherBtn()
        
        // 一进来先进入显示暂停模式
        play.isSelected = true
        updateCenterBtnFrame(isCenter: true)
        updateOtherBtnFrame()
    }
    
    func setupBtn() {
        
        stop = XYPopButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        stop.centerButton.setImage(UIImage(named: "walk_bottom_button_end"), for: .normal)
        addSubview(stop)
        stop.color = .red
        weak var weakSelf = self
        stop.completionBlock = {
            if let stopClickBlock = weakSelf?.stopClickBlock {
                stopClickBlock()
            }
        }
        stop.centerButton.addTarget(self, action: #selector(stopClick), for: .touchUpInside)
        

        play.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        play.setImage(UIImage(named: "walk_bottom_button_continue"), for: .normal)
        play.setImage(UIImage(named: "walk_bottom_button_suspended"), for: .selected)
        play.adjustsImageWhenHighlighted = false
        play.adjustsImageWhenDisabled = false
        play.imageView?.contentMode = .scaleToFill
        play.contentHorizontalAlignment = .fill
        play.contentVerticalAlignment = .fill
        addSubview(play)
        play.addTarget(self, action: #selector(playClick), for: .touchUpInside)
    }
    
    func setupOtherBtn() {
        let width: CGFloat = 32
        let height = width

        map.frame = CGRect(x: 0, y: 0, width: width, height: height)
        addSubview(map)
        map.centerY = play.centerY
        map.setImage(UIImage(named: "walk_bottom_icon_map"), for: .normal)
        map.adjustsImageWhenHighlighted = false
        map.adjustsImageWhenDisabled = false
        map.imageView?.contentMode = .scaleToFill
        map.contentHorizontalAlignment = .fill
        map.contentVerticalAlignment = .fill
        map.addTarget(self, action: #selector(mapClick), for: .touchUpInside)
        // 1.0版本暂时不要map
        map.isHidden = true

        lock.frame = CGRect(x: 0, y: 0, width: width, height: height)
        addSubview(lock)
        lock.centerY = play.centerY
        lock.setImage(UIImage(named: "walk_bottom_icon_lock"), for: .normal)
        lock.setImage(UIImage(named: "walk_bottom_icon_unlock"), for: .selected)
        lock.adjustsImageWhenHighlighted = false
        lock.adjustsImageWhenDisabled = false
        lock.imageView?.contentMode = .scaleToFill
        lock.contentHorizontalAlignment = .fill
        lock.contentVerticalAlignment = .fill
        lock.addTarget(self, action: #selector(lockClick), for: .touchUpInside)
    }
    
    func updateCenterBtnFrame(isCenter: Bool) {
        if isCenter {
            stop.centerX = selfCenterX
            play.centerX = selfCenterX
        } else {
            stop.centerX = (selfCenterX+buttonWidth/2)+margin
            play.centerX = (selfCenterX-buttonWidth/2)-margin
        }
    }
    
    func updateOtherBtnFrame() {
        let marg = 15.0
        self.map.centerX = self.play.centerX - self.play.width/2 - marg - self.map.width/2
        self.lock.centerX = self.stop.centerX + self.stop.width/2 + marg + self.lock.width/2
    }
    
    //MARK: - 点击事件
    @objc func playClick() {
//        weak var weakSelf = self
        if !play.isSelected { // 继续
            if let continueClickBlock = continueClickBlock {
                continueClickBlock()
            }
            updateButtonUI(isContinue: true)
        } else { // 暂停
            if let pauseClickBlock = pauseClickBlock {
                pauseClickBlock()
            }
            updateButtonUI(isContinue: false)
        }
    }
    
    func updateButtonUI(isContinue: Bool) {
        weak var weakSelf = self
        if isContinue {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: .curveLinear, animations: {
                weakSelf!.updateCenterBtnFrame(isCenter: true)
                weakSelf!.updateOtherBtnFrame()
            }) { finished in
                weakSelf!.play.isSelected = !weakSelf!.play.isSelected
            }
        } else {
            play.isSelected = !play.isSelected
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveLinear, animations: {
                weakSelf!.updateCenterBtnFrame(isCenter: false)
                weakSelf!.updateOtherBtnFrame()
            }) { finished in
                //            self.play.selected = !self.play.selected;
            }
        }
    }
    
    @objc func lockClick() {
        weak var weakSelf = self
        if !self.lock.isSelected { // 未锁定情况下去锁定
            UIView.animate(withDuration: 0.25, animations: {
                weakSelf!.updateCenterBtnFrame(isCenter: true)
                weakSelf!.map.centerX = weakSelf!.selfCenterX
                weakSelf!.lock.centerX = weakSelf!.selfCenterX
            }) { finished in
                weakSelf!.lock.size = weakSelf!.play.size
                weakSelf!.lock.centerX = weakSelf!.selfCenterX
                weakSelf!.lock.centerY = weakSelf!.buttonHeight / 2
                weakSelf!.lock.isSelected = !weakSelf!.lock.isSelected
                weakSelf!.lock.isHidden = true
                
                // 这里添加一个unlock
                weakSelf!.unlock = XYPopButton(frame: weakSelf!.lock.frame)
                weakSelf!.unlock.centerButton.setImage(UIImage(named: "walk_bottom_icon_unlock"), for: .normal)
                weakSelf!.unlock.completionBlock = {
                    weakSelf!.unlockLongClick()
                }
//                weakSelf!.unlock.centerButton.addTarget(self, action: #selector(weakSelf!.unlockClick), for: .touchUpInside)
                weakSelf!.addSubview(weakSelf!.unlock)
            }
        }
    }
    
    // 解锁
    func unlockLongClick() {
        weak var weakSelf = self
        self.lock.isSelected = !self.lock.isSelected
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveLinear) {
            if !weakSelf!.play.isSelected {
                weakSelf?.updateCenterBtnFrame(isCenter: false)
            }
            
            weakSelf!.lock.size = weakSelf!.map.size
            weakSelf!.lock.centerY = weakSelf!.map.centerY
            weakSelf?.updateOtherBtnFrame()
            
            weakSelf!.lock.isHidden = false
            weakSelf!.unlock.isHidden = true
        } completion: { finished in
            // 删除unlock
            weakSelf?.unlock.removeFromSuperview()
        }
    }
    
    // 为了给设备发指令时调用
    func unlockRefresh() {
        weak var weakSelf = self
        lock.isSelected = !lock.isSelected
        play.isSelected = !play.isSelected
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveLinear) {
//            if !weakSelf!.play.isSelected {
                weakSelf?.updateCenterBtnFrame(isCenter: weakSelf!.play.isSelected)
//            }
            
            weakSelf!.lock.size = weakSelf!.map.size
            weakSelf!.lock.centerY = weakSelf!.map.centerY
            weakSelf?.updateOtherBtnFrame()
            
            weakSelf!.lock.isHidden = false
            weakSelf!.unlock.isHidden = true
        } completion: { finished in
            // 删除unlock
            weakSelf?.unlock.removeFromSuperview()
        }
    }
    
    @objc func mapClick() {
        if let mapClickBlock = mapClickBlock {
            mapClickBlock()
        }
    }

}

extension UIView {
    //x position
    var x : CGFloat{
        get {
            return frame.origin.x

        }
        set(newVal) {
            var tempFrame : CGRect = frame
            tempFrame.origin.x     = newVal
            frame                  = tempFrame
        }
    }

    //y position
    var y : CGFloat{
        get {
            return frame.origin.y
        }
        set(newVal) {
            var tempFrame : CGRect = frame
            tempFrame.origin.y     = newVal
            frame                  = tempFrame
        }
    }
    
    //size
    var size : CGSize {
        get {
            return CGSize(width: frame.size.width, height: frame.size.height)
        }
        set(newVal) {
            var tmpSize : CGSize = frame.size
            tmpSize              = newVal
            frame.size           = tmpSize
        }
    }

    //height
    var height : CGFloat{
        get {
            return frame.size.height
        }
        set(newVal) {
            var tmpFrame : CGRect = frame
            tmpFrame.size.height  = newVal
            frame                 = tmpFrame
        }
    }


    // width
    var width : CGFloat {
        get {
            return frame.size.width
        }
        set(newVal) {
            var tmpFrame : CGRect = frame
            tmpFrame.size.width   = newVal
            frame                 = tmpFrame
        }
    }

    // left
    var left : CGFloat {
        get {
            return x
        }
        set(newVal) {
            x = newVal
        }
    }

    // right
    var right : CGFloat {
        get {
            return x + width
        }
        set(newVal) {
            x = newVal - width
        }
    }

    // top
    var top : CGFloat {
        get {
            return y
        }
        set(newVal) {
            y = newVal
        }
    }

    // bottom
    var bottom : CGFloat {
        get {
            return y + height
        }

        set(newVal) {
            y = newVal - height
        }
    }

    //centerX
    var centerX : CGFloat {
        get {
            return center.x
        }
        set(newVal) {
            center = CGPoint(x: newVal, y: center.y)
        }
    }

    //centerY
    var centerY : CGFloat {
        get {
            return center.y
        }

        set(newVal) {
            center = CGPoint(x: center.x, y: newVal)
        }
    }
    
    //middleX
    var middleX : CGFloat {
        get {
            return width / 2
        }
    }

    //middleY
    var middleY : CGFloat {
        get {
            return height / 2
        }
    }

    //middlePoint
    var middlePoint : CGPoint {
        get {
            return CGPoint(x: middleX, y: middleY)
        }
    }
    
    var maxX : CGFloat {
        get {
            return frame.maxX
        }
    }
    
    var minX : CGFloat {
        get {
            return frame.minX
        }
    }
    
    var maxY : CGFloat {
        get {
            return frame.maxY
        }
    }
    
    var minY : CGFloat {
        get {
            return frame.minY
        }
    }
}
