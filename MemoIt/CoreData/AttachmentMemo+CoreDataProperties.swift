//
//  AttachmentMemo+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 5/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import Foundation
import CoreData


extension AttachmentMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AttachmentMemo> {
        return NSFetchRequest<AttachmentMemo>(entityName: "AttachmentMemo")
    }

    @NSManaged public var attributedString: NSAttributedString?
    @NSManaged public var memoID: String!
    @NSManaged public var attachments: NSOrderedSet?

}

// MARK: Generated accessors for attachments
extension AttachmentMemo {

    @objc(insertObject:inAttachmentsAtIndex:)
    @NSManaged public func insertIntoAttachments(_ value: Attachment, at idx: Int)

    @objc(removeObjectFromAttachmentsAtIndex:)
    @NSManaged public func removeFromAttachments(at idx: Int)

    @objc(insertAttachments:atIndexes:)
    @NSManaged public func insertIntoAttachments(_ values: [Attachment], at indexes: NSIndexSet)

    @objc(removeAttachmentsAtIndexes:)
    @NSManaged public func removeFromAttachments(at indexes: NSIndexSet)

    @objc(replaceObjectInAttachmentsAtIndex:withObject:)
    @NSManaged public func replaceAttachments(at idx: Int, with value: Attachment)

    @objc(replaceAttachmentsAtIndexes:withAttachments:)
    @NSManaged public func replaceAttachments(at indexes: NSIndexSet, with values: [Attachment])

    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: Attachment)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: Attachment)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSOrderedSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSOrderedSet)

}
