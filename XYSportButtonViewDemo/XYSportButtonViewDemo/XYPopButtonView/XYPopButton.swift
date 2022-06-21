//
//  XYPopButton.swift
//  LuoNengWatch
//
//  Created by ecsage on 2021/11/2.
//  Copyright © 2021 iOSyan. All rights reserved.
//

import UIKit

class XYPopButton: UIView  {
    // 长按结束后闭包传值
    var completionBlock: (() -> Void)?
    
    lazy var lineWidth: CGFloat = 6.0
    lazy var longPressEnabled = true
    
    lazy var centerButton = UIButton(type: .custom)
    lazy var progressLayer = CAShapeLayer()
    
    lazy var color: UIColor = .white {
        didSet {
            progressLayer.strokeColor = color.cgColor
        }
    }
    
    deinit {
        print("deinit")
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
    
    func setup() {
//        self.backgroundColor = .yellow
        setupProgress()
        setupCenterButton() // 这个放progress层级上面
        setupGesture()
    }
    
    func setupProgress() {
        let center = CGPoint(x: self.width/2, y: self.height/2)
        let radius = self.width/2 - self.lineWidth/2
        let startA = -Double.pi/2  // 设置进度条起点位置
        let endA = -Double.pi/2 + Double.pi * 2 //设置进度条终点位置
        
        let path = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: startA, endAngle: endA, clockwise: true) // 用来构建圆形
        
        //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
        let pLayer = CAShapeLayer()
        pLayer.fillColor = UIColor.clear.cgColor //填充色为无色
        pLayer.strokeColor = UIColor.white.cgColor // 指定path的渲染颜色,这里可以设置任意不透明颜色
        pLayer.opacity = 0.4 //背景颜色的透明度
        pLayer.lineCap = CAShapeLayerLineCap.round //指定线的边缘是圆的
        pLayer.lineWidth = self.lineWidth //线的宽度
        pLayer.path = path.cgPath
        // layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
        layer.addSublayer(pLayer)
        
        //进度layer 即：遮盖layer
        //圆形路径
        let circlePath = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: startA, endAngle: endA, clockwise: true)
        progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = color.cgColor
        progressLayer.lineWidth = self.lineWidth
        // 指定线的边缘是圆的
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    func setupCenterButton() {
        addSubview(centerButton)
        centerButton.frame = self.bounds
        centerButton.layer.cornerRadius = self.width/2
        centerButton.adjustsImageWhenHighlighted = false
        centerButton.adjustsImageWhenDisabled = false
        centerButton.imageView?.contentMode = .scaleToFill
        centerButton.contentHorizontalAlignment = .fill
        centerButton.contentVerticalAlignment = .fill
    }
    
    func setupGesture() {
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress))
        longGesture.minimumPressDuration = 0.1
        centerButton.addGestureRecognizer(longGesture)
    }
    
    func startAnimation() {
        // 增加动画
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        pathAnimation.fromValue = NSNumber(value: 0.0)
        pathAnimation.toValue = NSNumber(value: 1.0)
        pathAnimation.autoreverses = false

        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.repeatCount = 1
        pathAnimation.delegate = self
        progressLayer.add(pathAnimation, forKey: "strokeEndAnimation")
    }
    
    func stopAnimation() {
        progressLayer.removeAllAnimations()
    }
    
    // 还原
    func restore() {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.1, animations: {
            weakSelf?.centerButton.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            weakSelf?.stopAnimation()
        }, completion: {  finished in
        })
    }
    
    // MARK: - 点击事件
    @objc func buttonClick() {
//        centerButton.isSelected = !centerButton.isSelected
//        longPressEnabled = centerButton.isSelected
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        
        if !longPressEnabled { return }
        weak var weakSelf = self
        switch gestureRecognizer.state {
        case .began:
            let scale = 0.8
            UIView.animate(withDuration: 0.1, animations: {
                weakSelf!.centerButton.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                weakSelf!.startAnimation()
            }, completion: {  finished in
            })
        case .ended:
            restore()
        default:
            break
        }
    }
}

extension XYPopButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {return}
        if let completionBlock = completionBlock {
            completionBlock()
        }
        
        restore()
    }
}
