//
//  APIViewController.swift
//  onTheMap
//
//  Created by Lola M on 7/11/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class APIViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    static func chekError(error: Error?, response: URLResponse?) -> String? {
        if error != nil {
            return error?.localizedDescription
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode
            else {
            let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                return statusCodeError.localizedDescription
        }
        guard statusCode >= 200 && statusCode <= 299 else {
            var errorMessage = ""
            switch statusCode {
            case 400:
                errorMessage = "Bad Request"
            case 401:
                errorMessage = "Invalid Credentials"
            case 403:
                errorMessage = "Unauthrized"
            case 405:
                errorMessage = "HTTP Method Not Allowed"
            case 410:
                errorMessage = "URL Changed"
            case 500:
                errorMessage = "Server Error"
            default:
                errorMessage = "Try again"
            }
            return errorMessage
        }
        return nil
    }
    
    
    static func Login(username: String, password: String, complition: @escaping (_ errorMessage: String?) -> Void)
    {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let errorMessage = chekError(error: error, response: response) {
                complition(errorMessage)
                return
            }
            
            
            let subdata = data![5..<data!.count]
            print(String(data: subdata, encoding: .utf8)!)
            
            let json: Any
            do {
                json = try JSONSerialization.jsonObject(with: subdata, options: [])
            } catch {
                complition(error.localizedDescription)
                return
            }
            guard let dict = json as? [String:Any] else {
                complition("we couldn't catch json object to swift dictionary")
                return
            }
            
            if let udacityError = dict["error"] as? String {
                complition(udacityError)
                return
            }
            
            guard let account = dict["account"] as? [String: Any],
                let key = account["key"] as? String else {
                    complition("account or key is nil")
                    return
            }
            
            Global.loginKey = key
            
            complition(nil)
        }
        task.resume()
    }
    
    
    
    
    static func getRandomUserData (complition: @escaping (_ errorMessage: String?) -> Void) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(Global.loginKey ?? "")")!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = chekError(error: error, response: response) {
                complition(errorMessage)
                return
            }
            
            let subdata = data![5..<data!.count]
            print(String(data: subdata, encoding: .utf8)!)
            
            let json: Any
            do {
                json = try JSONSerialization.jsonObject(with: subdata, options: [])
            } catch {
                complition(error.localizedDescription)
                return
            }
            guard let dict = json as? [String:Any] else {
                complition("we couldn't catch json object to swift dictionary")
                return
            }
            
            let firstName: String?
            let lastName: String?
            
            if let user = dict["user"] as? [String: Any] {
                firstName = user["firs_tName"] as? String
                lastName = user["last_Name"] as? String
            } else {
                firstName = dict["firs_tName"] as? String
                lastName = dict["last_Name"] as? String
            }
            
            Global.randomFirstName = firstName ?? "Lola"
            Global.randomLasttName = lastName ?? "Masari"
            complition(nil)
        }
        task.resume()
    }
    
    
    
    
    static func getStudentLocation (complition: @escaping (String?) -> Void) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let errorMessage = chekError(error: error, response: response) {
                complition(errorMessage)
                return
            }
            
            
            let json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                complition(error.localizedDescription)
                return
            }
            guard let dict = json as? [String:Any] else {
                complition("we couldn't catch json object to swift dictionary")
                return
            }
            
            guard let results = dict["results"] as? [[String: Any]] else {
                complition("couldn't get the result")
                return
            }
            
            let dataFromResults = try! JSONSerialization.data(withJSONObject: results, options: [])
            let studentsLocation = try! JSONDecoder().decode([studentLocation].self, from: dataFromResults)
            
            Global.shared.studentsLocations = studentsLocation
            
            complition(nil)
        }
        task.resume()
    }
    
    
    static func postStudentLocation (locationName: String, locationCoordinate: CLLocationCoordinate2D, mediaURL: String, complition: @escaping (String?) -> Void) {
        let loginKey = Global.loginKey ?? ""
        let randomFirstName = Global.randomFirstName ?? ""
        let randomLasttName = Global.randomLasttName ?? ""
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(loginKey)\", \"firstName\": \"\(randomFirstName)\", \"lastName\": \"\(randomLasttName)\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(locationCoordinate.latitude), \"longitude\": \(locationCoordinate.longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let errorMessage = chekError(error: error, response: response) {
                complition(errorMessage)
                return
            }
            complition(nil)
        }
        task.resume()
    }
    
    
    
    
    static func deletesSession(complition: @escaping (String?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let errorMessage = chekError(error: error, response: response) {
                complition(errorMessage)
                return
            }
            complition(nil)
        }
        task.resume()
    }
}
