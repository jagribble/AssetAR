//
//  AssetListView.swift
//  AssetAR
//
//  Created by Jules on 23/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit

class AssetListView:UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet var tableView: UITableView!
    var assetArray: [Asset] = []
  //  @IBOutlet var tableView: UITableView!
    
    func numberOvarctionsInTableView(tableView: UITableView!) -> Int {
        //        return Business.count
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetArray.count
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssetTableViewCell
        let asset = assetArray[indexPath.row]
        // Configure the cell...
        print("asset = \(asset.assetName)")
        cell.assetName.text = asset.assetName
//        cell.photoImageView.image = meal.photo
//        cell.ratingControl.rating = meal.rating
        return cell
    }
    // function to get back to listView
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    @IBAction func back(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as? HomeViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AssetDetail") as? AssetDetailViewController {
            viewController.asset = assetArray[indexPath.row]
          
            viewController.orgText = APIAccess.access.getOrganisation(id: assetArray[indexPath.row].orgainsationID)
            //self.navigationController?.show(viewController, sender: self)
            self.present(viewController, animated: true, completion: nil)
        }
       // self.performSegueWithIdentifier("yourIdentifier", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(tableView.indexPathForSelectedRow != nil){
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
              //  print("Index path selected = \((tableView.indexPathForSelectedRow)!)")
       
        self.tableView.reloadData()
    
        self.hideKeyboardWhenTappedAround()
    }
    
}
