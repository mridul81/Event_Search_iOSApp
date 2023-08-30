//
//  EventDetailsViewModel.swift
//  EventSearch
//
//  Created by Mridul Shah on 4/8/23.
//

import Foundation
import Alamofire
import SwiftyJSON


struct ArtistData : Codable,Hashable
{
    var name : String
    var popularity : Int
    var followers : String
    var spotify : String
    var image : String
    var id : String
    var album_1 : String
    var album_2 : String
    var album_3 : String
}

struct VenueData : Codable,Hashable
{
    var name : String
    var line1 : String
    var city : String
    var state : String
    var phone : String
    var openhours : String
    var generalrule : String
    var childrule : String?
    var latitude : String
    var longitude : String
}

struct EventData : Codable, Hashable
{
    var evname : String
    var date : String
    var time : String
    var artist : String
    var musicartist : [String]
    var venue : String
    var segment : String
    var genre : String
    var subgenre : String
    var type : String
    var subtype : String
    var pricemin : String
    var pricemax : String
    var pricecur : String
    var ticket : String
    var buyat : String
    var seatmap : String
    var evid  : String
    
}

public class EventDetailsViewModel: ObservableObject {
    

    @Published var eventdetails: EventData = EventData(evname: "", date: "", time: "", artist: "", musicartist: [], venue: "", segment: "", genre: "", subgenre: "", type: "", subtype: "", pricemin: "", pricemax: "", pricecur: "", ticket: "", buyat: "", seatmap: "", evid: "")
    
    @Published var venuedetails: VenueData = VenueData(name: "", line1: "", city: "", state: "", phone: "", openhours: "", generalrule: "", childrule: "", latitude: "", longitude: "")
    
    @Published var artistdetails:[ArtistData] = []
    //@Published var show_spinner:Bool = true
    @Published var artist_data_complete:Bool = false
    @Published var venue_data_complete:Bool = false
    @Published var event_data_complete:Bool = false
    @Published var genre_output:String = ""

    
    
    func event_tab(event_id: String)
    {

        let url = "https://iosbackend81.wn.r.appspot.com/eventdetails/?evid=" + event_id
        print(url)
        AF.request(url, method: .get).responseDecodable(of: EventData.self) { response in
            switch response.result {

            case .success(let data):
                self.eventdetails = data
                print(self.eventdetails)
                var res = [String]()
                res.append(self.eventdetails.segment)
                res.append(self.eventdetails.genre)
                res.append(self.eventdetails.subgenre)
                res.append(self.eventdetails.type)
                res.append(self.eventdetails.subtype)
                let separator = "|"
                let final = res.filter{ $0 != "" }
                self.genre_output = final.joined(separator: separator)
                
                
                if (self.eventdetails.musicartist != [])
                {
                    self.artist_tab(artist_list: self.eventdetails.musicartist)
                }
                else
                {
                    self.artist_data_complete = true
                }
                self.venue_tab(venue_name: self.eventdetails.venue)
                self.event_data_complete = true


            case .failure(let error):
                print(error)
                self.event_data_complete = true
            }
        }
    }
    
    
    func venue_tab(venue_name: String)
    {

        let url = "https://iosbackend81.wn.r.appspot.com/venuedetails/"
        let v_params = ["venuename": venue_name]
        AF.request(url, method: .get , parameters: v_params).responseDecodable(of: VenueData.self) { response in
            switch response.result {

            case .success(let data):
                self.venuedetails = data
                print(self.venuedetails)
                self.venue_data_complete = true
                //self.show_spinner = false

            case .failure(let error):
                print(error)
                self.venue_data_complete = true
                //self.show_spinner = false
            }
        }
    }
    
    
    func artist_tab(artist_list:[String])
    {
        let j_string = artist_list.joined(separator: ",")
        let url = "https://iosbackend81.wn.r.appspot.com/artistdetails/"
        let a_params = ["artistlist": j_string]
       
        AF.request(url, method: .get , parameters: a_params).responseDecodable(of: [ArtistData].self) { response in
            switch response.result {

            case .success(let data):
                self.artistdetails = data
               
                print(self.artistdetails)
                self.artist_data_complete = true

            case .failure(let error):
                print(error)
                
                self.artist_data_complete = true
                
            }
        }
    }

    
    func test()
    {
        print (self.eventdetails)
    }
    
    
}
