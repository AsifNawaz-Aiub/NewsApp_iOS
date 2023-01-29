//
//  NewsViewModel.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 12/1/23.
//

import Foundation

struct NewsModel: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}

// Article Table
//let sourceId: String?
//let sourceName: String
//let author: String?
//let title: String
//let description: String?
//let url: String
//let urlToImage: String?
//let publishedAt: String
//let content: String?
//let category: String?
