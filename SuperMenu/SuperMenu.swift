//
//  SuperMenu.swift
//  SuperMenu
//
//  Created by langyue on 16/5/4.
//  Copyright © 2016年 langyue. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore





protocol SuperMenuDelegate {
    
    func menu(menu:SuperMenu,didSelectRowAtIndexPath indexPath:LbkIndexPath)
    
}


protocol SuperMenuDataSource {
    
    
    func menu(menu:SuperMenu, numberOfRowsInColumn column:NSInteger)->NSInteger
    func menu(menu:SuperMenu,titleForRowAtIndexPath indexPath:LbkIndexPath)->NSString
    
    
    //有多少个column 默认为1列
    func numberOfColumnsInMenu(menu:SuperMenu)->NSInteger
    //第column列， 没行的image
    func menu(menu:SuperMenu, imageNameForRowAtIndexPath indexPath:LbkIndexPath)->NSString
    //detail text
    func menu(menu:SuperMenu, detailTextForRowAtIndexPath indexPath:LbkIndexPath)->NSString
    //某列的某行item数量 如果有 则说明有二级菜单 反之必然
    func menu(menu:SuperMenu, numberOfItemsInRow row:NSInteger,inColumn column:NSInteger)->NSInteger
   
    
    //如果有二级菜单 则实现下列协议
    func menu(menu:SuperMenu,titleForItemsInRowAtIndexPath indexPath:LbkIndexPath)->NSString
    func menu(menu:SuperMenu,imageForItemsInRowAtIndexPath indexPath:LbkIndexPath)->NSString
    func menu(menu:SuperMenu,detailTextForItemsInRowAtIndexPath indexPath:LbkIndexPath)->NSString
}





let Screen_Width = UIScreen.mainScreen().bounds.size.width
let Screen_Height = UIScreen.mainScreen().bounds.size.height
let kTableViewCellHeight = 44

let kTextColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
let kDetailTextColor = UIColor.init(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1)
let kSeparatorColor = UIColor.init(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1)
let kCellBgColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
let kTextSelectColor = UIColor.init(red: 246/255.0, green: 79/255.0, blue: 0/255.0, alpha: 1)

let kTableViewHeight = 300



struct _dataSourceFlag {
    var numberOfRowsInColumn = 1;
    var numberOfItemsInRow = 1;
    var titleForRowsAtIndexPath = 1;
    var titleForItemInRowAtIndexPath = 1;
    var imageNameForRowAtIndexPath = 1;
    var imageNameForItemInRowAtIndexPath = 1;
    var detailTextForRowAtIndexPath = 1;
    var detailTextForItemInRowAtIndexPath = 1;
}




typealias completeBlock = ()->(Void)


