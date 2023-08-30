//
//  Test.swift
//  EventSearch
//
//  Created by Mridul Shah on 4/5/23.
//

import Foundation
import Alamofire
import SwiftyJSON


public class FormDataViewModel: ObservableObject {

    @Published var keyword = ""
    @Published var distance = "10"
    @Published var location = ""
    @Published var selectedCategory = "Default"
    @Published var lat_lng = ""
    @Published var event_list: [[String?]] = []
    @Published var sugg_list: [String] = []

    @Published var bool_sugg_sheet: Bool = false
    @Published var display_table1: Bool = false
    @Published var autoDetLocation_toggle: Bool = false
    @Published var display_spinner:Bool = true
    
    
    func clickclear()
    {
        self.keyword = ""
        self.distance="10"
        self.location=""
        self.selectedCategory="Default"
        self.autoDetLocation_toggle =  false
        self.display_table1 = false
        self.event_list.removeAll()
    }
        
    func check_form_valid() -> Bool
    {
        
        if (keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        {
            return false
        }
        else
        {
            if (autoDetLocation_toggle == false) && (location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            {
                return false
            }
            else
            {
                return true
                
            }
        }
    }
    
// Separate functions does not works because of async calls so had to change the code.
// Keep it in case I get some idea to work on it later and divide the code
//func set_location()
//    {
//        if autoDetLocation_toggle == false
//        {
//            print(location , selectedCategory, distance,keyword , autoDetLocation_toggle)
//            print("Location toggle func is running")
//            //for URL string encoding have to do paremeters apparently. Sigh.
//            let my_parameters = [ "address": location,
//                "key" : "AIzaSyBHjusVw2ZkLUs6iFd-CW15zisliXcodEA" ]
//
//            Alamofire.AF.request("https://maps.googleapis.com/maps/api/geocode/json?", parameters: my_parameters).responseJSON { response in
//                switch response.result {
//                case .success(let data):
//
//                    let f = JSON(data)
//
//                    print(f["results"][0]["geometry"]["location"]["lat"].stringValue)
//                    print(f["results"][0]["geometry"]["location"]["lng"].stringValue)
//                    self.lat_lng = f["results"][0]["geometry"]["location"]["lat"].stringValue+","+f["results"][0]["geometry"]["location"]["lng"].stringValue
//                    print(self.lat_lng)
//
//
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
//    }
//
//    func autoDetLocation_function()
//    {
//
//    }
    
    func submit_click()
    {
        
        //1. Clear variables and initialize whatever should be
        self.event_list = []
        self.display_table1 = false
        
        //2.
        

        //Fix location latitude_longitude
        
        if autoDetLocation_toggle == false
        {
            
            //for URL string encoding have to use AlamoFire paremeters apparently. Nothing as easy as URLencoding.
            let my_parameters = [ "address": location,
                                  "key" : "AIzaSyBHjusVw2ZkLUs6iFd-CW15zisliXcodEA" ]
            Alamofire.AF.request("https://maps.googleapis.com/maps/api/geocode/json?", parameters: my_parameters).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let f = JSON(data)
                    self.lat_lng = f["results"][0]["geometry"]["location"]["lat"].stringValue+","+f["results"][0]["geometry"]["location"]["lng"].stringValue
                    print(self.lat_lng)
                    self.form_backend()
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        else
        {
            AF.request("https://ipinfo.io/json?token=c11dd5ff3ce97a").responseJSON { response in
                
                switch response.result {
                case .success(let json):
                    let f = JSON(json)
                    //print(f)
                    //print(f["loc"].stringValue)
                    self.lat_lng = f["loc"].stringValue
                    self.form_backend()
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    func form_backend()
    {
        
        let search_parameters = ["Keyword": keyword  , "Distance" : distance , "Category" : selectedCategory , "Location": lat_lng ]
        print(search_parameters)


        AF.request("https://augmented-voice-700366.wl.r.appspot.com/searchform/", method: .get , parameters: search_parameters).responseData { response in
            switch response.result {

            case .success(let data):
                let f = JSON(data)
                for item in f {
                    //                        let stringArray = [String]
                    //                        if item.1[0].string == nil { print("Time is blank and this check succeeds")}
                    //                        print(type(of: item.1[1].string))
                    let stringArray = item.1.map{ $0.1.string }
                    print(stringArray)
                    self.event_list.append(stringArray)
                }
                self.display_table1 = true

            case .failure(let error):
                print(error) }
        }
    }
    
    func suggest_karo()
    {
        self.sugg_list = []
        
        let sugg_url = "https://augmented-voice-700366.wl.r.appspot.com/suggestform"
        let sugg_params = [ "Keyword": self.keyword]
        AF.request(sugg_url, method: .get, parameters: sugg_params).responseDecodable(of: [String].self) { response in
            switch response.result {
                
            case .success(let data):
                print(data)
                self.sugg_list = data
                sleep(1) //Slowing it to show the LOADING spinner for Video otherwise its too fast
                self.display_spinner = false
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
}
