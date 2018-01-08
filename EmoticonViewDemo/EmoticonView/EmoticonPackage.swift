//
//  EmoticonPackage.swift
//  EmoticonViewDemo
//
//  Created by yyj on 2018/1/8.
//  Copyright © 2018年 yj. All rights reserved.
//

import UIKit
/*
 结构:
 1. 加载emoticons.plist拿到每组表情的路径
 
 emoticons.plist(字典)  存储了所有组表情的数据
 |----packages(字典数组)
 |-------id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist(字典)
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组, 里面存储了所有表情)
 |----chs(表情对应的文字)
 |----png(表情对应的图片)
 |----code(emoji表情对应的十六进制字符串)
 */
class EmoticonPackage: NSObject {
    /// 当前组表情文件夹的名称
    var id: String?
    /// 组的名称
    var group_name_cn : String?
    /// 当前组所有的表情对象
    var emoticons: [Emoticon] = []
    
    /// 获取所有组的表情数组
    // 浪小花 -> 一组  -> 所有的表情模型(emoticons)
    // 默认 -> 一组  -> 所有的表情模型(emoticons)
    // emoji -> 一组  -> 所有的表情模型(emoticons)
    class func loadPackages() -> [EmoticonPackage] {
        
        var packages = [EmoticonPackage]()
        // 0.创建最近组
        let pk = EmoticonPackage(id: "")
        pk.group_name_cn = "最近"
        pk.emoticons = [Emoticon]()
        pk.appendEmtyEmoticons()
        packages.append(pk)
        
        
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        //Bundle.main().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        // 1.加载emoticons.plist
        let dict = NSDictionary(contentsOfFile: path)!
        //NSDictionary(contentsOfFile: path)!
        // 2.或emoticons中获取packages
        let dictArray = dict["packages"] as! [[String:AnyObject]]
        // 3.遍历packages数组
        for d in dictArray
        {
            // 4.取出ID, 创建对应的组
            let package = EmoticonPackage(id: d["id"]! as! String)
            packages.append(package)
            package.loadEmoticons()
            package.appendEmtyEmoticons()
        }
        return packages
    }
    
    /// 加载每一组中所有的表情
    func loadEmoticons() {
        let emoticonDict = NSDictionary.init(contentsOfFile: infoPath(fileName: "info.plist"))!
        //NSDictionary(contentsOfFile: infoPath("info.plist"))!
        group_name_cn = emoticonDict["group_name_cn"] as? String
        let dictArray = emoticonDict["emoticons"] as! [[String: String]]
        //        emoticons = [Emoticon]
        var index = 0
        for dict in dictArray{ // 固定102
            
            if index == 20
            {
                emoticons.append(Emoticon(isRemoveButton: true))
                index = 0
            }
            emoticons.append(Emoticon(dict: dict, id: id!))
            index = index+1
        }
    }
    
    /**
     追加空白按钮
     如果一页不足21个,那么就添加一些空白按钮补齐
     */
    func appendEmtyEmoticons()
    {
        print(emoticons.count )
        let count = emoticons.count % 21
        
        // 追加空白按钮
        for _ in count..<20
        {
            // 追加空白按钮
            emoticons.append(Emoticon(isRemoveButton: false))
        }
        // 追加一个删除按钮
        emoticons.append(Emoticon(isRemoveButton: true))
    }
    
    /**
     用于给最近添加表情
     */
    func appendEmoticons(emoticon: Emoticon)
    {
        // 1.判断是否是删除按钮
        if emoticon.isRemoveButton
        {
            return
        }
        // 2.判断当前点击的表情是否已经添加到最近数组中
        let contains = emoticons.contains(emoticon)
        if !contains
        {
            // 删除删除按钮
            emoticons.removeLast()
            emoticons.append(emoticon)
        }
        
        // 3.对数组进行排序
        var result = emoticons.sorted(by: { (e1, e2) -> Bool in
            return e1.times > e2.times
        })
        
        // 4.删除多余的表情
        if !contains
        {
            result.removeLast()
            // 添加一个删除按钮
            result.append(Emoticon(isRemoveButton: true))
        }
        
        emoticons = result
        
        print(emoticons.count )
        
    }
    
    /**
     获取指定文件的全路径
     
     :param: fileName 文件的名称
     
     :returns: 全路径
     */
    func infoPath(fileName: String) -> String {
        return (EmoticonPackage.emoticonPath().appendingPathComponent(id!) as NSString).appendingPathComponent(fileName)
    }
    /// 获取微博表情的主路径
    class func emoticonPath() -> NSString{
        return (Bundle.main.bundlePath as NSString).appendingPathComponent("Emoticons.bundle") as NSString
    }
    
    init(id: String)
    {
        self.id = id
    }
}

class Emoticon: NSObject {
    /// 表情对应的文字
    var chs: String?
    /// 表情对应的图片
    var png: String?
    {
        didSet{
            imagePath = (EmoticonPackage.emoticonPath().appendingPathComponent(id!) as NSString).appendingPathComponent(png!)
        }
    }
    /// emoji表情对应的十六进制字符串
    var code: String?{
        didSet{
            // 1.从字符串中取出十六进制的数
            // 创建一个扫描器, 扫描器可以从字符串中提取我们想要的数据
            let scanner = Scanner(string: code!)
            
            // 2.将十六进制转换为字符串
            var result:UInt32 = 0
            scanner.scanHexInt32(&result)
            
            // 3.将十六进制转换为emoji字符串
            emojiStr = "\(Character(UnicodeScalar(result)!))"
        }
    }
    
    var emojiStr: String?
    
    /// 当前表情对应的文件夹
    var id: String?
    
    /// 表情图片的全路径
    var imagePath: String?
    
    /// 标记是否是删除按钮
    var isRemoveButton: Bool = false
    
    /// 记录当前表情被使用的次数
    var times: Int = 0
    
    init(isRemoveButton: Bool)
    {
        super.init()
        self.isRemoveButton = isRemoveButton
    }
    
    init(dict: [String: String], id: String)
    {
        super.init()
        self.id = id
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
}

