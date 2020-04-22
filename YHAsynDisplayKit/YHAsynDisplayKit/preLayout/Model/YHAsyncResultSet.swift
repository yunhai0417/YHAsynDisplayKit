//
//  YHAsyncResultSet.swift
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

public class YHAsyncResultSet: NSObject {
    
    // 列表业务数据
    var businessItems = [YHAsyncBusinessModel]()
    
    // 当涉及分页机制时，其代表总页数
    var pageSize:NSInteger = 0
    
    // 表示当前处于第几页
    var currentPage:NSInteger = 0
    
    // 表示是否还有分页数据, 通常情况下  hasMore = (currentPage = pageSize - 1) > 0
    var hasMore:Bool = false
    
    /**
     * 重置所有业务数据，一般情况下由预排版内部负责调用
     */
    
    public func resultReset(){
        self.pageSize = 0
        self.currentPage = 0
        self.businessItems.removeAll()
    }
    
    /**
     * 添加一条数据，一般情况下由engine负责调用
     * @param item 一条业务数据
     */
    
    public func appendItem(_ item:YHAsyncBusinessModel) {
        self.businessItems.append(item)
    }
    
    /**
    * 添加一批业务数据，一般情况下由YHAsyncBaseViewModel负责调用
    * @param items  业务数据
    */
    
    public func appendItems(_ items:[YHAsyncBusinessModel]) {
        self.businessItems.append(contentsOf: items)
    }
    
    /**
    * 删除一条业务数据
    * @param item  业务数据
    */
    
    public func deleteItem(_ item:YHAsyncBusinessModel) {
        self.businessItems.removeAll { model -> Bool in
            return model == item
        }
    }
}
