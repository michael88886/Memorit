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


extension ListIem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListIem> {
        return NSFetchRequest<ListIem>(entityName: "ListIem")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var isDone: Bool
    @NSManaged public var title: String?
    @NSManaged public var reminder: NSDate?
    @NSManaged public var listMemo: ListMemo?

}
