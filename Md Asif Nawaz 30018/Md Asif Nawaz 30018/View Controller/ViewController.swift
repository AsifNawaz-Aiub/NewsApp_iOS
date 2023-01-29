//
//  ViewController.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 11/1/23.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
     
    var articles:[ArticlesModel] = []

    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    var initialRefresh : [String: Date] = ["All News" : Date(),"Health":Date(),"Science":Date(),"Sports":Date(),
                                           "Business":Date(),"Technology":Date(),"Entertainment":Date(),"General":Date()]
    var currentIndex = 0
    var doesCategoryTabChanged = false
    var timer = Timer()
    var refreshControl = UIRefreshControl()
    var currentCategory: String? =  "All News"
    var currentCategoryIndexpath : IndexPath = IndexPath(item: 0, section: 0)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var headerSmallImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        headerImage.layer.cornerRadius = 5
        headerSmallImage.layer.cornerRadius = 35
        headerSmallImage.image = UIImage.gifImageWithName("earthGif")
        indicator.hidesWhenStopped = true
        intializeSearchBar()

        if checkLastRefresh() ==  false{
            //CoreDataManager.shared.deleteAllArticle()
            //fetchAllNewsAndCacheInCoreData()
            loadCachedOrNewData(category:"All News")
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
        timer.fire()
      
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC =  segue.destination as? ArticleModalViewController{
            if let selectedIndex = tableView.indexPathForSelectedRow?.row
            {
                destinationVC.loadViewIfNeeded()
                destinationVC.article = articles[selectedIndex]
                destinationVC.tableHeader = "Author - \(articles[selectedIndex].author ?? "Unavilable"), Source - \(articles[selectedIndex].sourceName ?? " Unavilable") "
                let placeholderImage = UIImage(named: "default")
                destinationVC.modalArticleImage.image = placeholderImage
                if let imageURLString = articles[selectedIndex].urlToImage {
                    let imageURL = URL(string: imageURLString)
                    destinationVC.modalArticleImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
                }
                
            }
        }
    }

}
extension ViewController{
    
