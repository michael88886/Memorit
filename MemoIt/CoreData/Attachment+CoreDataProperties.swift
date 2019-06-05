//
//  Attachment+CoreDataProperties.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//
//

import Foundation
import CoreData


extension Attachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attachment> {
        return NSFetchRequest<Attachment>(entityName: "Attachment")
    }

    @NSManaged public var attachID: String?
    @NSManaged public var attachType: String?
    @NSManaged public var attachmentMemo: AttachmentMemo?

}
