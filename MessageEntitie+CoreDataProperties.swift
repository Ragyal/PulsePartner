//
//  MessageEntitie+CoreDataProperties.swift
//  
//
//  Created by yannik grotkop on 13.06.19.
//
//

import Foundation
import CoreData

extension MessageEntitie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntitie> {
        return NSFetchRequest<MessageEntitie>(entityName: "MessageEntitie")
    }

    @NSManaged public var chatID: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var matchID: String?
    @NSManaged public var message: String?
    @NSManaged public var ownerID: String?
    @NSManaged public var read: Bool

}