class SuperMenu: UIView,UITableViewDelegate,UITableViewDataSource {

    
    var dataSourceFlag = _dataSourceFlag()
    
    
    var tableViewHeight : CGFloat?
    var origin : CGPoint!
    var height : CGFloat!
    var numberOfColumn : NSInteger?
    var isShow: Bool?
    var backGroundView : UIView!
    var leftTableView : UITableView!
    var rightTableView : UITableView!
    var currentSelectedColumn : NSInteger?
    var bottomLine : UIView!
    
    
    var titles : NSArray?
    var indicators : NSArray?
    var bgLayers : NSArray?
    
    
    var delegate: SuperMenuDelegate?
    
    
    private var _dataSource : SuperMenuDataSource?
    var dataSource: SuperMenuDataSource? {
        
        set{
            
            self._dataSource = newValue
            numberOfColumn = dataSource?.numberOfColumnsInMenu(self)
            
            currentSelectedRows = NSMutableArray(capacity:numberOfColumn!)
            for _ in 0...numberOfColumn!-1 {
                currentSelectedRows?.addObject(NSNumber(int:0))
            }
            
            
            dataSourceFlag.numberOfRowsInColumn = 1
            dataSourceFlag.numberOfItemsInRow = 1
            dataSourceFlag.titleForRowsAtIndexPath = 1
            dataSourceFlag.titleForItemInRowAtIndexPath = 1
            dataSourceFlag.imageNameForRowAtIndexPath = 1
            dataSourceFlag.imageNameForItemInRowAtIndexPath = 1
            dataSourceFlag.detailTextForRowAtIndexPath = 1
            dataSourceFlag.detailTextForItemInRowAtIndexPath = 1
            
            
            let numberOfLine = Screen_Width /  CGFloat(self.numberOfColumn!)
            let numberOfBlackground = Screen_Width / CGFloat(self.numberOfColumn!)
            let numberOfTextLayer = Screen_Width / ( CGFloat(self.numberOfColumn!) * CGFloat(2))

            
            //底部的line显示
            bottomLine?.hidden = false
            
            
            let tempTitles = NSMutableArray(capacity:numberOfColumn!)
            let tempIndicators = NSMutableArray(capacity:numberOfColumn!)
            let tempBgLayers = NSMutableArray(capacity:numberOfColumn!)
            
            
            
            //画出菜单
            for i in 0...numberOfColumn!-1 {
                
                //backgrounLayer
                let positionForBackgroundLayer = CGPointMake((CGFloat(i) + 0.5) * numberOfBlackground, self.height! / 2)
                let bgLayer = self.createBgLayerWithPosition(positionForBackgroundLayer, color: UIColor.whiteColor())
                self.layer.addSublayer(bgLayer)
                tempBgLayers.addObject(bgLayer)
                
                //titleLayer
                var titleString : NSString?
                if ((isClickHaveItemValid == false) && (dataSource?.menu(self, numberOfItemsInRow: 0, inColumn: 1) > 0) && (dataSourceFlag.numberOfItemsInRow != 0)) {
                    titleString = dataSource?.menu(self, titleForItemsInRowAtIndexPath: LbkIndexPath.indexPathWithColumn(i, row: 0, item: 0))
                }else{
                    titleString = dataSource?.menu(self, titleForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(i, row: 0))
                }
                
                
                let positionForTitle = CGPointMake((CGFloat(i) * 2 + 1) * numberOfTextLayer, self.height! / 2)
                
                let textLayer = self.createTitleLayerWithString(titleString!, position: positionForTitle, color: self.textColor)
                self.layer.addSublayer(textLayer)
                tempTitles.addObject(textLayer)
                
                
                //indicatorLayer
                
                let indicatorPosition = CGPointMake(CGFloat(i+1) * numberOfLine - 10, self.height! / 2)
                let sharpLayer = self.createIndicatorWithPosition(indicatorPosition, color: self.indicatorColor!)
                self.layer.addSublayer(sharpLayer)
                tempIndicators.addObject(sharpLayer)
                
                
                
                
                //separatorLayer
                if i != self.numberOfColumn! - 1 {
                    
                    
                    let separatorPosition = CGPointMake(ceil((CGFloat(i)+1)*numberOfLine-1), self.height! / 2)
                    
                    let separatorLayer = self.createSeparatorWithPosition(separatorPosition, color: self.separatorColor!)
                    self.layer.addSublayer(separatorLayer)
                    
                }
                
            }
            
            titles = tempTitles.copy() as? NSArray
            indicators = tempIndicators.copy() as? NSArray
            bgLayers = tempBgLayers.copy() as? NSArray
            
        }
        get{
            
            return _dataSource
        }
    }
    
    
    
    
    private var _textColor:UIColor?
    var textColor: UIColor {
        
        set {
            self._textColor = newValue
        }
        get {
            return UIColor.blackColor()
        }
        
    }
    
    
    var selectedTextColor : UIColor?
    var detailTextColor : UIColor?
    
    
    private var _indicatorColor : UIColor?
    var indicatorColor : UIColor? {
        
        set {
            self._indicatorColor = newValue
        }
        
        get{
            return UIColor.blackColor()
        }
        
    }
    
    
    
