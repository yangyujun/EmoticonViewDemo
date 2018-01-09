//
//  ViewController.swift
//  EmoticonViewDemo
//
//  Created by yyj on 2018/1/8.
//  Copyright © 2018年 yj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate lazy var customTextView: UITextView! = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.white
        textView.keyboardType = .numberPad
        textView.text = "dfadfdalfnadlfndaklfndalfkdoerjo4i3r4ru94ur04u045u04uuffjdfjdklfjadklfjadlkfjakldjfajfdajklasjdldjfljdlfjlsjfajflafjaldsjfls"
        return textView
    }()
    
    private lazy var sendBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("发送", for: .normal)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(senderClick), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(customTextView)
        view.addSubview(sendBtn)
        // 提示: 如果想自己封装一个框架, 最好不要依赖其它框架
        var cons = [NSLayoutConstraint]()
        let dict = ["sendBtn":sendBtn,"customTextView": customTextView] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[customTextView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-200-[sendBtn]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-60-[sendBtn(30)]-20-[customTextView]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
        
        // 将键盘控制器添加为当前控制器的子控制器
        addChildViewController(emoticonVC)
        
        // 将表情键盘控制器的view设置为UITextView的inputView
        customTextView.inputView = emoticonVC.view
        self.customTextView.font = UIFont.systemFont(ofSize: 20)
        
    }
    
    // weak 相当于OC中的 __weak , 特点对象释放之后会将变量设置为nil
    // unowned 相当于OC中的 unsafe_unretained, 特点对象释放之后不会将变量设置为nil
    private lazy var emoticonVC: EmoticonViewController = EmoticonViewController { [unowned self] (emoticon) -> () in
        
        self.customTextView.insertEmoticon(emoticon: emoticon, font: 20)
    }
    
    deinit
    {
        
    }
    
    func senderClick(){
        print(customTextView.emoticonAttributedText())
    }
    
}
