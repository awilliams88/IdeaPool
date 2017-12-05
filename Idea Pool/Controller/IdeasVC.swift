//
//  IdeasVC.swift
//  Idea Pool
//
//  Created by Arpit Williams on 01/12/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import UIKit

class IdeasVC: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Properties
    var ideas =  [Idea]()

    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View
        tableView.tableFooterView = UIView()
        
        // Register Cell for table view
        let ideaCell = UINib(nibName: "IdeaCell", bundle: Bundle.main)
        tableView.register(ideaCell, forCellReuseIdentifier: "ideaCell")
        
        loadData()
    }
    
    // Loads Ideas
    func loadData() {
        spinner.startAnimating()
        IdeaManager.shared.read(at: 1) { (result) in
            DispatchQueue.main.async { self.spinner.stopAnimating() }
            self.handle(result: result)
        }
    }
    
    // Handles result from completion handlers
    func handle(result: Result<Any>) {
        do {
            if let ideas = try result.unwrap() as? [Idea] {
                self.ideas.append(contentsOf: ideas)
            }
        }
        catch ResponseError.InvalidResponseCode(let reason) {
            if let reason =  reason as? [String: String] {
                Utility.showAlert(for: self, title: reason.keys.first ?? "", message: reason.values.first ?? "")
            }
        }
        catch {
            print(error)
        }
        
        // Update UI
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            if self.ideas.count > 0 {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    // Log out
    @IBAction func logOutBtnPrsd(_ sender: UIButton) {
        UserManager.shared.logout()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("DE-INIT")
    }
}


// MARK: Table View Datasource - Delegate - Idea Cell Delegate
extension IdeasVC: UITableViewDataSource, UITableViewDelegate, IdeaCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ideaCell", for: indexPath) as! IdeaCell
        cell.delegate = self
        let idea = ideas[indexPath.row]
        cell.updateUI(for: idea)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func didSelected(_ idea: Idea) {
        let actionSheet = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            print("EDIT")
            // TODO : Segue to IdeaEditorVC
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            self.spinner.startAnimating()
            IdeaManager.shared.delete(idea, completion: { (result) in
                
                // Removed delete idea from collection
                if let index = self.ideas.index(where: { $0.id == idea.id }) {
                    self.ideas.remove(at: index)
                }
                
                // Handle completion handler result
                self.handle(result: result)
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}
