//
//  Memo+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import UIKit
import CoreData


extension Memo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memo> {
        return NSFetchRequest<Memo>(entityName: "Memo")
    }

    @NSManaged public var archived: Bool
    @NSManaged public var color: UIColor!
    @NSManaged public var timeModified: NSDate!
    @NSManaged public var title: String!
    @NSManaged public var category: Category?
    @NSManaged public var label: MemoLabel?

}
