//
//  MemoLabel+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import Foundation
import CoreData


extension MemoLabel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoLabel> {
        return NSFetchRequest<MemoLabel>(entityName: "MemoLabel")
    }

    @NSManaged public var name: String?
    @NSManaged public var memo: NSSet?

}

// MARK: Generated accessors for memo
extension MemoLabel {

    @objc(addMemoObject:)
    @NSManaged public func addToMemo(_ value: Memo)

    @objc(removeMemoObject:)
    @NSManaged public func removeFromMemo(_ value: Memo)

    @objc(addMemo:)
    @NSManaged public func addToMemo(_ values: NSSet)

    @objc(removeMemo:)
    @NSManaged public func removeFromMemo(_ values: NSSet)

}
