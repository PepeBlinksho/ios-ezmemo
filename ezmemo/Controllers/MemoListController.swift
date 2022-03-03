//
//  MemoListController.swift
//  ezmemo
//
//  Created by kgo on 2021/12/27.
//

import UIKit
import Moya

class MemoListController: UITableViewController {
    
    var memoCollection: MemoCollection? = MemoCollection.loadFromCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadDataFormServer), for: .valueChanged)
        
        loadDataFormServer()
    }
    
    // MARK: - DATA関連
    @objc func loadDataFormServer() {
        MemoCollection.loadData { memoCollection in
            guard let memoCollection = memoCollection else {
                print("エラーーーー")
                return
            }
            
            memoCollection.saveToCache()
            
            self.memoCollection = memoCollection
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadMoreDeta(url: URL) {
        let provider  = MoyaProvider<WebAccessService>()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        provider.request(.load(url: url)) { result in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
                case let .success(moyaResponse):
                    do {
                        _ = try moyaResponse.filterSuccessfulStatusCodes()
                        let data = moyaResponse.data
                        let coder = JSONDecoder()
                        let newMemoCollection = try coder.decode(MemoCollection.self, from: data)
                        self.memoCollection?.links = newMemoCollection.links
                        self.memoCollection?.meta = newMemoCollection.meta
                        self.memoCollection?.memos.append(contentsOf: newMemoCollection.memos)
                        self.tableView.reloadData()
                    }
                    catch {
                        print("Error: ", error)
                        NotificationCenter.default.post(name: LocalNotificationService.getMemoListError, object: nil, userInfo: [
                            "message": "メモリスト取得できません。"
                        ])
                    }
                case let .failure(error):
                    print(error)
                    NotificationCenter.default.post(name: LocalNotificationService.networkError, object: nil, userInfo: [
                        "message": "サーバーに接続ができません。"
                    ])
                }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let memoCollection = self.memoCollection else {
            return 0
        }
        
        return memoCollection.memos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as! MemoCell
        
        guard let memoCollection = self.memoCollection else {
            return cell
        }
        
        let memo: MemoCollection.Memo = memoCollection.memos[indexPath.row]

        cell.titleTextView.text = memo.attributes.title
        cell.contentTextView.text = memo.attributes.contents
        cell.userTextView.text = "NONE"
        cell.dateTextView.text = "2021-12-27"
        
        cell.id = memo.id

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MemoCell
        let title = cell.titleTextView.text
        performSegue(withIdentifier: "ShowMemoDetail", sender: title)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let memoCollection = self.memoCollection else {
            return
        }
        
        let lastCellIndex = memoCollection.memos.count - 1
        if (lastCellIndex == indexPath.row) {
            guard let nextPageUrl = memoCollection.links.next else {
                return
            }
            
            loadMoreDeta(url: nextPageUrl)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! MemoCell
        
        // Editボタン
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, callback in
            
            if #available(iOS 15.0, *) {
                let storyboard = UIStoryboard(name: "MemoList", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "NewEditView")
                if let sheet = controller.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.largestUndimmedDetentIdentifier = .medium
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                }
                self.present(controller, animated: true, completion: nil)
            } else {
                print("古い")
            }
        }
        editAction.backgroundColor = UITheme.accentColor
        
        // Deleteボタン
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, callback in
            if let id = cell.id {
                print("削除APIを叩く", id)
                self.memoCollection?.memos.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
        deleteAction.backgroundColor = UITheme.secondaryColor
        
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! MemoCell
        
        // Editボタン
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, callback in
            if let id = cell.id {
                self.performSegue(withIdentifier: "ShowEditView", sender: id)
            }
        }
        editAction.backgroundColor = UITheme.accentColor
        
        // Deleteボタン
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, callback in
            if let id = cell.id {
                print("削除APIを叩く", id)
            }
        }
        deleteAction.backgroundColor = UITheme.secondaryColor
        
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    @IBAction func unwindToEditView(unwindSegue: UIStoryboardSegue) {}
     
    func setupNavigationBar() {
        self.navigationItem.title = "EZmemo List"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMemoDetail" {
            let destination = segue.destination as! MemoDetailController
            destination.memoTitle = sender as? String
        }
        
        if segue.identifier == "ShowEditView" {
            let destination = segue.destination as! MemoEditController
            destination.id = sender as? String
        }
    }
}
