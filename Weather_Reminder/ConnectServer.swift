//
//  ConnectServer.swift
//  Weather_Reminder
//
//  Created by allen on 2019/4/27.
//  Copyright © 2019 comp208.team4. All rights reserved.
//

import Foundation

// basic important value.
let id_field = "email"
let id_type = "s"
let SUPERTOKEN = "XvgcNiTgSPABTVqf"

// user's value.
var id_data = "" // test@test.com
var device_token = ""
var Password = "" // 123
var user_token = ""
var user_id = 0
var loginIsSucc = false

// sometimes need wait server response.
let semaphore = DispatchSemaphore.init(value: 0)
let requestQueue = DispatchQueue(label: "com.geselle.backgroundQueue", qos: .userInitiated)

// check the email address
struct MyRegex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern,
                                         options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,options: [],range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}

// add user. (must following check user)
func addUser(emailAdd:String, password:String){
    let url = URL(string: "http://142.93.34.33/add_user.php")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = "device_token=\(device_token)&email=\(emailAdd)&password=\(password)&token=\(SUPERTOKEN)".data(using: .utf8)
    
    requestQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            
            let responseString = String(data: data2, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                
                // Todo: add success or fail.
            
                semaphore.signal()
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
    
    
    requestQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            // check response
//            let responseString = String(data: data2, encoding: .utf8)
//            print("responseString = \(String(describing: responseString))")
            
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
func uploadEvent(){
    let url = URL(string: "http://142.93.34.33/add_event.php")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let startDate = gsPeriod["startDate"] ?? ""
    let endDate = gsPeriod["endDate"] ?? ""
    let lon = location2D["long"]!
    let lat = location2D["lat"]!
    
    let event = "{\"id\":\(id),\"title\":\"\(eventTitle)\",\"period\":{\"startDate\":\"\(startDate)\",\"endDate\":\"\(endDate)\" },\"alertDays\":\(gsAlertDays),\"remindTime\":\"\(gsRemindTime)\",\"sunny\":\"\(sunny)\", \"cloudy\":\"\(cloudy)\",\"windy\":\"\(windy)\",\"rainy\":\"\(rainy)\",\"snow\":\"\(snow)\",\"uvIndex\":\"\(uvIndex)\",\"humidity\":\"\(humidity)\",\"loc\":{\"lon\":\"\(lon)\",\"lat\":\"\(lat)\" },\"locName\":\"\(locName)\" }"
    request.httpBody = "event=\(event)&token=\(user_token)&user_id=\(user_id)".data(using: .utf8)
    
    requestQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            // check response
//            let responseString = String(data: data2, encoding: .utf8)
//            print("responseString = \(String(describing: responseString))")
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                for jsonKey in jsonResponse!.allKeys {
                    let theKey = jsonKey as! String
                    if theKey == "error"{
                        print("wrong")
                    }else{
                        if theKey == "id"{
                            id = jsonResponse![theKey] as! Int
                            print("event id:" + String(id))
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

// the fowlloing three struct are used to
// get json file and trans to event.
struct Period:Decodable {
    let startDate: String?
    let endDate: String?
}

struct Location:Decodable{
    let lon: String
    let lat: String
}

struct eventInCloud:Decodable {
    let id: Int
    let title:String
    let period:Period
    let alertDays: Int
    let remindTime: String
    let sunny: String
    let cloudy: String
    let windy: String
    let rainy: String
    let snow: String
    let uvIndex: String
    let humidity: String
    let loc: Location
    let locName: String
    let user_id: Int
}

var eventList = [eventInCloud]()

// download every events of this user.
func getEvents(){
    let url = URL(string: "http://142.93.34.33/get_events.php?token=\(user_token)&user_id=\(user_id)")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    requestQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let jsonData = data, error == nil else{ return }
            var resultDict: NSArray?
            do{
                let decoder = JSONDecoder()
                resultDict = try JSONSerialization.jsonObject(with:jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                eventList = try decoder.decode([eventInCloud].self, from: jsonData)
                
                semaphore.signal()
            }catch let err {
                print("error here ", err)
            }
        }
        task.resume()
    }
    return
}

// delete one event
func deleteEvent(eventId event_id :Int){
    let url = URL(string: "http://142.93.34.33/delete_event.php")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = "event_id=\(event_id)&token=\(user_token)&user_id=\(user_id)".data(using: .utf8)
    
    requestQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                for jsonKey in jsonResponse!.allKeys {
                    let theKey = jsonKey as! String
                    if theKey == "error"{
                        print("wrong")
                    }else{
                        print("delete success")
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

// update one event
func updateEvent(){
    let url = URL(string: "http://142.93.34.33/update_event.php")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let startDate = gsPeriod["startDate"] ?? ""
    let endDate = gsPeriod["endDate"] ?? ""
    let lon = location2D["long"]!
    let lat = location2D["lat"]!
    
    let event = "{\"id\":\(id),\"title\":\"\(eventTitle)\",\"period\":{\"startDate\":\"\(startDate)\",\"endDate\":\"\(endDate)\" },\"alertDays\":\(gsAlertDays),\"remindTime\":\"\(gsRemindTime)\",\"sunny\":\"\(sunny)\", \"cloudy\":\"\(cloudy)\",\"windy\":\"\(windy)\",\"rainy\":\"\(rainy)\",\"snow\":\"\(snow)\",\"uvIndex\":\"\(uvIndex)\",\"humidity\":\"\(humidity)\",\"loc\":{\"lon\":\"\(lon)\",\"lat\":\"\(lat)\" },\"locName\":\"\(locName)\" }"
    
    request.httpBody = "event=\(event)&token=\(user_token)&user_id=\(user_id)".data(using: .utf8)
    
    requestQueue.async {
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data2 = data, error == nil else{ return }
            
//            let responseString = String(data: data2, encoding: .utf8)
//            print("responseString = \(String(describing: responseString))")
            
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data2, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                for jsonKey in jsonResponse!.allKeys {
                    let theKey = jsonKey as! String
                    if theKey == "error"{
                        print("wrong")
                    }else{
                        if(theKey == "id"){
                            print("update successfully")
                        }
                    }
                }
            }catch let err {
                print("error here ", err)
            }
        }
        task.resume()
    }
}
