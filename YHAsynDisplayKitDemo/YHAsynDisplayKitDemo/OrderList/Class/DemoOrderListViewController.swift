//
//  DemoOrderListViewController.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/24.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class DemoOrderListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    lazy var viewModel:YHAsyncBaseViewModel = {
        let viewModel = DemoOrderListViewModel()
        viewModel.engine = DemoOrderListEngine()
        viewModel.owner = self
        return viewModel
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.backgroundColor = UIColor.white
        tableView.register(DemoOrderListCell.self, forCellReuseIdentifier: "DemoOrderListCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        YHAsyncTextDrawer.enableDebugMode()
        
        self.navigationController?.title = "订单列表"
        self.view.addSubview(self.tableView)
        
        self.viewModel.reloadDataWithParams(nil) {[weak self] (cellLayout, error) in
            self?.tableView.reloadData()
        }
        self.view.backgroundColor = UIColor.white
    }
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayLayouts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.arrayLayouts[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellData = self.viewModel.arrayLayouts[indexPath.row] as? DemoOrderCellData else {
            return UITableViewCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellData.getCurrentClass(),for: indexPath) as? DemoOrderListCell {
            cell.selectionStyle = .none
            cell.setupCellData(cellData)
            return cell
        }
        
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = self.viewModel.arrayLayouts[indexPath.row]
        
        if let orderModel = cellData.metaData as? DemoOrderModel {
            orderModel.poiName = "xxx"
            
            orderModel.setNeedsUpdateUIData()
        }
        
        self.viewModel.syncRefreshModelWithResultSet(self.viewModel.engine?.resultSet)
        self.tableView.reloadData()
    }
}
