//
//  ConnectServer.swift
//  Weather_Reminder
//
//  Created by allen on 2019/4/27.
//  Copyright © 2019 comp208.team4. All rights reserved.
//

import Foundation

let id_field = "email"
let id_type = "s"
let SUPERTOKEN = "XvgcNiTgSPABTVqf"

var id_data = "" // axess971230@gmail.com
var device_token = ""
var Password = "" // 123abc
var user_token = ""
var user_id = 0
var loginIsSucc = false

let semaphore = DispatchSemaphore.init(value: 0)

// add user.
func addUser(emailAdd:String, password:String){
    let url = URL(string: "http://142.93.34.33/add_user.php")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = "device_token=\(device_token)&email=\(emailAdd)&password=\(password)&token=\(SUPERTOKEN)".data(using: .utf8)
    
    DispatchQueue.main.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            
            let responseString = String(data: data2, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                
                // Todo: add success or fail.
                
            }catch let err {
                print("error here ", err)
            }
        }
        task.resume()
    }
}


// check user Using GET
//
func checkUser(){
    
    let url = URL(string: "http://142.93.34.33/check_user.php?id_field=\(id_field)&id_data=\(id_data)&id_type=\(id_type)&device_token=\(device_token)&password=\(Password)&token=\(SUPERTOKEN)")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let backgroundQueue = DispatchQueue(label: "com.geselle.backgroundQueue", qos: .userInitiated)
    backgroundQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            
            let responseString = String(data: data2, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                
                for jsonKey in jsonResponse!.allKeys {
                    let theKey = jsonKey as! String
                    if theKey == "error"{
                        loginIsSucc = false
                        print("wrong")
                    }else{
                        loginIsSucc = true
                        if theKey == "token"{
                            user_token = jsonResponse![theKey] as! String
                            print("test for login user_token :" + user_token)
                        }else if theKey == "id"{
                            user_id = jsonResponse![theKey] as! Int
                            print("test for login user_id:" + String(user_id))
                        }
                    }
                }
                semaphore.signal()
            }catch let err {
                print("error here ", err)
            }
        }
        task.resume()
    }
}


// add event
func addEvent(){
    let url = URL(string: "http://142.93.34.33/update_event.php")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let startDate = gsPeriod["startDate"]
    let endDate = gsPeriod["endDate"]
    let lon = location2D["long"]
    let lat = location2D["lat"]
    
    let event = "{\"id\":\(id),\"title\":\"\(eventTitle)\",\"period\":{\"startDate\":\(startDate),\"endDate\":\(endDate) },\"alertDays\":1,\"remindTime\":\"\(gsRemindTime)\",\"sunny\":\"\(sunny)\", \"cloudy\":\"\(cloudy)\",\"windy\":\"\(windy)\",\"rainy\":\"\(rainy)\",\"snow\":\"\(snow)\",\"uvIndex\":\"\(uvIndex)\",\"humidity\":\"\(humidity)\",\"loc\":{\"lon\":\(lon),\"lat\":\(lat) },\"locName\":\"\(locName)\" }"
    
    request.httpBody = "event=\(event)&token=\(user_token)&user_id=\(user_id)".data(using: .utf8)
    
    DispatchQueue.main.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            
            let responseString = String(data: data2, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                //
                
                
            }catch let err {
                print("error here ", err)
            }
        }
        task.resume()
    }
}

