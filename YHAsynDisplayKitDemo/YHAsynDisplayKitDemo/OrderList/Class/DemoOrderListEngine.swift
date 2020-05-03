//
//  DemoOrderListEngine.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/24.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class DemoOrderListEngine: YHAsyncBaseEngine {
   
    override func reloadDataWithParams(_ params: [String : Any]?, completion inCompletion: YHAsyncEngineLoadCompletion?) {
        if self.loadState == YHAsyncEngineLoadState.loading {
            return
        }
        self.loadState = YHAsyncEngineLoadState.loading
        
        guard let jsonData = self.readLocalFileWithName("orderlist") else { return }
        guard let arr = jsonData.object(forKey: "orderlist") as? NSArray else { return }
        var array = [DemoOrderModel]()
        for item in arr {
            if let dic = item as? NSDictionary {
                let model = DemoOrderModel.init(dic)
                array.append(model)
            }
        }
        
        self.resultSet.resultReset()
        self.resultSet.appendItems(array)
        
        self.loadState = YHAsyncEngineLoadState.loaded
        
        if let completion = inCompletion {
            completion(self.resultSet,nil)
        }
        
    }

    fileprivate func readLocalFileWithName(_ name:String) -> NSDictionary? {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else { return nil }
        guard let urlString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.init(charactersIn: "#%^{}\"[]|\\<> ").inverted) else { return nil }
            
        if let data = NSData.init(contentsOfFile: urlString){
            if let jsonObj:NSDictionary = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                return jsonObj
            }
        }
        
        return nil
    }
}
