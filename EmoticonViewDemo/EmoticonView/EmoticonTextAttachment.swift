//
//  EmoticonTextAttachment.swift
//  EmoticonViewDemo
//
//  Created by yyj on 2018/1/8.
//  Copyright © 2018年 yj. All rights reserved.
//

import UIKit

class EmoticonTextAttachment: NSTextAttachment {
    // 保存对应表情的文字
    var chs: String?
    
    /// 根据表情模型, 创建表情字符串
    class func imageText(emoticon: Emoticon, font: CGFloat) -> NSAttributedString{
        
        // 创建附件
        let attachment = EmoticonTextAttachment()
        attachment.chs = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        // 设置了附件的大小
        attachment.bounds = CGRect(x: 0, y: -4, width: font, height: font)
        
        // 根据附件创建属性字符串
        return NSAttributedString(attachment: attachment)
    }
}

