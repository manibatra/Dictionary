//
//  WordTableViewController.swift
//  Dictionary
//
//  Created by Mani Batra on 13/3/17.
//  Copyright © 2017 Mani Batra. All rights reserved.
//

import UIKit

class WordTableViewController: UITableViewController {
    
    var blockArray: NSArray!
    var refinedBlockArray: NSArray!
    var activityIndicator: UIActivityIndicatorView! //activity indicator to placate user when your code is lazy
    
    
    /**
     * Method name: addActivityIndicator
     * Description: shows the activity indicator in the view
     * Parameters:
     */
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    
    /**
     * Method name: removeActivityIndicator
     * Description: removes the activity indicator from the view
     * Parameters:
     */
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func isValid(word: String) -> Bool {
        
        let checker = UITextChecker()
        let valid = checker.rangeOfMisspelledWord(in: word, range: NSMakeRange(0, word.characters.count), startingAt: 0, wrap: false, language: "en")
        print(valid.location)
        return valid.location == NSNotFound
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        var dict:[Character:Int] = [
            "a" : 0,
            "b" : 1,
            "c" : 2,
            "d" : 3,
            "e" : 4,
            "f" : 5,
            "g" : 6,
            "h" : 7,
            "i" : 8,
            "j" : 9,
            "k" : 10,
            "l" : 11,
            "m" : 12,
            "n" : 13,
            "o" : 14,
            "p" : 15,
            "q" : 16,
            "r" : 17,
            "s" : 18,
            "t" : 19,
            "u" : 20,
            "v" : 21,
            "w" : 22,
            "x" : 23,
            "y" : 24,
            "z" : 25
        ]

        //        var myStrings: [String]!
//        if let path = Bundle.main.path(forResource: "words", ofType: "txt") {
//            do {
//                let data = try String(contentsOfFile: path, encoding: .utf8)
//                 myStrings = data.components(separatedBy: .newlines)
//            } catch {
//                print(error)
//            }
//        }
//        
                //creating a "refined array" of blocks which have confidence level above 80 and preprocessing
        let tempSet: NSMutableSet! = NSMutableSet.init()
        for obj in blockArray {
            let block = obj as! G8RecognizedBlock
            print("word = \(block.text!) , confidence = \(block.confidence)  \n")

            let text = block.text.trimmingCharacters(in: CharacterSet.punctuationCharacters).lowercased()
            var valid = false
            if ( text.characters.count > 2 ) {
                let firstChar = text.characters.first!
                
                
                if((dict.index(forKey: firstChar)) != nil) {
                    let location = dict[firstChar]!
                    
                    print ("The location for letter is \(location)")
                    
                    if(myWords[location].contains(text)) {
                        
                        print("\(text) is valid")
                        valid = true
                        
                    } else {
                        print("\(text) is invalid")
                    }
                }
 
            }
            
            
           

            if (valid ) {

                tempSet.add(text)
            }
            
        }
        
        //sorting the array in descinging order of lenght of recongnised words
        refinedBlockArray =  tempSet.sorted(by: {
            ($0 as! String).characters.count > ($1 as! String).characters.count
        }) as NSArray!
        
        
        //display an alert in case no words are detected
        if(refinedBlockArray.count == 0) {
            let alert = UIAlertController(title: "Patience Is A Virtue",
                                message: "\nMake sure the word is in focus/clear before tapping\n\nMake sure the light is even\n\nWorks best on books with black letters on a white background\n\nWorks best when device is parallel to the book",
                                preferredStyle: .alert)
            
            let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: {
                (result : UIAlertAction) -> Void in
                
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            alert.addAction(tryAgainAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return refinedBlockArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // setting the text of the cell
        let text = refinedBlockArray.object(at: indexPath.row) as! String
        
        //remove unwanted punctuation marks and set the title text
        cell.textLabel?.text = text.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        addActivityIndicator()
        //getting the word from the selected row and showing the meaning if it is valid
        let word = tableView.cellForRow(at: indexPath)?.textLabel?.text
        if ( UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word!)) {
            let dictionary = UIReferenceLibraryViewController.init(term: word!)
            self.present(dictionary, animated: true, completion: {
                
                self.removeActivityIndicator()
                
            })
        } else {
            
            //check if the dictionary is installed, if not present a dialouge to install it
            if(!UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: "the")){
                
                let dictionary = UIReferenceLibraryViewController.init(term: "Install Dictionary")
                self.present(dictionary, animated: true, completion: {
                    
                    let alert = UIAlertController(title: "Dictionary Unavailable", message: "Please install British/American English Dictionary by tapping Manage then select Settings > General > Dictionary > British/United States English", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    dictionary.present(alert, animated: true, completion: nil )
                    self.removeActivityIndicator()
                })
            } else {
                //show alert view if an invalid word is selected
                tableView.cellForRow(at: indexPath)?.isSelected = false
                let alert = UIAlertController(title: "Invalid Word", message: "The word recognised by Dictionary is invalid", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.removeActivityIndicator()
                })
            }
        }
        
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
