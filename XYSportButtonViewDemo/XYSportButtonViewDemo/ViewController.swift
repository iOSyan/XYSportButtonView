//
//  ViewController.swift
//  XYSportButtonViewDemo
//
//  Created by ecsage on 2022/6/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var popButtonView: XYPopButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popButtonView.backgroundColor = .lightGray
        // 监听运动控制按钮点击
        popButtonViewClick()
    }
    
    func popButtonViewClick() {
        // 继续
        popButtonView.continueClickBlock = {
            print("continueClickBlock")
        }
         
        // 暂停
        popButtonView.pauseClickBlock = {
            print("pauseClickBlock")
        }
        
        // 停止按钮长按
        popButtonView.stopClickBlock = {
            print("stopClickBlock")
        }
    }


}

