//
//  IdeaCell.swift
//  Idea Pool
//
//  Created by Arpit Williams on 01/12/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import UIKit

class IdeaCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var ideaLbl: UILabel!
    @IBOutlet weak var avgLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var easeLbl: UILabel!
    @IBOutlet weak var impactLbl: UILabel!
    
    // MARK: Properties
    
    weak var delegate: IdeaCellDelegate?
    var idea: Idea?
    
    // MARK: Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Box View
        boxView.layer.masksToBounds = false
        boxView.layer.cornerRadius = 4
        boxView.layer.shadowColor = UIColor.black.cgColor
        boxView.layer.shadowOpacity = 0.34
        boxView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        boxView.layer.shadowRadius = 2
    }
    
    func updateUI(for idea: Idea) {
        self.idea = idea
        ideaLbl.text = idea.content
        avgLbl.text = String(format: "%0.1f", idea.averageScore)
        confidenceLbl.text = String(idea.confidence)
        easeLbl.text = String(idea.ease)
        impactLbl.text = String(idea.impact)
    }
    
    @IBAction func selectBtnPtsd(_ sender: UIButton) {
        if let idea = idea, let delegate = delegate {
            delegate.didSelected(idea)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// Idea Cell Delegate Protocol
protocol IdeaCellDelegate: class {
    func didSelected(_ idea: Idea)
}
