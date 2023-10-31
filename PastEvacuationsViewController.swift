//
//  PastEvacuationsViewController.swift
//  FireEvacuation
//
//  Created by FAO on 29/05/23.
//

import UIKit

class PastEvacuationsViewController: UIViewController {
   
    @IBOutlet weak var pastTableview: UITableView!
    
    var dateTimeArray: [String] = []
    
    var evacuationStatusModelArray : [EvacuationStatusModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pastTableview.register(UINib(nibName: "PastEvacuationsTableViewCell", bundle: nil), forCellReuseIdentifier: "PastEvacuationsTableViewCell")
        
        self.pastTableview.separatorStyle = .none
        
    }
    
    @IBAction func didBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension PastEvacuationsViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evacuationStatusModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastEvacuationsTableViewCell", for: indexPath) as! PastEvacuationsTableViewCell
        
        cell.evacuationCauseLabel.text = evacuationStatusModelArray[indexPath.row].evacuate_type
        
        let dateString1 = evacuationStatusModelArray[indexPath.row].evacuate_start ?? ""
        let dateString2 = evacuationStatusModelArray[indexPath.row].evacuate_end ?? ""

        // Create a DateFormatter instance for the date component
        let dateComponentFormatter = DateFormatter()
        dateComponentFormatter.dateFormat = "dd-MM-yyyy"

        // Create a DateFormatter instance for the time component
        let timeComponentFormatter = DateFormatter()
        timeComponentFormatter.dateFormat = "HH:mm"

        // Create a DateFormatter instance for the combined date and time format
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Parse the strings and convert them to Date objects
        if let date1 = dateTimeFormatter.date(from: dateString1), let date2 = dateTimeFormatter.date(from: dateString2) {
            // Calculate the difference in time in minutes
            let timeDifferenceMinutes = Calendar.current.dateComponents([.minute], from: date1, to: date2).minute ?? 0
            
            // Extract the date and time components from the parsed dates
            let date1Component = dateComponentFormatter.string(from: date1)
            let date2Component = dateComponentFormatter.string(from: date2)
            let time1Component = timeComponentFormatter.string(from: date1)
            let time2Component = timeComponentFormatter.string(from: date2)
            
            // Convert the time components to 24-hour format with hour and minute precision
            let convertedTime1 = timeComponentFormatter.string(from: date1)
            let convertedTime2 = timeComponentFormatter.string(from: date2)
            
            cell.evacuationOnLabel.text = date1Component
            cell.startTimeLabel.text = convertedTime1
            cell.endTimeLabel.text = convertedTime2
            cell.timeTakenLabel.text = "\(timeDifferenceMinutes)"
            
            print("Time Difference (in minutes): \(timeDifferenceMinutes)")
            print("Date 1: \(date1Component)")
            print("Date 2: \(date2Component)")
            print("Time 1: \(time1Component)")
            print("Time 2: \(time2Component)")
            print("Converted Time 1: \(convertedTime1)")
            print("Converted Time 2: \(convertedTime2)")
        } else {
            print("Invalid date string")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
}
