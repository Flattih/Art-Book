//
//  DetailsVc.swift
//  sanatkitabi
//
//  Created by Fatih on 26.07.2023.
//
import CoreData
import UIKit

class DetailsVc: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenName = ""
    var chosenId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenName != "" {
            saveButton.isHidden = true
            // core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sayfa")
            let idString = chosenId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameTextField.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistTextField.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearTextField.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("error")
            }
        } else {
            saveButton.isEnabled = false
            nameTextField.text = ""
            artistTextField.text = ""
            yearTextField.text = ""
            
        }




        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
     
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true 
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage 
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // we are creating a new entity
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Sayfa", into: context)
        // attributes
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        if let year = Int(yearTextField.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")

        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }



        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
        
        
    }
    


}
