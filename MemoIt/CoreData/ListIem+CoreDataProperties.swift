//
//  ListIem+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import UIKit
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var color: UIColor!
    @NSManaged public var isDone: Bool
    @NSManaged public var title: String!
    @NSManaged public var reminder: NSDate?
    @NSManaged public var listMemo: ListMemo?

}
