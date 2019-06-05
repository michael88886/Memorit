//
//  ListMemo+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import Foundation
import CoreData


extension ListMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListMemo> {
        return NSFetchRequest<ListMemo>(entityName: "ListMemo")
    }

    @NSManaged public var listItem: NSOrderedSet?

}

// MARK: Generated accessors for listItem
extension ListMemo {

    @objc(insertObject:inListItemAtIndex:)
    @NSManaged public func insertIntoListItem(_ value: ListIem, at idx: Int)

    @objc(removeObjectFromListItemAtIndex:)
    @NSManaged public func removeFromListItem(at idx: Int)

    @objc(insertListItem:atIndexes:)
    @NSManaged public func insertIntoListItem(_ values: [ListIem], at indexes: NSIndexSet)

    @objc(removeListItemAtIndexes:)
    @NSManaged public func removeFromListItem(at indexes: NSIndexSet)

    @objc(replaceObjectInListItemAtIndex:withObject:)
    @NSManaged public func replaceListItem(at idx: Int, with value: ListIem)

    @objc(replaceListItemAtIndexes:withListItem:)
    @NSManaged public func replaceListItem(at indexes: NSIndexSet, with values: [ListIem])

    @objc(addListItemObject:)
    @NSManaged public func addToListItem(_ value: ListIem)

    @objc(removeListItemObject:)
    @NSManaged public func removeFromListItem(_ value: ListIem)

    @objc(addListItem:)
    @NSManaged public func addToListItem(_ values: NSOrderedSet)

    @objc(removeListItem:)
    @NSManaged public func removeFromListItem(_ values: NSOrderedSet)

}
