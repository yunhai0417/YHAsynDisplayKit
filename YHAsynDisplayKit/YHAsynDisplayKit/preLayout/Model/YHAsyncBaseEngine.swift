//
//  YHAsyncBaseEngine.swift
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


public typealias YHAsyncEngineLoadCompletion = (_ resultSet:YHAsyncResultSet, _ error: NSError?) -> Void

public enum YHAsyncEngineLoadState: NSInteger {
    case unload     = 0    //未载入状态
    case loading    = 1    //网络载入中
    case loaded     = 2    //网络载入完成
}

/*
整体负责
1.数据存储 Insert Delete Update Select操作
2.网络请求、数据解析
*/

open class YHAsyncBaseEngine: NSObject {

    // 结果集，业务列表数据、是否有下一页、当前处于第几页的封装，适用于流式列表结构
    public var resultSet:YHAsyncResultSet = YHAsyncResultSet()
    
    // 载入状态，用于标识当前网络请求的载入状态
    public var loadState = YHAsyncEngineLoadState.unload
    
    /**
    * reload请求
    * @param params 网络请求参数
    * @param completion 请求完成的回调block,该block返回(YHAsyncResultSet , error)
    */
    
    open func reloadDataWithParams(_ params:[String:Any]?, completion inCompletion:YHAsyncEngineLoadCompletion?){
        // override to subclass
    }
    
    /**
    * loadmore请求
    * @param params 网络请求参数
    * @param completion 请求完成的回调block,该block返回(YHAsyncResultSet , error)
    */
    
    public func loadMoreDataWithParams(_ params:[String:Any]?, completion inCompletion:YHAsyncEngineLoadCompletion?){
        // override to subclass
    }
    
    /**
    * insert请求
    * @param params 网络请求参数
    * @param completion 请求完成的回调block,该block返回(YHAsyncResultSet , error)
    */
    public func insertDataWithParams(_ params:[String:Any]?, completion inCompletion:YHAsyncEngineLoadCompletion?){
        // override to subclass
    }
}

//对数据的增删改查
extension YHAsyncBaseEngine {
    /**
     * 添加一条数据
     * @param item YHAsyncBusinessModel类型，标识一条业务数据
     */
    public func addItem(_ item:YHAsyncBusinessModel) {
        // 如果抽象程度较高，父类统一处理，否则子类覆盖
    }
    
    /**
    * 插入一条数据
    * @param item YHAsyncBusinessModel类型，标识一条业务数据
    * @param index 插入位置
    */
    
    public func insertItem(_ item:YHAsyncBusinessModel, atIndex index:NSInteger) {
        // 如果抽象程度较高，父类统一处理，否则子类覆盖
    }
    
    /**
    * 删除一条数据
    * @param item WMGBusinessModel *类型，标识一条业务数据
    */
    
    public func deleteItem(_ item:YHAsyncBusinessModel) {
        // 如果抽象程度较高，父类统一处理，否则子类覆盖
    }
    
    /**
    * 删除所有业务数据
    */
    
    public func deleteAllItem() {
        // 如果抽象程度较高，父类统一处理，否则子类覆盖
    }
}
