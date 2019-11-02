//
//  Configuration.swift
//  INIADFES-2019-Reception
//
//  Created by Kentaro on 2019/11/02.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation

class Configuration{
    private var dict:NSDictionary!
    
    init(){
        let filePath = Bundle.main.path(forResource: "configuration", ofType: "plist")
        self.dict = NSDictionary.init(contentsOfFile: filePath!)
    }
    
    func value(forKey:String) -> String{
        guard let value = self.dict[forKey] as? String else{
            return ""
        }
        
        return value
    }
}
