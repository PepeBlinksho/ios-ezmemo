//
//  MemoEditController.swift
//  ezmemo
//
//  Created by kgo on 2022/01/14.
//

import UIKit

class MemoEditController: UIViewController {
    
    var id: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        print(id)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        // APIにリクエスト
        //self.performSegue(withIdentifier: "UnwindToEditView", sender: nil)
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginView")
        //NAVIがある場合
        //self.navigationController?.pushViewController(controller, animated: true)
        
        present(controller, animated: true, completion: nil)
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
