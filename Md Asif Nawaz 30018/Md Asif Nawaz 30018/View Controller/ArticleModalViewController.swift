//
//  ArticleModalViewController.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 16/1/23.
//

import UIKit
import SDWebImage

class ArticleModalViewController: UIViewController {

    @IBOutlet weak var modalHeadImage: UIImageView!
    @IBOutlet weak var modalArticleImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBookmarkBtn: UIButton!
    var tableHeader : String = ""
    var article : ArticlesModel?
    var bookMark : BookmarksModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        modalHeadImage.layer.cornerRadius = 35
        modalHeadImage.image = UIImage.gifImageWithName("earthGif")
        
     
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC =  segue.destination as? ReadMoreWebKitViewController{
          
            if let article = article {
                guard let url =  article.url else {return}
                destinationVC.urlString = url
            }
            if let bookmark = bookMark {
                guard let url =  bookmark.url else {return}
                destinationVC.urlString = url
            }
        }
    }
    @IBAction func addBookmarkBtnAction(_ sender: Any) {
        guard let article = article else {
            addBookmarkBtn.isHidden = true
            return
        }
        CoreDataManager.shared.addBookmark(bookmarkToAdd: article, completion: {result in 
            switch result{
            case .failure(let error):
                print(error)
                present(Constants.showAlert(msg: "This news already exists!"), animated: true)
            case .success(_):
                present(Constants.showAlert(msg: "Bookmark Added!"), animated: true)
            }
        })
    }
    @IBAction func readMoreBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "toReadMore", sender: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        guard let _ = article else {
            addBookmarkBtn.isHidden = true
            return
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ArticleModalViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableHeader
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        35
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ArticleModalCustomTableViewCell", for: indexPath) as! ArticleModalCustomTableViewCell
        if let article = article {
            cell.titleLabel.text = "\(article.title ?? "") \n"
            cell.detailLabel.text = "\( article.content ?? "") \n\n \( article.desc ?? "")"
        }
        if let bookmark = bookMark {
            cell.titleLabel.text =  "\(bookmark.title ?? "") \n"
            cell.detailLabel.text = "\( bookmark.content ?? "") \n\n \( bookmark.desc ?? "")"
        }
        //cell.newsImage.sd_setImage(with: imageURL)
       
        return cell
    }
    
    
}
