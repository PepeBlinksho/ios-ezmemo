//
//  WebViewController.swift
//  ezmemo
//
//  Created by kgo on 2022/01/31.
//

import UIKit
import SafariServices
import WebKit
import Moya
import Firebase

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let url = URL(string: "https://demo.nextshowroom.jp/membership")!
//        let request = URLRequest(url: url)
//        webView.load(request)
        
//        webView.loadHTMLString("<h1>テスト</h1>", baseURL: nil)
//        webView.loadHTMLString("<iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/LRD_j5dbrYE\" title=\"YouTube video player\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>", baseURL: nil)
        
        
        //イメージビュー
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let testImagesRef = storageRef.child("images/test.jpg")
        testImagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // Data for "images/island.jpg" is returned
            let image = UIImage(data: data!)
              self.imageView.image = image
          }
        }
        
        let imgUrl = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/ezmemo-a0bc2.appspot.com/o/images%2Ftest.jpg?alt=media&token=3dd68391-00c0-4999-bb2b-13ffaa1147b0")!
        imageView.loadFromURL(url: imgUrl)
    }
    
    @IBAction func openWebSite(_ sender: Any) {
        let url = URL(string: "https://demo.nextshowroom.jp/membership")!
        let webViewController = SFSafariViewController(url: url)
        webViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.present(navigationController, animated: true)
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

extension WebViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("OK")
    }
}
