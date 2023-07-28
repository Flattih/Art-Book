//
//  ViewController.swift
//  sanatkitabi
//
//  Created by Fatih on 26.07.2023.
//
import CoreData
import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedName = ""
    var selectedId : UUID?
    
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self 
        tableView.dataSource = self 
        getData()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell() 
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell 
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle ==  UITableViewCell.EditingStyle.delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sayfa")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch  {
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            } catch  {
                print("error")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVc"{
            let destinationVc = segue.destination as! DetailsVc
            destinationVc.chosenName = selectedName
            destinationVc.chosenId = selectedId
        }
    }

     


    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sayfa")
        fetchRequest.returnsObjectsAsFaults = false
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                }
                self.tableView.reloadData()
            }
        } catch  {
            print("error")
        }   
     }
    @objc func addButtonClicked(){
        selectedName = ""
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }

}

