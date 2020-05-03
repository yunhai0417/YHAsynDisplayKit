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

