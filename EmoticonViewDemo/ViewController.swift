//
//  ViewController.swift
//  EmoticonViewDemo
//
//  Created by yyj on 2018/1/8.
//  Copyright © 2018年 yj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    func itemClick(sender: AnyObject) {
        
        print(self.customTextView.emoticonAttributedText())
    }
    
    private lazy var customTextView: UITextView! = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.lightGray
        return textView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
 
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(customTextView)
        // 提示: 如果想自己封装一个框架, 最好不要依赖其它框架
        var cons = [NSLayoutConstraint]()
        let dict = ["customTextView": customTextView] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[customTextView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[customTextView(100)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
        
        // 1.将键盘控制器添加为当前控制器的子控制器
        addChildViewController(emoticonVC)
        
        // 2.将表情键盘控制器的view设置为UITextView的inputView
        customTextView.inputView = emoticonVC.view
        self.customTextView.font = UIFont.systemFont(ofSize: 20)
        
    }
    
    // MARK: - 懒加载
    // weak 相当于OC中的 __weak , 特点对象释放之后会将变量设置为nil
    // unowned 相当于OC中的 unsafe_unretained, 特点对象释放之后不会将变量设置为nil
    private lazy var emoticonVC: EmoticonViewController = EmoticonViewController { [unowned self] (emoticon) -> () in
        // TODO: 还不够完美
        self.customTextView.insertEmoticon(emoticon: emoticon, font: 20)
    }
    
    deinit
    {
       
    }
    
}


