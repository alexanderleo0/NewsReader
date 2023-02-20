//
//  News_ent+CoreDataProperties.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 19.02.2023.
//
//

import Foundation
import CoreData


extension News_ent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News_ent> {
        return NSFetchRequest<News_ent>(entityName: "News_ent")
    }

    @NSManaged public var descript: String?
    @NSManaged public var image: Data?
    @NSManaged public var readCounter: Int32
    @NSManaged public var publishedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?

}

extension News_ent : Identifiable {

}
