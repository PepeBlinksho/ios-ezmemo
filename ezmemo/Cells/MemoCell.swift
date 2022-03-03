//
//  MemoCell.swift
//  ezmemo
//
//  Created by kgo on 2021/12/27.
//

import UIKit

class MemoCell: UITableViewCell {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var dateTextView: UITextView!
    
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI() {
        self.subviews.first?.subviews.first?.layer.borderWidth = 1.0
        self.subviews.first?.subviews.first?.layer.borderColor = UITheme.accentColor.cgColor
    }

}
