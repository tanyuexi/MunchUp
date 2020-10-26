//
//  PeopleTableVC.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/17.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import GoogleMobileAds
import UIKit
import CoreData

class PeopleTableVC: UITableViewController, GADBannerViewDelegate {
    
    // Google AdMob
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google AdMob
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = K.adUnitIDPeople  //change this after test before publish
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        tableView.tableHeaderView?.frame = bannerView.frame
        tableView.tableHeaderView = bannerView
    }
    

}

//MARK: - TableView Data Source

extension PeopleTableVC {
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2 //1. people list, 2. button to add new person
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:   //people list
            return Data.shared.peopleArray.count
        default:   //button to add new person
            return 1
        }
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let person = Data.shared.peopleArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: K.peopleCellID, for: indexPath)
            cell.textLabel?.text = String(format: "%d. %@",
                                          indexPath.row + 1,
                                          person.name ?? "")
            cell.detailTextLabel?.text = String(
                format: "%@%@%@%d %@",
                person.pregnant ? "🤰": "",
                person.breastfeeding ? "🤱": "",
                person.additional ? "🏃": "",
                Calendar.current.dateComponents([.year], from: person.dateOfBirth!, to: Date()).year!,
                NSLocalizedString("yrs", comment: "people list")
            )
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.addPeopleCellID, for: indexPath)
            return cell
        }
    }
}

//MARK: - TableView Delegate Methods

extension PeopleTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "GoToEditPeopleVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToEditPeopleVC",
            let editVC = segue.destination as? EditPeopleTableVC,
            let indexPath = tableView.indexPathForSelectedRow {

            editVC.delegate = self
            if indexPath.section == 0 {
                editVC.selectedPerson = [Data.shared.peopleArray[indexPath.row]]
                editVC.index = indexPath.row
            }
        }
    }
}

//MARK: - EditPeopleTableVCDelegate

extension PeopleTableVC: EditPeopleTableVCDelegate {

    func addPerson(_ newData: People) {
        Data.shared.peopleArray.append(newData)
        sortPeopleArray(&Data.shared.peopleArray)
    }
    
    func deletePerson(at index: Int) {
        K.context.delete(Data.shared.peopleArray[index])
        Data.shared.peopleArray.remove(at: index)
    }
    
    func saveDataAndReloadTable() {
        calculateDailyTotalServes(from: Data.shared.peopleArray, to: &Data.shared.dailyTotal)
        postNotification([
            "peopleCount": Data.shared.peopleArray.count,
            "dailyTotal": Data.shared.dailyTotal
        ])
        saveContext()
        tableView.reloadData()
    }
}
