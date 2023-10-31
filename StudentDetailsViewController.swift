//
//  StudentDetailsViewController.swift
//  FireEvacuation
//
//  Created by Amritha on 31/05/23.
//

import UIKit

class StudentDetailsViewController: UIViewController {
    
    var GETCLASSSTUDENTS = API_Manager().Header + API_Manager().getclassstudents
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    @IBOutlet weak var tableViewInView: UIView!
    
    @IBOutlet weak var classNameLabel: UILabel!
    
    var fullNames: [String] = []
    
    var studentsModelArray = [ClassStudentsModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeNetworkCallForGetClassStudents()

        self.detailsTableView.register(UINib(nibName: "StudentDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentDetailsTableViewCell")
        
        detailsTableView.separatorStyle = .none
        
        tableViewInView.layer.cornerRadius = 10
        tableViewInView.layer.masksToBounds = true
        
        self.classNameLabel.text = "Class \(DefaultWrapper.shared.classname)"
        
        
    }

}

extension StudentDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentsModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentDetailsTableViewCell", for: indexPath) as! StudentDetailsTableViewCell
        cell.nameLabel.text = studentsModelArray[indexPath.row].full_name
        cell.idLabel.text = "\(studentsModelArray[indexPath.row].id ?? 0)"
        if let bannerImageUrlString = studentsModelArray[indexPath.row].profile_photo_path,
                                                       let bannerImageUrl = URL(string: bannerImageUrlString) {
            URLSession.shared.dataTask(with: bannerImageUrl) { data, response, error in
                                                            if let data = data {
                                                                DispatchQueue.main.async {
                                                                    cell.profileImageView.image = UIImage(data: data)
                                                                }
                                                            }
                                                        }.resume()
                                                    }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
        
    }
    
//   MARK: - GET CLASS STUDENTS

    func makeNetworkCallForGetClassStudents() {

        print("newclassidnewclassid: \(DefaultWrapper.shared.classid)")

        guard let Url = URL(string: GETCLASSSTUDENTS) else { return }
        let parameters: [String:Any] = [
            "class_id": DefaultWrapper.shared.classid
        ]
        var components = URLComponents(url: Url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        var req = URLRequest(url: components.url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: req) { datainbyte, responseinbyte, errorinbyte in
                       print("datainbyte: \(datainbyte!)")
            if let Error = errorinbyte {
                print(Error.localizedDescription)
            }
            if let dataConv = datainbyte {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: dataConv)
                                       print("jsonDatas: \(jsonData)")

                    if let convDict = jsonData as? [String: Any] {
                        //                       print("Dictionary: \(convDict)")

                        if let respData = convDict["data"] as? [[String:Any]] {
                         print("respData: \(respData)")
                            
                            DispatchQueue.main.async {
                                for i in respData {
                                    self.studentsModelArray.append(ClassStudentsModel(fromdata: i))
                                }
                                self.detailsTableView.reloadData()
                            }
                            
                        }
                    }
                }catch{
                    print("Error")
                }
            }

        }.resume()

    }
    
}
