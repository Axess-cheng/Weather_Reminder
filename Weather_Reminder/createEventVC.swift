//
//  crateEventVC.swift
//  Weather_Reminder
//
//  Created by allen on 2019/3/31.
//  Copyright © 2019 comp208.team4. All rights reserved.
//

import UIKit

class createEventVC: UIViewController {

    var senario = String()//从上一个view传递
    
    var eventTitle:String?
    var pStart = String()
    var pEnd = String()
    var alertDays = Int()
    var remindTime = String()
    var weatherType = String()
    var intensity: String?
    var uvIndex:Int?
    var humidityStatus:String?
    var humidityValue:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
