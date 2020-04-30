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
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "订单列表"
    }
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayLayouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = self.viewModel.arrayLayouts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellData.getCurrentClass(),for: indexPath) as? YHAsyncBaseTBCell {
            cell.selectionStyle = .none
            cell.setupCellData(cellData)

        }
        
        
        return UITableViewCell()
        
    }
}