    func fetchAllNewsAndCacheInCoreData(category : String? = nil){
        indicator.startAnimating()
        NetworkManager.shared.getNews(category: category, completed: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure(let error):
                print(error)
                if error == .unableToComplete{
                    DispatchQueue.main.async {
                        self.present( Constants.showAlert(msg: "Check your network connection"), animated: true)
                        self.indicator.stopAnimating()
                        NetworkManager.shared.isPaginating = false
                    }
                }
            case .success(let news):
                DispatchQueue.main.async {
                    CoreDataManager.shared.addArticles(newsFetchedFromAPi: news, category: category, completion: { result in
                        //self.articles = articles
                        switch result{
                        case .failure(let error):
                            print(error)
                        case .success( _):
                            DispatchQueue.main.async {
                                let result = CoreDataManager.shared.fetchAllArtciles(category: category)
                                switch result{
                                case .failure(let error):
                                    print(error)
                                case .success(let articleModelList):
                                    
                                    if self.doesCategoryTabChanged == true{
                                        self.articles.removeAll()
                                        //self.articles.append(contentsOf: articleModelList)
                                        self.articles = articleModelList
                                        self.doesCategoryTabChanged = false
                                    }else{
                                        self.articles = articleModelList
                                        //self.articles.append(contentsOf: articleModelList)
                                    }
                                    
                                    //self.articles = articleModelList
                                    self.indicator.stopAnimating()
                                    self.tableView.reloadData()
                                    NetworkManager.shared.isPaginating = false
                                }
                            }
                        }
                    })
                }
            }
        })
    }
   

    func loadCachedOrNewData(category : String? = nil){
        let result = CoreDataManager.shared.fetchAllArtciles(category: category)
        switch result{
        case .failure(let error):
            print(error)
        case .success(let articleModelList):
            
           
            
            if articleModelList.count == 0 || NetworkManager.shared.isPaginating == true {
                fetchAllNewsAndCacheInCoreData(category: category)
                print("caching")
                updateOrInitiateLastRefreshTime()
                
            }else{
                print("loading cached data")
                self.articles = articleModelList
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refresh(send: UIRefreshControl){
             NetworkManager.shared.resetPageAndPageSize(category: currentCategory!)
             CoreDataManager.shared.deleteAllArticle(category: currentCategory)
             loadCachedOrNewData(category: currentCategory)
             tableView.reloadData()
             refreshControl.endRefreshing()
       }
    
    func checkLastRefresh()-> Bool{
        let defaults = UserDefaults.standard
        if let lastRefreshedTime = defaults.dictionary(forKey: "lastRefreshed") as? [String:Date]{
            print(lastRefreshedTime[currentCategory!]!)
            
            let passedTimeInSecond = Date().timeIntervalSince(lastRefreshedTime[currentCategory!]!)
            let minutes = round(passedTimeInSecond/60)
            if minutes > 60.0{
                NetworkManager.shared.resetPageAndPageSize(category: currentCategory!)
                CoreDataManager.shared.deleteAllArticle(category: currentCategory)
                loadCachedOrNewData(category: currentCategory)
                tableView.reloadData()
                return true
            }
        }
        return false
    }
    func updateOrInitiateLastRefreshTime(){
        let defaults = UserDefaults.standard
        initialRefresh[currentCategory!] = Date()
        if var lastRefreshedTime = defaults.dictionary(forKey: "lastRefreshed") as? [String:Date]{
            lastRefreshedTime.updateValue(Date(), forKey: currentCategory!)
            defaults.set(lastRefreshedTime, forKey: "lastRefreshed")
        }else{
            defaults.set(initialRefresh, forKey: "lastRefreshed")
        }
    }
    @objc func changeImage() {
           if currentIndex < articles.count {
               if let imageURLString = articles[currentIndex].urlToImage {
                   let imageURL = URL(string: imageURLString)
                   if let imageURL = imageURL {
                       UIView.transition(with: headerImage, duration: 1.0, options: .transitionCrossDissolve, animations: {
                           self.headerImage.sd_setImage(with: imageURL)
                       }, completion: nil)
                       
                   }
               }
               currentIndex += 1
           } else {
               currentIndex = 0
           }
       }
    
    func addToBookMark(indexPath: IndexPath){
        CoreDataManager.shared.addBookmark(bookmarkToAdd: articles[indexPath.row], completion: {result in
            switch result{
            case .failure(let error):
                print(error)
                present(Constants.showAlert(msg: "This news already exists!"), animated: true)
            case .success(_):
                present(Constants.showAlert(msg: "Bookmark Added!"), animated: true)
            }
        })
    }
    
    func intializeSearchBar(){
        searchTextField.placeholder = "Search..."
        searchTextField.backgroundColor = .white
        searchTextField.layer.cornerRadius = 10.0
        searchTextField.layer.masksToBounds = true
        searchTextField.clearButtonMode = .whileEditing
    }
    
    func timeConvert(time: String)-> String{
            if time != " "{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: time)
                let passedTimeInSecond = Date().timeIntervalSince(date!)
                let minutes = round(passedTimeInSecond/60)
                if minutes > 59.0{
                    let hour = round(minutes/60)
                    if hour>23{
                        let day = round(hour/24)
                        return ("\(Int(day)) days ago")
                    }else{
                        return ("\(Int(hour)) hours ago")
                    }
                    
                }else {
                    return ("\(Int(minutes)) minutes ago")
                }
            }else{
                return " "
            }
        }



}
extension ViewController :  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.catagories.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCollectionViewCell
        cell.categoryLabel.text = Constants.catagories[indexPath.row]
        cell.categoryLabel.textColor = .darkGray
        if indexPath == currentCategoryIndexpath {
            cell.categoryLabel.textColor = .black
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentCategoryIndexpath = indexPath
        currentCategory = Constants.catagories[indexPath.row]
        doesCategoryTabChanged = true
        if checkLastRefresh() == false{
            loadCachedOrNewData(category: Constants.catagories[indexPath.row])
            
        }
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell
        //cell?.categoryLabel.highlightedTextColor = .clear
       
        cell?.categoryLabel.textColor = .darkGray
    }
    
}
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toArticleModal", sender: self)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CustomTableViewCell
        cell.newsTitle.text = articles[indexPath.row].title
        let placeholderImage = UIImage(named: "default")
        cell.newsImage.image = placeholderImage
        if let imageURLString = articles[indexPath.row].urlToImage {
            let imageURL = URL(string: imageURLString)
            cell.newsImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }
        cell.newsPublishDuration.text = timeConvert(time: articles[indexPath.row].publishedAt ?? " ")
        cell.newsPublishDate.text = "Source - " + (articles[indexPath.row].sourceName ?? "Unavailable")
        //cell.newsImage.sd_setImage(with: imageURL)
        
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView{
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
           
            if (NetworkManager.shared.isPaginating == false){
                if offsetY > 100 {
                    // scrolling down
                    UIView.animate(withDuration: 0.7) { [weak self] in
                        guard let self = self else {return}
                        self.searchBarTopConstraint.constant = 0
                        self.headerViewTopConstraint.constant = -222
                        self.searchTextField.backgroundColor = .lightGray
                        self.view.layoutIfNeeded()
                    }
                } else {
                    // scrolling up
                    UIView.animate(withDuration: 0.7) { [weak self] in
                        guard let self = self else {return}
                        self.searchBarTopConstraint.constant = 120
                        self.headerViewTopConstraint.constant = 0
                        self.searchTextField.backgroundColor = .white
                        self.view.layoutIfNeeded()
                    }
                }
            }
       
            if searchTextField.text == "" {
                if offsetY >  contentHeight - scrollView.frame.height{
                    if NetworkManager.shared.isPaginating == false {
                        NetworkManager.shared.isPaginating = true
                        loadCachedOrNewData(category: currentCategory)
                    }
                     
                }
            }
        }
      
    }
    
    //MARK: Swipe Action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addBookmarkAction = UIContextualAction(style: .normal, title: nil){ [weak self] _,_, completion in
            guard let self = self else{return}
            completion(true)
            self.addToBookMark(indexPath: indexPath)
        
        }
        addBookmarkAction.image = UIImage(systemName: "bookmark")
        addBookmarkAction.backgroundColor =  .systemGray
        let swipeAction =  UISwipeActionsConfiguration (actions: [addBookmarkAction])
        
        return swipeAction
        
    }
    
    
}
extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        let searchQuery = searchTextField.text!
        let result = CoreDataManager.shared.fetchAllArtciles(category: currentCategory, searchQuery: searchQuery)
        switch result {
        case .success(let filterdArticles):
            articles = filterdArticles
            tableView.reloadData()
        case .failure(let error):
            print(error)
        }
        return true
    }
  
   
}

