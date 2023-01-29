//
//  BookmarksModel+CoreDataProperties.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 17/1/23.
//
//

import Foundation
import CoreData


extension BookmarksModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarksModel> {
        return NSFetchRequest<BookmarksModel>(entityName: "BookmarksModel")
    }

    @NSManaged public var author: String?
    @NSManaged public var category: String?
    @NSManaged public var content: String?
    @NSManaged public var desc: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var sourceId: String?
    @NSManaged public var sourceName: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?

}

extension BookmarksModel : Identifiable {

}
