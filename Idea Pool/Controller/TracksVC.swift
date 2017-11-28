//
//  TracksVC.swift
//  MJ Tracks
//
//  Created by Arpit Williams on 16/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import UIKit

class TracksVC: UITableViewController {
    
    // MARK: Properties
    
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadData()
    }
    
    func loadData() {
//        let userInfo = ["email": "test6@mail.com",
//                        "password": "STar1234"]
//
//        UserManager.shared.login(userInfo) { (result) in
//            do {
//                if let user = try result.unwrap() as? User {
//                    print(user.email)
//                }
//            }
//            catch ResponseError.InvalidResponseCode(let reason) {
//                print(reason ?? "")
//            }
//            catch {
//                print(error)
//            }
//        }
        
        UserManager.shared.logout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
