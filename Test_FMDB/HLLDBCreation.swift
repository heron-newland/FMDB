//
//  HLLDBCreation.swift
//  Test_FMDB
//
//  Created by  bochb on 2019/5/20.
//  Copyright © 2019 com.heron. All rights reserved.
//

import UIKit
import FMDB

class HLLDBCreation: NSObject {
   static var path: String?
    override init() {
        super.init()
    }
    static func path(_ path: String) -> HLLDBCreation.Type{
        HLLDBCreation.path = path
        var path = HLLDBCreation.path
        if  path == nil {
            path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!.appending("/sqlite.db")
        }
        let db = FMDatabase(path: path!)
        return self
    }
    
    static func named(dbName: String) -> HLLDBCreation.Type {

        return self
    }
   
}