    var detailTextFont : UIFont?
    
    
    private var _separatorColor : UIColor?
    var separatorColor  : UIColor? {
        
        set{
            self._separatorColor = newValue
        }
        get{
            return UIColor.blackColor()
        }
        
    }
    
    
    var fontSize : NSInteger?
    
    
    var currentSelectedRows : NSMutableArray?
    var isClickHaveItemValid : Bool?
    
    
    convenience init(origin:CGPoint,height:CGFloat){
        
        self.init(frame:CGRectMake(origin.x, origin.y, Screen_Width, height))
        
        
        self.origin = origin
        self.height = height
        self.isShow = false
        self.fontSize = 14
        self.currentSelectedColumn = -1
        self.isClickHaveItemValid = true
        self.textColor = kTextColor
        self.selectedTextColor = kTextSelectColor
        self.detailTextFont = UIFont.systemFontOfSize(11)
        self.separatorColor = kSeparatorColor;
        self.detailTextColor = kDetailTextColor
        self.indicatorColor = kDetailTextColor
        self.tableViewHeight = CGFloat(kTableViewHeight)
        
        //初始化两个TableView
       
        leftTableView = UITableView(frame: CGRectMake(origin.x + Screen_Width / 2, origin.y + self.frame.size.height, Screen_Width / 2, 0),style: .Plain)
        leftTableView.delegate = self
        leftTableView.dataSource = self
        leftTableView.rowHeight = CGFloat(kTableViewCellHeight)
        leftTableView.separatorColor = kSeparatorColor
        
        
        
        rightTableView = UITableView(frame:CGRectMake(origin.x + Screen_Width / 2, origin.y + self.frame.size.height, Screen_Width / 2, 0) ,style:.Plain)
        rightTableView.delegate = self
        rightTableView.dataSource = self
        rightTableView.rowHeight = CGFloat(kTableViewCellHeight)
        rightTableView.separatorColor = kSeparatorColor
        
        
        self.backgroundColor = UIColor.whiteColor()
        let tap = UITapGestureRecognizer(target: self,action: #selector(SuperMenu.menuTapped(_:)))
        self.addGestureRecognizer(tap)
        self.userInteractionEnabled = true
        
        
        backGroundView = UIView()
        backGroundView.frame = CGRectMake(origin.x, origin.y, Screen_Width, Screen_Height)
        backGroundView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        backGroundView.opaque = false
        let backTap = UITapGestureRecognizer(target: self,action: #selector(SuperMenu.backTapped(_:)))
        backGroundView.userInteractionEnabled = true
        backGroundView.addGestureRecognizer(backTap)
        
    
        bottomLine = UIView(frame:CGRectMake(0,self.height! - 0.5,Screen_Width,0.5))
        bottomLine.backgroundColor = kSeparatorColor
        bottomLine.hidden = true
        self.addSubview(bottomLine)
        
    }
    
    
    func selectDeafultIndexPath(){
        self.selectIndexPath(LbkIndexPath.indexPathWithColumn(0, row: 0))
    }

    
    //绘图
    //背景
    func createBgLayerWithPosition(position:CGPoint,color:UIColor)->CALayer{
        let layer = CALayer()
        layer.position = position
        layer.bounds = CGRectMake(0, 0, Screen_Width / CGFloat(self.numberOfColumn!), self.height! - 1)
        layer.backgroundColor = color.CGColor
        return layer
    }
    //标题
    func createTitleLayerWithString(string:NSString,position:CGPoint,color:UIColor)->CATextLayer{
        
        let size = self.calculateTitleSizeWithString(string)
        
        let layer = CATextLayer()
        let sizeWidth = (size.width < (self.frame.size.width / CGFloat(numberOfColumn!)) - 25) ? size.width : self.frame.size.width / CGFloat(numberOfColumn!) - 25
        layer.bounds = CGRectMake(0, 0, sizeWidth, size.height)
        layer.string = string
        layer.fontSize = CGFloat(self.fontSize!)
        layer.alignmentMode = kCAAlignmentCenter
        layer.truncationMode = kCATruncationEnd
        layer.foregroundColor = color.CGColor
        
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.position = position
        
        return layer
    }
    
    
    //计算string宽度
    func calculateTitleSizeWithString(string:NSString)->CGSize{
        
        let dic = [NSFontAttributeName:UIFont.systemFontOfSize(CGFloat(fontSize!))]
        let size = string.boundingRectWithSize(CGSizeMake(280, 0), options: [.TruncatesLastVisibleLine,.UsesLineFragmentOrigin,.UsesFontLeading], attributes: dic, context: nil).size
        return CGSizeMake( CGFloat(ceilf(Float(size.width))) + CGFloat(2), size.height)
    }
    
    //指示器
    func createIndicatorWithPosition(position:CGPoint,color:UIColor)->CAShapeLayer {
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(8, 0))
        path.addLineToPoint(CGPointMake(4, 5))
        path.closePath()
        
        layer.path = path.CGPath
        layer.lineWidth = 0.8
        layer.fillColor = color.CGColor
        
        
        
        let bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, .Butt, .Miter, layer.miterLimit)
        layer.bounds = CGPathGetBoundingBox(bound)
        layer.position = position
        
        
        return layer
        
    }
    
    
    //分割线
    func createSeparatorWithPosition(position:CGPoint,color:UIColor)->CAShapeLayer{
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(160, 0))
        path.addLineToPoint(CGPointMake(160, 20))
        
