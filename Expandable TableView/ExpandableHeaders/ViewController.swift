

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    enum ExpandType :String
    {
        case expandTypeSingle
        case expandTypeMultiple
    }
    
    /* expandType is used to determine whether to expand a single section or multiple at same time */
    var expandType: ExpandType = .expandTypeSingle
    
    @IBOutlet weak var expandableTableView: UITableView!
    @IBOutlet weak var singleExpandableBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var multipleExpandableBarButtonItem: UIBarButtonItem!

    let kHeaderSectionTag: Int = 6900;
    
    var currentExpandedSectionHeader: UITableViewHeaderFooterView!
    
    var currentExpandedSectionHeaderNumbers: Array<Int> = [-1, -1, -1]

    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    
    //MARK: - Implementation
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sectionNames = [ "Asia", "Europe", "Africa" ]
        
        sectionItems = [ ["Pakistan", "India", "Srilanka", "China", "Bangladesh", "Japan"],
                         ["Germany", "Italy", "France", "Greece"],
                         ["Algeria", "Nigeria", "Senegal"]
                       ]
        
        self.expandableTableView!.tableFooterView = UIView()
        
        if self.expandType == .expandTypeSingle
        {
            self.singleExpandableBarButtonItem.isEnabled = false
        }
        else
        {
            self.multipleExpandableBarButtonItem.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tableview DATA SOURCE Methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if sectionNames.count > 0
        {
            tableView.backgroundView = nil
            return sectionNames.count
        }
        else
        {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.expandableTableView.backgroundView = messageLabel;
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.currentExpandedSectionHeaderNumbers[section] != -1
        {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count;
        }
        else
        {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (self.sectionNames.count != 0)
        {
            return self.sectionNames[section] as? String
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as UITableViewCell
        
        let section = self.sectionItems[indexPath.section] as! NSArray
        cell.textLabel?.textColor = UIColor.colorWithHexString(hexStr: "#000080")
        cell.textLabel?.text = section[indexPath.row] as? String
        
        return cell
    }
    
    // MARK: - Tableview DELEGATE Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 60.0;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //TODO:- recast your view as a UITableViewHeaderFooterView
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.colorWithHexString(hexStr: "#000080")
        header.textLabel?.textColor = UIColor.colorWithHexString(hexStr: "#00FFFF")
        
        //TODO:- make headers touchable
        
        header.tag = section
        
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(ViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section)
        {
            viewWithTag.removeFromSuperview()
        }
        
        let headerFrame = self.view.frame.size
        
        // chevron imageView
        let chevronImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
        chevronImageView.image = UIImage(named: "Chevron-Dn-Wht")
        chevronImageView.tag = kHeaderSectionTag + section
        
        header.addSubview(chevronImageView)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer)
    {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let currentlyTouchedHeaderImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView // The Dropdown Image for the currently touched header
        
        if !self.isAnySectionExpanded()
        {
            //  none of the sections/headers are currently expanded
            
            self.currentExpandedSectionHeaderNumbers[section] = section
            expandTableViewSection(section, imageView: currentlyTouchedHeaderImageView!)
        }
        else
        {
            if self.currentExpandedSectionHeaderNumbers[section] != -1
            {
                //  already expanded section/header is touched, so collapse that

                collapseTableViewSection(section, imageView: currentlyTouchedHeaderImageView!)
            }
            else
            {
                // a secction/header is already expanded, and another header/section is touched to expand

                if self.expandType == .expandTypeSingle
                {
                    collpaseAlreadyExpandedSection()
                }
                
                expandTableViewSection(section, imageView: currentlyTouchedHeaderImageView!)
            }
        }
    }
    
    func collapseTableViewSection(_ section: Int, imageView: UIImageView)
    {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.currentExpandedSectionHeaderNumbers[section] = -1
        
        if (sectionData.count == 0)
        {
            return;
        }
        else
        {
            // un-rotate chevron ImageView
            
            UIView.animate(withDuration: 0.4, animations:
            {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            
            // delete rows of collapsed section
            
            var indexPaths = [IndexPath]()
            
            for i in 0 ..< sectionData.count
            {
                let index = IndexPath(row: i, section: section)
                indexPaths.append(index)
            }
            
            self.expandableTableView!.beginUpdates()
            self.expandableTableView!.deleteRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            self.expandableTableView!.endUpdates()
        }
    }
    
    func expandTableViewSection(_ section: Int, imageView: UIImageView)
    {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0)
        {
            self.currentExpandedSectionHeaderNumbers[section] = -1
            return;
        }
        else
        {
            // rotate chevron ImageView
            
            UIView.animate(withDuration: 0.4, animations:
            {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            
            // add rows for expanded section

            var indexesPath = [IndexPath]()
            
            for i in 0 ..< sectionData.count
            {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            
            self.currentExpandedSectionHeaderNumbers[section] = section
            
            self.expandableTableView!.beginUpdates()
            self.expandableTableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.expandableTableView!.endUpdates()
        }
    }
    
    // MARK:- Private
    
    func isAnySectionExpanded() -> Bool
    {
        for i in 0 ..< self.currentExpandedSectionHeaderNumbers.count
        {
            if self.currentExpandedSectionHeaderNumbers[i] != -1
            {
                return true
            }
        }
        return false
    }
    
    func collpaseAlreadyExpandedSection()
    {
        for section in 0 ..< self.currentExpandedSectionHeaderNumbers.count
        {
            if self.currentExpandedSectionHeaderNumbers[section] != -1
            {
                let alreadyExpandedHeaderImageView = self.view.viewWithTag(kHeaderSectionTag + section) as? UIImageView ?? UIImageView()

                collapseTableViewSection(section, imageView: alreadyExpandedHeaderImageView)
            }
        }
    }
    
    // MARK:- Actions
    
    @IBAction func changeExpandType(sender: UIBarButtonItem)
    {
        if sender.tag == 1
        {
            // Single Expand Button Tapped
            
            multipleExpandableBarButtonItem.isEnabled = true
            singleExpandableBarButtonItem.isEnabled = false
            
            self.expandType = .expandTypeSingle
        }
        else
        {
            multipleExpandableBarButtonItem.isEnabled = false
            singleExpandableBarButtonItem.isEnabled = true
            
            self.expandType = .expandTypeMultiple
        }
        
        collpaseAlreadyExpandedSection()
    }

}

