//
//  BookmarksViewController.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 17/1/23.
//

import UIKit
import SDWebImage
class BookmarksViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var bookmarks = [BookmarksModel]()
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
  
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchTextField.delegate = self
        headerImage.layer.cornerRadius = 35
        headerImage.image = UIImage.gifImageWithName("earthGif")
        initializeCollectionViewLayout()
        intializeSearchBar()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        loadBookmarks()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destinationVC =  segue.destination as? ArticleModalViewController{
//            destinationVC.loadViewIfNeeded()
//            //if let index =  collectionView.indexPathsForSelectedItems?.first
//            //{destinationVC.bookMark = bookmarks[]}
//            destinationVC.bookMark = bookmarks[index]
//        }
//    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    func initializeCollectionViewLayout(){
       
        
        let nib = UINib(nibName: "BookmarkCustomCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "BookmarkCustomCollectionViewCell")
        // Do any additional setup after loading the view.
        let insets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let largeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
        
        largeItem.contentInsets = insets
        
        let vertGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2.5))
        let verticalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: vertGroupSize, subitems: [largeItem])
        let section = NSCollectionLayoutSection(group: verticalGroup)
        
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView.collectionViewLayout = compositionalLayout
    }
    func loadBookmarks(){
        let results = CoreDataManager.shared.fetchAllBookmarks(category: nil)
        
        switch results{
        case .failure(let error):
            print(error)
        case .success(let bookmarkList):
            bookmarks = bookmarkList
        }
        collectionView.reloadData()
    }
  
    

}

extension BookmarksViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarks.count//pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCustomCollectionViewCell", for: indexPath) as! BookmarkCustomCollectionViewCell
        cell.nibLabel.text =  bookmarks[indexPath.row].title
        let placeholderImage = UIImage(named: "default")
        cell.nibImage.image = placeholderImage
        if let imageURLString = bookmarks[indexPath.row].urlToImage {
            let imageURL = URL(string: imageURLString)
            cell.nibImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }

        cell.articleAuthor = bookmarks[indexPath.row].author ?? "Unavailable"
        cell.articleTitle = bookmarks[indexPath.row].title ?? "Unavailable"
        cell.articleSource = bookmarks[indexPath.row].sourceName ?? "Unavailable"
        cell.articleImage = bookmarks[indexPath.row].urlToImage ?? "Unavailable"
        
        cell.nibShowBtn.tag = indexPath.row
        cell.nibShowBtn.addTarget(self, action: #selector(showBookmarkAction), for: .touchUpInside)
        cell.nibDeleteBtn.tag = indexPath.row
        cell.nibDeleteBtn.addTarget(self, action: #selector(deleteBookmarkAction), for: .touchUpInside)
        cell.vc = self
        return cell
    }
    // This addBookmarkAction should be renamed to showNews
    @objc func showBookmarkAction(sender: UIButton){
        index = sender.tag
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "articleVCId") as? ArticleModalViewController
        {
            vc.loadViewIfNeeded()
            vc.bookMark = bookmarks[index]
    
            vc.tableHeader = "Author - \(bookmarks[index].author ?? "Unavilable"), Source - \(bookmarks[index].sourceName ?? " Unavilable") "
            let placeholderImage = UIImage(named: "default")
            vc.modalArticleImage.image = placeholderImage
            if let imageURLString = bookmarks[index].urlToImage {
                let imageURL = URL(string: imageURLString)
                vc.modalArticleImage.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc func deleteBookmarkAction(sender: UIButton){
        index = sender.tag
        
        let alertController = UIAlertController(title: "Delete Bookmark!", message: "Are you sure you want to delete?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            guard let self = self else {return}
            DispatchQueue.main.async {
                CoreDataManager.shared.deleteBookmark(bookmarkToDelete: self.bookmarks[self.index])
                self.bookmarks.remove(at: self.index)
                self.collectionView.reloadData()
            }
          
        })
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}
extension BookmarksViewController: UITextFieldDelegate {
    func intializeSearchBar(){
        searchTextField.placeholder = "Search..."
        searchTextField.backgroundColor = .white
        searchTextField.layer.cornerRadius = 10.0
        searchTextField.layer.masksToBounds = true
        searchTextField.clearButtonMode = .whileEditing
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchQuery = searchTextField.text!
        //articlesArray = CoreDataManager.shared.getAllRecords(category: category, search: search)
        let result = CoreDataManager.shared.fetchAllBookmarks(searchQuery: searchQuery)
        switch result {
        case .success(let filterdBookmarks):
            bookmarks = filterdBookmarks
            collectionView.reloadData()
        case .failure(let error):
            print(error)
        }
        return true
    }
}