        layer.path = path.CGPath
        layer.lineWidth = 1
        layer.strokeColor = color.CGColor
        
        let bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth,CGLineCap.Butt,.Miter, layer.miterLimit)
        layer.bounds = CGPathGetBoundingBox(bound)
        layer.position = position
        
        return layer
        
    }
    
    
    
    
    //MARK  UITableView的dataSource和delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == leftTableView {
            
            if dataSourceFlag.numberOfRowsInColumn != 0 {
                return (dataSource?.menu(self, numberOfRowsInColumn: currentSelectedColumn!))!
            }else{
                return 0
            }
            
        }else{
            
            if dataSourceFlag.numberOfItemsInRow != 0 {
                
                let row = currentSelectedRows![currentSelectedColumn!].integerValue
                return (dataSource?.menu(self, numberOfItemsInRow: row, inColumn: currentSelectedColumn!))!
            }else{
                return 0
            }
            
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let ID : NSString = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(ID as String)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ID as String)
            cell?.textLabel?.textColor = textColor
            cell?.textLabel?.highlightedTextColor = selectedTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(CGFloat(fontSize!))
            if (dataSourceFlag.detailTextForRowAtIndexPath != 0) && (dataSourceFlag.detailTextForItemInRowAtIndexPath  != 0){
                cell?.detailTextLabel?.textColor = detailTextColor
                cell?.detailTextLabel?.font = detailTextFont
            }
            
        }
        
        if tableView == leftTableView {
            
            
            if dataSourceFlag.titleForRowsAtIndexPath != 0 {
                
                
                let str =  dataSource?.menu(self, titleForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: indexPath.row))
                
                
                
                cell?.textLabel?.text = String(str!)
                
                
                
                if dataSourceFlag.imageNameForRowAtIndexPath != 0 {
                    
                    let imgName = dataSource?.menu(self, imageNameForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: indexPath.row))
                    if imgName != nil && imgName?.length > 0 {
                        cell?.imageView?.image = UIImage(named: String(imgName))
                    }else{
                        cell?.imageView?.image = nil
                    }
                    
                }else{
                    cell?.imageView?.image = nil
                }
                
                //detailText
                if dataSourceFlag.detailTextForRowAtIndexPath != 0 {
                    
                    let str = dataSource?.menu(self, detailTextForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: indexPath.row))
                    cell!.detailTextLabel!.text = String(str!)
                }else{
                    cell!.detailTextLabel!.text = nil
                }
                
                
                //设置accessory
                let currentSelectRow = currentSelectedRows![currentSelectedColumn!].integerValue
                
                if indexPath.row == currentSelectRow {
                    
                    tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                }
                
                if (dataSourceFlag.numberOfItemsInRow != 0) && (dataSource?.menu(self, numberOfItemsInRow: indexPath.row, inColumn: currentSelectedColumn!) > 0){
                
                    cell?.accessoryView = UIImageView.init(image: UIImage(named:"accessory_normal"), highlightedImage: UIImage(named:"accessory_highlight"))
                }else{
                    cell!.accessoryView = nil
                }
               
            }
            
            
        }else{
            
         
            if dataSourceFlag.titleForItemInRowAtIndexPath != 0 {
                
                let currentSelectedRow = currentSelectedRows![currentSelectedColumn!].integerValue
                
                let str = dataSource?.menu(self, titleForItemsInRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: currentSelectedRow, item: indexPath.row))
                cell?.textLabel?.text = String(str!)
                
                if dataSourceFlag.imageNameForItemInRowAtIndexPath != 0 {
                    
                    let imgName = dataSource?.menu(self, imageForItemsInRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: currentSelectedRow, item: indexPath.row))
                    if imgName != nil && imgName?.length > 0 {
                        cell?.imageView?.image = UIImage(named: String(imgName))
                    }else{
                        cell?.imageView?.image = nil
                    }
                    
                }else{
                    cell?.imageView?.image = nil
                }
                                
                
                if dataSourceFlag.detailTextForItemInRowAtIndexPath != 0 {

                    
                    let str =
                    dataSource?.menu(self, detailTextForItemsInRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: currentSelectedRow, item: indexPath.row))
                    cell?.detailTextLabel?.text = String(str!)
                }else{
                    
                    cell?.textLabel?.text = nil
                }
               
            }
            
            if cell?.textLabel?.text == (titles![currentSelectedColumn!]).string {
                
                let currentSelectedRow = (currentSelectedRows![currentSelectedColumn!]).integerValue
                leftTableView?.selectRowAtIndexPath(NSIndexPath(forRow: currentSelectedRow,inSection:0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                rightTableView?.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            cell?.accessoryView = nil
            
        }
        return cell!
    }
    
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == leftTableView {
            
            let haveItem = self.setMenuWithSelectedRow(indexPath.row)
            let isClickHaveItemValid = (self.isClickHaveItemValid != nil) ? true : haveItem
            if isClickHaveItemValid && delegate != nil {
                delegate?.menu(self, didSelectRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: indexPath.row))
            }
            
        }else{
            //
            self.setMenuWithSelectedItem(indexPath.item)
            if delegate != nil  {
                delegate?.menu(self, didSelectRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: currentSelectedRows![currentSelectedColumn!].integerValue, item: indexPath.item))
            }
        }
        
    }
    
    
    //解决Cell分割线左侧留空的问题
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        cell.preservesSuperviewLayoutMargins  = false
    }
    
    /*
     *
     *
     *
    */
    //实现方法
    func selectDefaultIndexPath(){
        self.selectIndexPath(LbkIndexPath.indexPathWithColumn(0, row: 0))
    }
    //获取IndexPath所对应的字符串
    func titleForRowAtIndexPath(indexPath:LbkIndexPath)->NSString{
        return (self.dataSource?.menu(self, titleForRowAtIndexPath: indexPath))!
    }
    //菜单切换
    func selectIndexPath(indexPath:LbkIndexPath){
        
        
        if (delegate != nil) || (dataSource != nil) {
            return
        }
        
        if (dataSource?.numberOfColumnsInMenu(self) <= indexPath.column) || ((dataSource?.menu(self, numberOfRowsInColumn: indexPath.row!)) <= indexPath.row){
            return
        }
        
        
        
        let title : CATextLayer = titles![indexPath.column!] as! CATextLayer
        if indexPath.item < 0 {
            
            if (isClickHaveItemValid! == true) && (dataSource?.menu(self, numberOfItemsInRow: indexPath.row!, inColumn: indexPath.column!) > 0) {
                
                title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: LbkIndexPath.indexPathWithColumn(indexPath.column!, row: indexPath.row!, item: 0))
                
                delegate?.menu(self, didSelectRowAtIndexPath: LbkIndexPath.indexPathWithColumn(indexPath.column!, row: indexPath.row!, item: 0))
                
            }else{
                
                title.string = dataSource?.menu(self, titleForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(indexPath.column!, row: indexPath.row!))
                delegate?.menu(self, didSelectRowAtIndexPath: indexPath)
                
            }
            
            
            
            
            if currentSelectedRows?.count > indexPath.column {
                currentSelectedRows![indexPath.column!] = NSNumber(int: Int32(indexPath.row!))
            }
            
            let size = self.calculateTitleSizeWithString(String(title.string))
            let sizeWidth = (size.width < (self.frame.size.width / CGFloat(numberOfColumn!)) - 25) ? size.width : self.frame.size.width / CGFloat(numberOfColumn!) - 25
            title.bounds = CGRectMake(0, 0, sizeWidth, size.height)
            
        }else if (dataSource?.menu(self, numberOfItemsInRow: indexPath.row!, inColumn: indexPath.column!) > indexPath.column) {
            
            
            
            title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: indexPath)
            delegate?.menu(self, didSelectRowAtIndexPath: indexPath)
            if currentSelectedRows?.count > indexPath.column {
                currentSelectedRows![indexPath.column!] = NSNumber(int:Int32(indexPath.row!))
            }
            
            let size = self.calculateTitleSizeWithString(String(title.string))
            let sizeWidth = (size.width < (self.frame.size.width / CGFloat(numberOfColumn!)) - 25) ? size.width: self.frame.size.width / CGFloat(numberOfColumn!) - 25
            title.bounds = CGRectMake(0, 0, sizeWidth, size.height)
            
        }else if( dataSource?.menu(self, numberOfItemsInRow: indexPath.row!, inColumn: indexPath.column!) > indexPath.column ){
            title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: indexPath)
            delegate?.menu(self, didSelectRowAtIndexPath: indexPath)
            if currentSelectedRows?.count > indexPath.column {
                currentSelectedRows![indexPath.column!] = NSNumber(int: Int32(indexPath.row!))
            }
            let size = self.calculateTitleSizeWithString(String(title.string))
            let sizeWidth = size.width < ((self.frame.size.width / CGFloat(numberOfColumn!)) - 25) ? size.width : self.frame.size.width / CGFloat(numberOfColumn!) - 25
            title.bounds = CGRectMake(0, 0, sizeWidth, size.height)
        }
       
    }
    
    
    //数据重载
    func reloadData(){
        
        self.animateBackGroundView(backGroundView!, show: false) { () -> (Void) in
            self.animateTableView(nil, show: false, complete: { () -> (Void) in
                self.isShow = false
                let vc = self.dataSource
                self.dataSource = nil
                self.dataSource = vc
            })
        }
        
    }
    
    
    
    func menuTapped(gesture:UITapGestureRecognizer){
     
        if dataSource == nil {
            return
        }
        
        //触摸的地方的index
        let touchPoint = gesture.locationInView(self)
        let touchIndex :Int = Int(touchPoint.x / (Screen_Width / CGFloat(self.numberOfColumn!)))
        
        
        //将当前点击的column之外的column给收回
        for i in 0...numberOfColumn!-1 {
            
            if i != Int(touchIndex) {
                self.animateIndicator(indicators![i] as! CAShapeLayer, reverse: false, complete: { () -> (Void) in
                    self.animateTitle(self.titles![i] as! CATextLayer, show: false, complete: { () -> (Void) in
                        
                    })
                })
            }
            
        }
        
        
        if touchIndex == currentSelectedColumn! && isShow! {
            //收回menu
            self.animateIndicator(self.indicators![Int(touchIndex)] as! CAShapeLayer, background: self.backGroundView!, tableView: self.leftTableView!, title: self.titles![Int(touchIndex)] as! CATextLayer, reverse: false, complete: {
                self.currentSelectedColumn = NSInteger(touchIndex)
                self.isShow = false
            })
            
        }else{
            
            //弹出menu
            currentSelectedColumn = NSInteger(touchIndex)
            leftTableView.reloadData()
            if (dataSource != nil) && (dataSourceFlag.numberOfItemsInRow > 0) {
                rightTableView.reloadData()
            }
            
            
            self.animateIndicator(indicators![Int(touchIndex)] as! CAShapeLayer, background: self.backGroundView!, tableView: leftTableView, title: titles![Int(touchIndex)] as! CATextLayer, reverse: true, complete: {
                
                print("true")
                self.isShow = true
                
            })
            
            
        }
        
    }
    
    
    func backTapped(gesture:UITapGestureRecognizer){
        
        self.animateIndicator(indicators![currentSelectedColumn!] as! CAShapeLayer, background: self.backGroundView!, tableView: self.leftTableView!, title: self.titles![currentSelectedColumn!] as! CATextLayer, reverse: false) {
            self.isShow = true
        }
    }

    
    func setMenuWithSelectedRow(row:NSInteger)->Bool{
        
        
        currentSelectedRows![currentSelectedColumn!] = NSNumber(int: Int32(row))
        
        
        let title : CATextLayer = titles![currentSelectedColumn!] as! CATextLayer
        
        if (dataSourceFlag.numberOfItemsInRow > 0) && (dataSource?.menu(self, numberOfItemsInRow: row, inColumn: currentSelectedColumn!) > 0) {
            
            
            if isClickHaveItemValid == true {
                
                title.string = dataSource?.menu(self, titleForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: row))
                self.animateTitle(title, show: true, complete: { () -> (Void) in
                    self.rightTableView.reloadData()
                })
                
            }else{
                rightTableView.reloadData()
            }
            return false
            
        }else{
            
            title.string = dataSource?.menu(self, titleForRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: row))
            self.animateIndicator(indicators![currentSelectedColumn!] as! CAShapeLayer, background: backGroundView, tableView: leftTableView, title: title, reverse: false, complete: {
                self.isShow = false
            })
            
            return true
        }
        
    }
    
    
    func setMenuWithSelectedItem(item:NSInteger){
        
        let title : CATextLayer = titles![currentSelectedColumn!] as! CATextLayer
        let currentSelectedMenuRow = currentSelectedRows![currentSelectedColumn!].integerValue
        
        title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: LbkIndexPath.indexPathWithColumn(currentSelectedColumn!, row: currentSelectedMenuRow, item: item))
        
        
        self.animateIndicator(indicators![currentSelectedColumn!] as! CAShapeLayer, background: self.backGroundView!, tableView: self.leftTableView!, title: title, reverse: false) { 
            self.isShow = false
        }
    
    }
    
    
    func animateTitle(title:CATextLayer,show:Bool,complete:completeBlock){
        
        let size = self.calculateTitleSizeWithString(title.string as! NSString)
        
        let sizeWidth = (size.width < ((self.frame.size.width / CGFloat(numberOfColumn!))-25)) ? size.width : ((self.frame.size.width/CGFloat(numberOfColumn!) - 25))
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height)
        if show == false {
            title.foregroundColor = textColor.CGColor
        }else{
            title.foregroundColor = selectedTextColor?.CGColor
        }
        
        complete()
    }
    
    
    func animateIndicator(indicator:CAShapeLayer,background:UIView,tableView:UITableView,title:CATextLayer,reverse:Bool,complete:(()->Void)){
        
        self.animateIndicator(indicator, reverse: reverse) { () -> (Void) in
            self.animateTitle(title, show: reverse, complete: { () -> (Void) in
                self.animateBackGroundView(background, show: reverse, complete: { () -> (Void) in
                    
                    self.animateTableView(tableView, show: reverse, complete: { () -> (Void) in
                        
                    })
                    
                })
            })
        }
        
        complete()
    }
    
    
    
    func animateIndicator(indicator:CAShapeLayer,reverse:Bool,complete:completeBlock){
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0 ,0.2 ,1.0))
        
        let anim = CAKeyframeAnimation(keyPath:"transform.rotation")
        anim.values = reverse ? [NSNumber(int:0), NSNumber(double:M_PI)] : [NSNumber(double:M_PI), NSNumber(float:0)]
        
        if anim.removedOnCompletion == false {
            indicator.addAnimation(anim, forKey: anim.keyPath)
        }else{
            indicator.addAnimation(anim, forKey: anim.keyPath)
            indicator.setValue(anim.values?.last, forKeyPath: anim.keyPath!)
        }
        CATransaction.commit()
        
        if reverse == true{
            indicator.fillColor = self.selectedTextColor?.CGColor
        }else{
            indicator.fillColor = self.textColor.CGColor
        }
        complete()
    }
    
    
    func animateBackGroundView(view:UIView,show:Bool,complete:completeBlock){
        
        if show {
            
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            UIView.animateWithDuration(0.2, animations: {
                view.backgroundColor = UIColor(white: 0.0,alpha: 0.3)
            })
            
        }else{
            
            UIView.animateWithDuration(0.2, animations: {
                view.backgroundColor = UIColor(white: 0.0,alpha: 0.3)
                }, completion: { (finished) in
                    if finished {
                        view.removeFromSuperview()
                    }
            })
            
        }
        complete()
        
    }
    
    
    
    
    func animateTableView(tableView:UITableView?,show:Bool,complete:completeBlock){
        
        
        var haveItems = false
        if (dataSource != nil) {
            
            let num = leftTableView.numberOfRowsInSection(0)
            for i in 0...num-1 {
                
                if (dataSourceFlag.numberOfItemsInRow > 0) && (dataSource?.menu(self, numberOfItemsInRow: i, inColumn: self.currentSelectedColumn!) > 0) {
                    haveItems = true
                    break
                }
            }
           
        }
        
        
        
        if show {
            
            if haveItems {
                leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, Screen_Width / 2, 0)
                rightTableView.frame = CGRectMake(self.origin.x + Screen_Width,self.origin.y + self.height, Screen_Width/2, 0)
                self.superview?.addSubview(leftTableView)
                self.superview?.addSubview(rightTableView)
            }else{
                leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, Screen_Width, 0);
                self.superview?.addSubview(leftTableView)
            }
            
            
            
            let num = leftTableView.numberOfRowsInSection(0)
            let tableViewHeight = num * kTableViewCellHeight > kTableViewHeight ? kTableViewHeight : num * kTableViewCellHeight
            UIView.animateWithDuration(0.2, animations: {
                
                if haveItems{
                    
                    self.leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, Screen_Width / 2, CGFloat(tableViewHeight));
                    self.rightTableView.frame = CGRectMake(self.origin.x + Screen_Width/2,self.origin.y+self.height,Screen_Width/2,CGFloat(tableViewHeight));
                }else{
                    self.leftTableView!.frame = CGRectMake(self.origin.x, self.origin.y + self.height,Screen_Width, CGFloat(tableViewHeight));
                }
                
            })
            
            
        }else{
            
            UIView.animateWithDuration(0.2, animations: {
                
                if haveItems {
                    
                    self.leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, Screen_Width/2, 0);
                    self.rightTableView.frame = CGRectMake(self.origin.x + Screen_Width/2, self.origin.y+self.height, Screen_Width/2, 0);
                    
                }else{
                   self.leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height,Screen_Width, 0);
                }
                
            }, completion: { (finished) in
                    self.rightTableView.removeFromSuperview()
                    self.leftTableView.removeFromSuperview()
            })
            
        }
        complete()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}










class LbkIndexPath: NSObject {
    
    
    var row : NSInteger!
    var column : NSInteger!
    var item: NSInteger!
    
    
    convenience init(column:NSInteger,row:NSInteger){
        self.init()
        
        self.column = column
        self.row = row
        self.item = -1
        
    }
    
    convenience init(column:NSInteger,row:NSInteger,item:NSInteger){
        self.init(column:column,row: row)
        self.item = item
    }
    
    class func indexPathWithColumn(column:NSInteger,row:NSInteger)->LbkIndexPath{
        return LbkIndexPath(column: column,row: row)
    }
    
    class func indexPathWithColumn(column:NSInteger,row:NSInteger,item:NSInteger)->LbkIndexPath{
        return LbkIndexPath(column: column,row: row,item: item)
    }
    
    
}
