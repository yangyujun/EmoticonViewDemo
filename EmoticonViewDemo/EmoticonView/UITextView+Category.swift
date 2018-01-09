//
//  UITextView+Category.swift
//  EmoticonViewDemo
//
//  Created by yyj on 2018/1/8.
//  Copyright © 2018年 yj. All rights reserved.
//


import UIKit

extension UITextView
{
    func insertEmoticon(emoticon: Emoticon, font: CGFloat)
    {
        // 处理删除按钮
        if emoticon.isRemoveButton
        {
            deleteBackward()
        }
        
        // 判断当前点击的是否是emoji表情
        if emoticon.emojiStr != nil{
            //            self.selectedRange(self.selectedTextRange!, withText: emoticon.emojiStr!)
            self.replace(self.selectedTextRange!, withText: emoticon.emojiStr!)
        }
        
        // 判断当前点击的是否是表情图片
        if emoticon.png != nil{
            
            // 创建表情字符串
            let imageText = EmoticonTextAttachment.imageText(emoticon: emoticon, font: font)
            
            
            // 拿到当前所有的内容
            let strM = NSMutableAttributedString(attributedString: self.attributedText)
            
            // 插入表情到当前光标所在的位置
            let range = self.selectedRange
            strM.replaceCharacters(in: range, with: imageText)
            
            // 属性字符串有自己默认的尺寸
            strM.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: font - 1), range: NSMakeRange(range.location, 1))
            
            // 将替换后的字符串赋值给UITextView
            self.attributedText = strM
            // 恢复光标所在的位置
            // 两个参数: 第一个是指定光标所在的位置, 第二个参数是选中文本的个数
            self.selectedRange = NSMakeRange(range.location + 1, 0)
            
        }
    }
    
    /**
     获取需要发送给服务器的字符串
     */
    func emoticonAttributedText() -> String
    {
        var strM = String()
        // 后去需要发送给服务器的数据
        attributedText.enumerateAttributes( in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (objc, range, _) -> Void in
            
            if objc["NSAttachment"] != nil
            {
                // 图片
                let attachment =  objc["NSAttachment"] as! EmoticonTextAttachment
                strM += attachment.chs!
            }else
            {
                // 文字
                strM += (self.text as NSString).substring(with: range)
            }
        }
        return strM
    }
}

