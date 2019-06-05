//
//  Category+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import UIKit
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var color: UIColor?
    @NSManaged public var memo: NSSet?

}

// MARK: Generated accessors for memo
extension Category {

    @objc(addMemoObject:)
    @NSManaged public func addToMemo(_ value: Memo)

    @objc(removeMemoObject:)
    @NSManaged public func removeFromMemo(_ value: Memo)

    @objc(addMemo:)
    @NSManaged public func addToMemo(_ values: NSSet)

    @objc(removeMemo:)
    @NSManaged public func removeFromMemo(_ values: NSSet)

}
