//
//  CoreDataManager.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 13/1/23.
//


import Foundation
import UIKit
import CoreData
enum BookmarkSaveError : Error {
    case invalidBookmark
}
class CoreDataManager {
    
    static let shared = CoreDataManager()
    //var count = 0
    private init() {}

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func addArticles(newsFetchedFromAPi: NewsModel,category : String? = nil,completion: (Result<[ArticlesModel],Error>)->()){
        var articleList:[ArticlesModel] = []
        for eachArticel in newsFetchedFromAPi.articles{
            
            let articles = ArticlesModel(context: context)
            articles.sourceId = eachArticel.source.id
            articles.sourceName = eachArticel.source.name
            articles.category = category
            articles.title = eachArticel.title
            articles.author = eachArticel.author
            articles.content = eachArticel.content
            articles.desc = eachArticel.description
            articles.urlToImage = eachArticel.urlToImage
            articles.url = eachArticel.url
            articles.publishedAt = eachArticel.publishedAt
            
            do{
                try context.save()
                articleList.append(articles)
            }catch{
                print(error)
                completion(.failure(error))
            }
        }
        completion(.success(articleList))
    }
    
    func fetchAllArtciles(category : String? = nil, searchQuery : String? = nil) -> Result<[ArticlesModel],Error>{
        let fetchReq = NSFetchRequest<ArticlesModel>(entityName: "ArticlesModel")
        
        if let _ = category, searchQuery == nil {
            let predicate = NSPredicate(format: "category == %@", category!)
            fetchReq.predicate = predicate
        }
        if let _ = searchQuery, let _ = category {
            let predicate = NSPredicate(format: "category == %@ && title CONTAINS [c] %@", category!, searchQuery!)
            fetchReq.predicate = predicate
        }
//        else {
//            let predicate = NSPredicate(format: "category == nil")
//            fetchReq.predicate = predicate
//        }
        do{
            let articles = try context.fetch(fetchReq)
            return (.success(articles))
        }catch{
            print(error)
            return (.failure(error))
        }
    
    }
    
    func deleteAllArticle(category : String? = nil){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticlesModel")
        if let _ = category {
            let predicate = NSPredicate(format: "category == %@", category!)
            fetchRequest.predicate = predicate
        }
//        else {
//            let predicate = NSPredicate(format: "category == nil")
//            fetchRequest.predicate = predicate
//        }
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
        } catch let error as NSError {
            print(error)
        }

    }
    
    func addBookmark(bookmarkToAdd: ArticlesModel, completion: (Result<BookmarksModel,Error>)->()){
        
        let result = fetchAllBookmarks(category: nil, url: bookmarkToAdd.url )
     
      
        do{
            switch result {
            case .success(let existingBookmark) :
                if existingBookmark.count == 0{
                    let bookMark = BookmarksModel(context: context)
                    bookMark.sourceName = bookmarkToAdd.sourceName
                    bookMark.author = bookmarkToAdd.author
                    bookMark.content = bookmarkToAdd.content
                    bookMark.publishedAt = bookmarkToAdd.publishedAt
                    bookMark.urlToImage = bookmarkToAdd.urlToImage
                    bookMark.url = bookmarkToAdd.url
                    bookMark.title = bookmarkToAdd.title
                    bookMark.desc = bookmarkToAdd.desc
                    bookMark.category = bookmarkToAdd.category
                    bookMark.sourceId = bookmarkToAdd.sourceId
                    try context.save()
                    completion(.success(bookMark))
                }else{
                    throw BookmarkSaveError.invalidBookmark
                }
            case .failure(let error):
                throw error
            }
        }catch{
            print(error)
            completion(.failure(error))
        }
        
    }
    func fetchAllBookmarks(category : String? = nil,url : String? = nil,searchQuery : String? = nil) -> Result<[BookmarksModel],Error>{
        let fetchRequest = NSFetchRequest<BookmarksModel>(entityName: "BookmarksModel")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: false)]
        if let _ = category {
            let predicate = NSPredicate(format: "category == %@", category!)
            fetchRequest.predicate = predicate
        }
        if let _ = searchQuery {
            let predicate = NSPredicate(format: "title CONTAINS [c] %@",searchQuery!)
            fetchRequest.predicate = predicate
        }
        if let _ = url {
            let predicate = NSPredicate(format: "url == %@", url!)
            fetchRequest.predicate = predicate
        }
        do{
            let bookMarks = try context.fetch(fetchRequest)
            return (.success(bookMarks))
        }catch{
            print(error)
            return (.failure(error))
        }
    
    }
    func deleteBookmark( bookmarkToDelete : BookmarksModel) {
        context.delete(bookmarkToDelete)
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
