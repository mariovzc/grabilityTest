//
//  iPhoneListVC.swift
//  grability
//
//  Created by Mario Vizcaino on 20/02/17.
//  Copyright © 2017 Mario Vizcaino. All rights reserved.
//

import UIKit
import CoreData

class iPhoneListVC: UIViewController {

    let cellIdentifier = "cellIphone"
    var appData: [NSManagedObject] = []
    let feed  = FeedData()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellInTable()
        initialData()
        navigationBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerCellInTable() {
        let nib:UINib = UINib(nibName: "iPhoneTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
}

extension iPhoneListVC{
    func refresh(){
        displayData()
        self.tableView.reloadData()
        initialData()
    }
    func navigationBar() {
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "refresh"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1
        self.navigationItem.title = "Iphone View"

    }
    func displayData() {
        if #available(iOS 10.0, *) {
            getData {
                print("DATAaaaaaa")
                
            }
        }
        print(appData.count)
        tableView.reloadData()
    }
    
    @available(iOS 10.0, *)
    func getData(handleComplete:(()->())){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: feed.daEntity())
        
        do {
            appData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
        handleComplete()
    }
    
    func initialData(){
        if #available(iOS 10.0, *) {
            getData{() -> () in
                if(appData.count > 0){
                    displayData()
                    tableView.reloadData()
                }else{
                    if (self.currentReachabilityStatus == .notReachable) {
                        alert(message: "Please check your internet connection and try again")
                        return
                    }else{
                        feed.cleanDB()
                        feed.updateInfo{ () -> () in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                self.getData {
                                    self.displayData()
                                    self.tableView.reloadData()
                                    
                                }
                                
                            })
                        }
                    }
                    
                }
            }
        }
    }
}
extension iPhoneListVC : UITableViewDataSource {
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appData.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cell = iPhoneTableViewCell()
        return cell.heigthCell
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIphone", for: indexPath) as! iPhoneTableViewCell
       
        
        let data = appData[indexPath.row]
        print("index   \(indexPath.row)")
        let imgURL: NSURL = NSURL(string: data.value(forKey: "imageUrl") as! String)!
        let request: NSURLRequest = NSURLRequest(url: imgURL as URL)
        
        cell.nameLabel.text =  data.value(forKey: "name") as! String?
        let price = (data.value(forKey: "price") as! String?)!
        if (price == "0.00000"){
            cell.priceLabel.text  = "GRATIS"
        }else{
            cell.priceLabel.text = "\(data.value(forKey: "price")!)  \(data.value(forKey: "currency")!)"
            
        }
        
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response, data, error) -> Void in
            
            if error == nil {
                cell.appImageView.image = UIImage(data: data!)
            }
        }

        
        return cell
    }

    
    
}


extension iPhoneListVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let obj = arrayData[indexPath.row]
        
    }
    
}



