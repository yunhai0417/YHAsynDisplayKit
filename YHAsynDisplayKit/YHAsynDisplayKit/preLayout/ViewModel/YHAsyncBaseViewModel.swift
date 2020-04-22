//
//  YHAsyncBaseViewModel.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/22.
//  Copyright © 2020 YH. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Foundation

public typealias YHAsyncPreLayoutCompletionBlock = (_ cellLayouts:[YHAsyncBaseCellData], _ error:NSError?) -> Void
public typealias YHAsyncSafeInvokeBlock = () -> Void


public struct YHAsyncListState: OptionSet {
    public var rawValue: Int
    
    public typealias RawValue = Int
    
    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
    
    static let unLoad   = YHAsyncListState(rawValue: 1 << 0)    // initilize
    static let loading  = YHAsyncListState(rawValue: 1 << 1)    // 菊花转
    static let hasList  = YHAsyncListState(rawValue: 1 << 2)    // list数据
    static let empty    = YHAsyncListState(rawValue: 1 << 3)    // 空列表
    static let failed   = YHAsyncListState(rawValue: 1 << 4)    // 重新加载
    
    static let success  = YHAsyncListState(rawValue: YHAsyncListState.hasList.rawValue | YHAsyncListState.empty.rawValue)
    
    static let loaded  = YHAsyncListState(rawValue: YHAsyncListState.success.rawValue | YHAsyncListState.failed.rawValue)
}

let specificKey = DispatchSpecificKey<String>()

public class YHAsyncBaseViewModel: NSObject {
    // 预排版结果，该数组内装的对象均为排版结果
    // 对于该数组的增删改查务必要使用WMGBaseViewModel (Operation)中的方式由业务数据驱动
    // 排版模型和业务模型的关联关系如下图所示:
    //
    //  |-------------|  ---weak---->   |---------------|
    //  | LayoutModel |                 | BusinessModel |
    //  |-------------|  <——strong——    |---------------|
    //
    
    public var arrayLayouts:[YHAsyncBaseCellData] = [YHAsyncBaseCellData]()
    
    // 网络请求返回的错误
    public var error:NSError?
    
    // 当前列表状态，详见WMGListState说明
    public var listState = YHAsyncListState.unLoad
    
    // 松耦合方式连接engine和viewModel，通过桥接模式实现
    public var engine:YHAsyncBaseEngine?
    
    // viewModel的持有者
    public weak var owner:AnyObject?
    
    private var preLayoutQueue:DispatchQueue?
    
    public override init() {
        super.init()
        
        let queueName:String = "\(YHAsyncBaseViewModel.className())_prelayout_queue"
        let specificKeyValue = "\(YHAsyncBaseViewModel.className())_prelayout_queue_Value"
        preLayoutQueue = DispatchQueue(label: queueName)
        preLayoutQueue?.setSpecific(key: specificKey, value: specificKeyValue)
    }

}

//MARK: - private functions
extension YHAsyncBaseViewModel {
    fileprivate class func className() -> String {
        return NSStringFromClass(self)
    }
    
    fileprivate func prefreshModelWithResultSet(_ resultSet:YHAsyncResultSet, correspondingLayouts layouts: inout [YHAsyncBaseCellData]) {
        var resultLayouts = [YHAsyncBaseCellData]()
        
        for businessItem in resultSet.businessItems {
            //创建缓存
            if let _ = businessItem.cellData {
                let cellDataTmp = self.refreshCellDataWithMetaData(businessItem)
                cellDataTmp.metaData = businessItem
                businessItem.cellData = cellDataTmp
            } else {
                continue
            }
            
            if let cellData = businessItem.cellData {
                resultLayouts.append(cellData)
            }
            
        }
        layouts = resultLayouts
    }
    
    fileprivate func hanleNetWorkResult(_ resultSet:YHAsyncResultSet, error inError:NSError?, completion inCompletion:YHAsyncPreLayoutCompletionBlock?) {
        var layouts = [YHAsyncBaseCellData]()
        self.prefreshModelWithResultSet(resultSet, correspondingLayouts: &layouts)
        
        DispatchQueue.main.async {
            self.arrayLayouts.removeAll()
            if layouts.count > 0 {
                self.arrayLayouts.append(contentsOf: layouts)
            }
            self.safeInvoke {
                self.updateListLoadedState()
            }
            
            if let completion = inCompletion {
                completion(self.arrayLayouts, inError)
            }
        }
        
    }
    
