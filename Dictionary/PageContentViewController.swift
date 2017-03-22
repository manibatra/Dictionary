//
//  PageContentViewController.swift
//  Dictionary
//
//  Created by Mani Batra on 21/3/17.
//  Copyright © 2017 Mani Batra. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var titleText: String! //stores the tile of the current page
    var imageName: String! //stores the name of the image belonging to the current page
    var pageIndex: Int! //stores the current page number
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = self.titleText
        self.backgroundImageView.image = UIImage.init(named: self.imageName)
        self.pageControl.currentPage = self.pageIndex
    }
    
    /**
     * Method name: dismiss
     * Description: method to dismiss the how it works screen
     * Parameters:
     */

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
