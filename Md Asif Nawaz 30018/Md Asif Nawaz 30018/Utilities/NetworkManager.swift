//
//  NetworkManager.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 13/1/23.
//

import Foundation

class NetworkManager{
    
    static let shared = NetworkManager()
    private init(){
        loadPageAndPageSize()
    }
    var isPaginating = false
    static var categoryWisePage : [String: Int] = [:]
    func getNews(category : String? = nil, pageSize:Int = 10,completed : @escaping (Result<NewsModel,CustomError>)->() ){
        
        var urlString : String = ""
        if category == "All News"{
            let page = NetworkManager.categoryWisePage[category!]
            urlString = "https://newsapi.org/v2/top-headlines?country=us&pageSize=\(pageSize)&page=\(page!)&apiKey=\(Constants.apiKey)"
            print(urlString)
            
        }else{
            if let _ = category{
                let page = NetworkManager.categoryWisePage[category!]
                urlString = "https://newsapi.org/v2/top-headlines?country=us&category=\(category!)&pageSize=\(pageSize)&page=\(page!)&apiKey=\(Constants.apiKey)"
                print(urlString)
            }
        }
        guard let url = URL(string: urlString )
        else {
            completed(.failure(.invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url){[weak self] data, response, error in
            guard let self = self else {return}
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            guard let response =  response as? HTTPURLResponse, response.statusCode == 200 else{
                completed(.failure(.invalidResponse))
                return
            }
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            do{
                let jsonResponse = try JSONDecoder().decode(NewsModel.self, from: data)
                NetworkManager.categoryWisePage.updateValue(NetworkManager.categoryWisePage[category!]! + 1 , forKey: category!)
                print(NetworkManager.categoryWisePage)
                self.updatePageAndPageSize()
                completed(.success(jsonResponse))
                
            }catch{
                completed(.failure(.invalidData))
            }
            
            
        }
        task.resume()
    }
    func loadPageAndPageSize(){
        let defaults = UserDefaults.standard
        if let pageByCat = defaults.dictionary(forKey: "pageDictionary") {
            if let pageByCat = pageByCat as? [String:Int]
            {
                NetworkManager.categoryWisePage = pageByCat
            }
        }else{
            let initialPage : [String: Int] = ["All News" : 1,
                                               "Health":1,
                                               "Science":1,
                                               "Sports":1,
                                               "Business":1,
                                               "Technology":1,
                                               "Entertainment":1,
                                               "General":1]
            defaults.set(initialPage, forKey: "pageDictionary")
            
            if let pageByCat = defaults.dictionary(forKey: "pageDictionary") {
                if let pageByCat = pageByCat as? [String:Int]
                {
                    NetworkManager.categoryWisePage = pageByCat
                }
            }
        }
    
        
    }
    func updatePageAndPageSize(){
        let defaults = UserDefaults.standard
        defaults.set(NetworkManager.categoryWisePage, forKey: "pageDictionary")
    }
    func resetPageAndPageSize(category: String){
        //let defaults = UserDefaults.standard
        NetworkManager.categoryWisePage.updateValue(1, forKey: category)
        updatePageAndPageSize()
    }
}
//    func getPosts() {
//        indicator.startAnimating()
//
//
//            let _ = URLSession.shared.dataTask(with: url){ [weak self] data, response, error in
//
//                if let error = error {print("Error - \(error)")}
//                else{
//                    guard let data = data, let self = self else {return}
//                    do{
//                        let jsonResponse = try JSONDecoder().decode(NewsModel.self, from: data)
//
//                      let articleList = jsonResponse.articles
//                        self.articles = articleList
//                        print( self.articles)
//
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                            self.tableView.delegate = self
//                            self.tableView.dataSource = self
//                            self.indicator.stopAnimating()
//
//
//                        }
//                    }catch{
//                        print("Error Thrown")
//                    }
//                }
//
//            }.resume()
//      }
//}
//
//                    let articleList = jsonResponse.articles
//                    self.articles = articleList
//                    print( self.articles)
//
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.tableView.delegate = self
//                        self.tableView.dataSource = self
//                        self.indicator.stopAnimating()
//
//
//                    }

//func getNewsByCategory(category: String,completed : @escaping (Result<NewsModel,CustomError>)->()){
//
//    guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=21e422a61a7a46b080899d4a4ea1c4c1")
//    else {
//        completed(.failure(.invalidURL))
//        return
//    }
//    let task = URLSession.shared.dataTask(with: url){data, response, error in
//
//        if let _ = error {
//            completed(.failure(.unableToComplete))
//            return
//        }
//        guard let response =  response as? HTTPURLResponse, response.statusCode == 200 else{
//            completed(.failure(.invalidResponse))
//            return
//        }
//        guard let data = data else {
//            completed(.failure(.invalidData))
//            return
//        }
//    }
//    task.resume()
//}
