//
//  VoiceMemo+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import Foundation
import CoreData


extension VoiceMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoiceMemo> {
        return NSFetchRequest<VoiceMemo>(entityName: "VoiceMemo")
    }

    @NSManaged public var memoID: String?

}
