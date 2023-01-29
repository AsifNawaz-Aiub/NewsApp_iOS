//
//  NewsCoreDataModel.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 13/1/23.
//

import Foundation

struct NewsCoreDataModel: Codable {
    let sourceId: String?
    let sourceName: String
    let category : String
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

