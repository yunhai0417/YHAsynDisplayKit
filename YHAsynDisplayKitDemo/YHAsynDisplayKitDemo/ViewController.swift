//
//  ViewController.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/3/28.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        self.reloaditems()
        
        
        //初始化一个指定尺寸的字体对象
        let font = UIFont.systemFont(ofSize: 24)
        //输出字体对象的上行高度，即基线与字形最高点之间的距离。
        print("font.ascender: \(font.ascender)")
        //输出字体对象的下行高度，即基线与字形最低点之间的距离。
        print("font.descender: \(font.descender)")
        //输出基线到大写字母最高点的距离。
        print("font.capHeight: \(font.capHeight)")
        //输出基线至非突出的小写字母最高点的距离。
        print("font.xHeight: \(font.xHeight)")
        //输出一行字形的最大高度，等于前三个属性值的和。
        print("font.lineHeight: \(font.lineHeight)")
        //输出行距的数值，即上方一行的最低点，与下方一行的最高点的距离
        print("font.leading: \(font.leading)")
        
    }
    
    fileprivate func reloaditems() {
        self.array.append("基本使用-简单自定义数据渲染")
        self.array.append("高级使用-简单自定义数据渲染")
        self.array.append("高级使用-计算文本宽高及计算")
        self.array.append("基本使用-图片倒角计算")
        self.array.append("终极使用-美团订单列表")
        self.tableview.reloadData()
    }

}

extension ViewController :UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "xxxx")
        cell.textLabel?.text = self.array[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let newVc = AdvanceViewController.init()
            self.navigationController?.pushViewController(newVc, animated: true)
            return
        }
        
        if indexPath.row <= 3 {
            let newVc = BaseUseViewController.init()
            newVc.tempIndex = indexPath.row
            self.navigationController?.pushViewController(newVc, animated: true)
        } else {
            let newVc = DemoOrderListViewController.init()
            self.navigationController?.pushViewController(newVc, animated: true)

        }
        
    }
}

