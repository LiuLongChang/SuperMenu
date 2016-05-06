//
//  ViewController.swift
//  SuperMenu
//
//  Created by langyue on 16/5/4.
//  Copyright © 2016年 langyue. All rights reserved.
//

import UIKit

class ViewController: UIViewController,SuperMenuDelegate,SuperMenuDataSource {
    
    
    var menu : SuperMenu!
    
    
    var sort  = ["排序", "智能排序", "销量最高", "距离最近", "评分最高", "起送价最低", "送餐速度最快"];
    var choose = ["筛选", "立减优惠", "预定优惠", "特价优惠", "折扣商品", "进店领券", "下单返券"];
    var classify = ["全部", "新店特惠", "连锁餐厅", "家常快餐", "地方菜", "特色小吃", "日韩料理", "西式快餐", "烧烤海鲜"]
    
    
    var jiachang = ["家常炒菜", "黄焖J8饭", "麻辣烫", "盖饭"];
    var difang = ["湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜"];
    var tese = ["湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜"];
    var rihan = ["湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜"];
    var xishi = ["湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜"];
    var shaokao = ["湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜", "湘菜"];
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        menu = SuperMenu(origin: CGPointMake(0, 64),height:44)
        menu.delegate = self
        menu.dataSource = self
        self.view.addSubview(menu)
        menu.selectDeafultIndexPath()
        
        
    }

    
    func numberOfColumnsInMenu(menu: SuperMenu) -> NSInteger {
        return 3
    }
    
    func menu(menu: SuperMenu, numberOfRowsInColumn column: NSInteger) -> NSInteger {
        
        if column == 0 {
            return self.classify.count
        }else if(column == 1){
            return self.sort.count
        }else{
            return self.choose.count
        }
        
    }
    
    
    
    
    func menu(menu:SuperMenu, imageNameForRowAtIndexPath indexPath:LbkIndexPath)->NSString{
        
        if indexPath.column == 0 || indexPath.column == 1 {
            return "baidu"
        }
        return ""
    }
    
    
    
    
    func menu(menu:SuperMenu,titleForRowAtIndexPath indexPath:LbkIndexPath)->NSString{
        if indexPath.column == 0 {
            return self.classify[indexPath.row!]
        }else if(indexPath.row == 1){
            return self.sort[indexPath.row!]
        }else{
            return self.choose[indexPath.row!]
        }
    }
    
    
    func menu(menu: SuperMenu, imageForItemsInRowAtIndexPath indexPath: LbkIndexPath) -> NSString {
        if indexPath.column == 0 && indexPath.item >= 0 {
            return "baidu"
        }
        return ""
    }
    
    
    
    func menu(menu: SuperMenu, detailTextForRowAtIndexPath indexPath: LbkIndexPath) -> NSString {
        if indexPath.column < 2 {
            return  NSNumber(int:( Int32(arc4random()%1000) )).stringValue
        }
        return ""
    }
    
    
    
    func menu(menu: SuperMenu, detailTextForItemsInRowAtIndexPath indexPath: LbkIndexPath) -> NSString {
        return  NSNumber(int:( Int32(arc4random()%1000) )).stringValue
    }
    
    
    
    func menu(menu: SuperMenu, numberOfItemsInRow row: NSInteger, inColumn column: NSInteger) -> NSInteger {
        
        if column == 0 {
            if row == 3 {
                return self.jiachang.count
            }else if(row == 4){
                return self.difang.count
            }else if(row == 5){
                return self.tese.count
            }else if(row == 6){
                return self.rihan.count
            }else if(row == 7){
                return self.xishi.count
            }else if(row == 8){
                return self.shaokao.count
            }
        }
        return 0
    }
    
    
    
    
    func menu(menu: SuperMenu, titleForItemsInRowAtIndexPath indexPath: LbkIndexPath) -> NSString {
        
        let row = indexPath.row
        if indexPath.column == 0 {
            
            
            
            
            if row == 3 {
                return self.jiachang[indexPath.item!]
            }else if(row == 4){
                return self.tese[indexPath.item!]
            }else if(row == 5){
                return self.rihan[indexPath.item!]
            }else if(row == 6){
                return self.xishi[indexPath.item!]
            }else if(row == 7){
                return self.shaokao[indexPath.item!]
            }
            
        }
        
        return ""
    }
    
    
    func menu(menu: SuperMenu, didSelectRowAtIndexPath indexPath: LbkIndexPath) {
        
        if indexPath.item >= 0 {
            print("点击了 %ld - %ld - %ld 项目",indexPath.column,indexPath.row,indexPath.item)
        }else{
            print("点击了 %ld - %ld",indexPath.column,indexPath.row)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

