//
//  News_ent+CoreDataProperties.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 17.02.2023.
//
//

import Foundation
import CoreData


extension News_ent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News_ent> {
        return NSFetchRequest<News_ent>(entityName: "News_ent")
    }

    @NSManaged public var author: String?
    @NSManaged public var title: String?
    @NSManaged public var descript: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var url: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var source_id: String?
    @NSManaged public var newsReadCounter: Int32
    @NSManaged public var imagesForNews: Data?

}

extension News_ent : Identifiable {

}