    fileprivate func updateListLoadedState(){
        if let _ = self.error {
            if self.arrayLayouts.count > 0 {
                self.listState = YHAsyncListState.hasList
            } else {
                self.listState = YHAsyncListState.failed
            }
        } else {
            if self.arrayLayouts.count > 0 {
                self.listState = YHAsyncListState.hasList
            } else {
                self.listState = YHAsyncListState.empty
            }
        }
    }
}

 //MARK: - public functions
extension YHAsyncBaseViewModel {
    /**
    * 同步刷新方法，该方法会根据BaseModel的list刷新出最新的UI数据
    * 该方法是线程安全的
    * @param resultSet 网络返回结果的一层包装
    */
    
    func syncRefreshModelWithResultSet(_ resultSet:YHAsyncResultSet) {
        self.safeInvoke {
            var layouts = [YHAsyncBaseCellData]()
            self.prefreshModelWithResultSet(resultSet, correspondingLayouts: &layouts)
            
            self.arrayLayouts.removeAll()
            
            if layouts.count > 0 {
                self.arrayLayouts.append(contentsOf: layouts)
            }
        }
    }
    
    /**
    * 异步刷新方法，该方法会根据BaseModel的list刷新出最新的UI数据
    * 异步刷新完成的回调block,该block返回刷新完成的UI数据和Error.
    * 该方法是线程安全的
    * @param resultSet 网络返回结果的一层包装
    * @param completion 结果以block方式回调, block回调两个参数即是该类的两个只读变量arrayLayouts和error
    */
    
    func asyncRefreshModelWithResultSet(_ resultSet:YHAsyncResultSet, completion inCompletion:YHAsyncPreLayoutCompletionBlock?) {
        self.asyncSafeInvoke {
            var layouts = [YHAsyncBaseCellData]()
            self.prefreshModelWithResultSet(resultSet, correspondingLayouts: &layouts)
            
            DispatchQueue.main.async {
                self.arrayLayouts.removeAll()
                if layouts.count > 0 {
                    self.arrayLayouts.append(contentsOf: layouts)
                }
                if let completion = inCompletion {
                    completion(self.arrayLayouts, nil)
                }
            }
        }
    }
    
    /**
    * UI数据生成的单元方法，该方法会根据业务数据模型刷新出其对应的UI数据
    * 一般情况下，我们需要通过子类集成的方式覆写该方法实现
    * 注意：该方法会在多线程环境调用，注意保证线程安全
    * @param item 一条业务数据，这里的WMGBusinessModel是网络数据模型的一个抽象类,可根据业务实际进行改造.
    * @return WMGBaseCellData 列表场景下的抽象UI数据，亦即排版模型
    */

    func refreshCellDataWithMetaData(_ item:YHAsyncBusinessModel) -> YHAsyncBaseCellData {
        // override to subclass
        let cellData = YHAsyncBaseCellData.init()
        return cellData
    }
}

//MARK:- 增删改查 实际上是对Engine的对应封装,区别在于由ViewModel操控线程安全
extension YHAsyncBaseViewModel {
    /**
    * 插入一个item到指定的index位置
    * 当插入一条业务数据的时候，会在下次刷新排版的时机自动调取单条刷新方法生成对应的UI排版模型
    * 该方法是线程安全的
    * @param item 待插入的一项业务数据
    * @param index 要插入的位置
    */
    
    public func insertItem(_ newItem:YHAsyncBusinessModel, atIndex index:NSInteger) {
        if !Thread.isMainThread {
            return
        }
        
        self.safeInvoke {
            self.engine?.insertItem(newItem, atIndex: index)
            
            var layouts = [YHAsyncBaseCellData]()
            guard let resultSet = self.engine?.resultSet else { return }
            self.prefreshModelWithResultSet(resultSet, correspondingLayouts: &layouts)
            
            self.arrayLayouts.removeAll()
            
            if layouts.count > 0 {
                self.arrayLayouts.append(contentsOf: layouts)
            }
            
            self.updateListLoadedState()
        }
    }
    
    /**
    * 删除一项业务数据、及其对应的UI排版数据
    * 该方法是线程安全的
    * @param item 一个客户端定义的业务数据项
    */
    
    public func deleteItem(_ item:YHAsyncBusinessModel) {
        if !Thread.isMainThread {
            return
        }
        
        self.safeInvoke {
            self.engine?.deleteItem(item)
            
            var layouts = [YHAsyncBaseCellData]()
            guard let resultSet = self.engine?.resultSet else { return }
            self.prefreshModelWithResultSet(resultSet, correspondingLayouts: &layouts)
            
            self.arrayLayouts.removeAll()
            
            if layouts.count > 0 {
                self.arrayLayouts.append(contentsOf: layouts)
            }
            
            self.updateListLoadedState()
        }
    }
    
