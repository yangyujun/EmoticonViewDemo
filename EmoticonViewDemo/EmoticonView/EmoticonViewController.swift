//
//  EmoticonViewController.swift
//  EmoticonViewDemo
//
//  Created by yyj on 2018/1/8.
//  Copyright © 2018年 yj. All rights reserved.
//


import UIKit

private let XMGEmoticonCellReuseIdentifier = "XMGEmoticonCellReuseIdentifier"

class EmoticonViewController: UIViewController {
    
    /// 定义一个闭包属性, 用于传递选中的表情模型
    var emoticonDidSelectedCallBack: (_ emoticon: Emoticon)->()
    
    init(callBack: @escaping (_ emoticon: Emoticon)->())
    {
        self.emoticonDidSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        
        // 初始化UI
        setupUI()
    }
    /**
     初始化UI
     */
    private func setupUI()
    {
        // 添加子控件
        view.addSubview(collectionVeiw)
        view.addSubview(toolbar)
        
        // 布局子控件
        collectionVeiw.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionVeiw": collectionVeiw, "toolbar": toolbar] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionVeiw]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionVeiw]-[toolbar(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        view.addConstraints(cons)
    }
    
    // MARK: - 懒加载
    fileprivate lazy var collectionVeiw: UICollectionView = {
        let clv = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonLayout())
        // 注册cell
        clv.register(EmoticonCell.self, forCellWithReuseIdentifier: XMGEmoticonCellReuseIdentifier)
        clv.dataSource = self
        clv.delegate = self
        clv.backgroundColor = UIColor.lightGray
        return clv
    }()
    
    fileprivate lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.tintColor = UIColor.lightGray
        var items = [UIBarButtonItem]()
        
        var index = 0
        for title in ["最近", "默认", "emoji", "浪小花"]
        {
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action:#selector(itemClick(_:)))
            item.tag = index
            index += 1
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        bar.items = items
        return bar
    }()
    
    fileprivate lazy var packages: [EmoticonPackage] = EmoticonPackage.loadPackages()
}

extension EmoticonViewController{
    
}

extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XMGEmoticonCellReuseIdentifier, for: indexPath) as! EmoticonCell
        
        // 取出对应的组
        let package = packages[indexPath.section]
        // 取出对应组对应行的模型
        let emoticon = package.emoticons[indexPath.item]
        // 赋值给cell
        cell.emoticon = emoticon
        
        return cell
    }
    
    // 选中某一个cell时调用
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 处理最近表情, 将当前使用的表情添加到最近表情的数组中
        let emoticon = packages[indexPath.section].emoticons[indexPath.item]
        emoticon.times = emoticon.times + 1
        packages[0].appendEmoticons(emoticon: emoticon)
        //        collectionView.reloadSections(NSIndexSet(index: 0))
        
        //回调通知使用者当前点击了那个表情
        emoticonDidSelectedCallBack(emoticon)
    }
    
    @objc func itemClick(_ item: UIBarButtonItem)
    {
        let indexPath = IndexPath(item: 0, section: item.tag)
        collectionVeiw.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
}

class EmoticonCell: UICollectionViewCell {
    
    var emoticon: Emoticon?
    {
        didSet{
            // 判断是否是图片表情
            if emoticon!.chs != nil
            {
                iconButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath!), for: .normal)
            }else
            {
                // 防止重用
                iconButton.setImage(nil, for: .normal)
            }
            
            // 设置emoji表情
            // 注意: 加上??可以防止重用
            iconButton.setTitle(emoticon!.emojiStr ?? "", for: .normal)
            
            // 判断是否是删除按钮
            if emoticon!.isRemoveButton
            {
                iconButton.setImage(UIImage.init(named: "faceDelete"), for: .normal)
                iconButton.setImage(UIImage.init(named: "faceDelete"), for: .highlighted)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    /**
     初始化UI
     */
    private func setupUI()
    {
        contentView.addSubview(iconButton)
        iconButton.backgroundColor = UIColor.orange
        iconButton.frame = contentView.bounds.insetBy(dx: 4, dy: 4)
        iconButton.isUserInteractionEnabled = false
    }
    
    // MARK: - 懒加载
    private lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        return btn
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// 自定义布局
class EmoticonLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        // 设置cell相关属性
        let width = collectionView!.bounds.width / 7
        itemSize = CGSize(width: width, height: width)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        // 设置collectionview相关属性
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        // 注意:最好不要乘以0.5, 因为CGFloat不准确, 所以如果乘以0.5在iPhone4/4身上会有问题
        let y = (collectionView!.bounds.height - 3 * width) * 0.45
        collectionView?.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
        
    }
}