    /**
    * 将指定位置的数据替换为新的数据
    * 该方法是线程安全的
    * @param index 替换位置
    * @param item 一个客户端定义的业务数据项
    */
    
    public func replaceItemAtIndex(_ index:NSInteger, withItem item:YHAsyncBusinessModel) {
        guard let resultSet = self.engine?.resultSet else { return }

        let origin = resultSet.businessItems[index]
        self.deleteItem(origin)
        self.insertItem(item, atIndex: index)
    }
    
    /**
    * 移除所有业务数据，包含其对应的所有UI排版模型数据
    * 该方法是线程安全的
    */
    public func removeAllItems() {
        if !Thread.isMainThread {
            return
        }
        self.safeInvoke {
            self.engine?.deleteAllItem()
            self.arrayLayouts.removeAll()
            self.updateListLoadedState()
        }
    }
}

//MARK:- 网络请求 同样是对engine层面同名方法的封装
extension YHAsyncBaseViewModel {
    /**
    * 根据指定参数对业务数据进行重载
    * 我们把网络请求、磁盘等本地数据读取均定义到数据层。
    * 按此逻辑，该重载方法多数场景下代表着网络请求，当然也会包含读取本地磁盘等形式的数据
    * @param params 请求参数
    * @param completion 请求完成的回调,当实质性的数据重载请求完成之后，预排版内部会根据业务数据进行UI排版操作
    */
    
    public func reloadDataWithParams(_ params:[String:Any]?, completion inCompletion:YHAsyncPreLayoutCompletionBlock?) {
        self.error = nil
        self.asyncSafeInvoke {
            self.engine?.reloadDataWithParams(params, completion: { [weak self] (resultSet, inError) in
                self?.error = inError
                self?.hanleNetWorkResult(resultSet, error: inError, completion: inCompletion)
            })
        }
    }
    
    /**
    * 根据指定参数对业务数据进行增量加载，即我们常说的后项刷新
    * 我们把网络请求、磁盘等本地数据读取均定义到数据层。
    * 按此逻辑，该重载方法多数场景下代表着网络请求，当然也会包含读取本地磁盘等形式的数据
    * 请求完成的block回调arrayLayouts，即排版数据, 是当前整体业务数据List的排版结果
    * 注意，不仅仅是本次loadmore回来的数据，但是上次或者原有的业务数据并不会进行重新排版
    * @param params 请求参数
    * @param completion 请求完成的回调,当实质性的数据重载请求完成之后，预排版内部会根据新增业务数据进行UI排版操作
    */
    
    public func loadMoreDataWithParams(_ params:[String:Any]?, completion inCompletion:YHAsyncPreLayoutCompletionBlock?) {
        self.asyncSafeInvoke {
            self.engine?.loadMoreDataWithParams(params, completion: { [weak self](resultSet, inError) in
                self?.hanleNetWorkResult(resultSet, error: inError, completion: inCompletion)
            })
        }
    }
    
    /**
    * 将本地逻辑产生的一条数据插入到整体业务数据池中
    * @param params 请求参数
    * @param index 插入位置
    * @param completion 请求完成的回调
    */
    
    public func insertDataWithParams(_ params:[String:Any]?, withIndex index:NSInteger, completion inCompletion:YHAsyncPreLayoutCompletionBlock?){
        self.asyncSafeInvoke {
            self.engine?.insertDataWithParams(params, completion: {[weak self](resultSet, inError) in
                self?.hanleNetWorkResult(resultSet, error: inError, completion: inCompletion)
            })
        }
    }
}



//MARK: - 安全调用
extension YHAsyncBaseViewModel {
    /**
    * 同步安全调用
    * 该类其他方法均已线程安全，禁止再该block里面再调用同类的其他方法
    * @param block  : 对engine中的一切数据操作都放到这个block里面执行。
    */
    
    func safeInvoke(_ inBlock:YHAsyncSafeInvokeBlock?){
        guard let block = inBlock else { return }
        
        guard let preLayoutQueue = self.preLayoutQueue else { return }
        
        if preLayoutQueue.getSpecific(key: specificKey) == "\(YHAsyncBaseViewModel.className())_prelayout_queue_Value" {
            preLayoutQueue.sync {
                block()
            }
        }
    }
    
    /**
    * 异步安全调用
    * @param block  :对engine中的一切数据操作都放到这个block里面执行。
    */
    
    func asyncSafeInvoke(_ inBlock:YHAsyncSafeInvokeBlock?) {
        guard let block = inBlock else { return }
        self.preLayoutQueue?.async {
            block()
        }
    }
}
