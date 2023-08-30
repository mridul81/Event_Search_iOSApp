//
//  EventDetailsView.swift
//  EventSearch
//
//  Created by Mridul Shah on 4/8/23.
//

import SwiftUI
import Kingfisher
import MapKit

struct EventDetailsView: View {
    
    var eventidfromtable:String
    @StateObject var eventvm = EventDetailsViewModel()
    @StateObject var favvm = FavViewModel()
    @State private var show_map:Bool = false
    
    // https://sarunw.com/posts/how-to-change-swiftui-font-size/
    
    
    var body: some View {
        
        if (!eventvm.event_data_complete || !eventvm.artist_data_complete || !eventvm.venue_data_complete)
        {
            VStack
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Loading...")
                    .foregroundColor(Color.gray)

            }
            .id(UUID())
                        .onAppear
                        {
                            print( "IMMMPPORTANT" , favvm.fav_list )
                            eventvm.event_tab(event_id: eventidfromtable)
                            let check_fav = favvm.fav_list.contains { ev in
                                ev["id"] == eventidfromtable
                            }
                            print(check_fav)
                            favvm.isFavorite = check_fav
                            favvm.updateButtonAppearance()
            
                        }
        }
        else
        {

        TabView {
                VStack{
                    Text("\(eventvm.eventdetails.evname)")
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .padding(.horizontal,15.0)
                        .padding(.bottom)
                        .font(.system(size: 24))

                    Group
                    {
                        HStack {
                            Text("Date")
                                .fontWeight(.bold)
                            Spacer()
                            Text("Artist | Team")
                                .fontWeight(.bold)
                        }.padding(.horizontal, 15.0)

                        HStack {
                            Text("\(self.eventvm.eventdetails.date)")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(self.eventvm.eventdetails.artist)")
                                .lineLimit(1)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 15.0)
                        .padding(.bottom, 5.0)


                        HStack {
                            Text("Venue")
                                .fontWeight(.bold)
                            Spacer()
                            Text("Genre")
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 15.0)

                        HStack {
                            Text("\(eventvm.eventdetails.venue)")
                                .lineLimit(1)
                                .foregroundColor(.gray)
                            Spacer()

                            Text("\(eventvm.genre_output)")
                                .lineLimit(1)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 15.0)
                        .padding(.bottom, 5.0)


                        HStack {
                            Text("Price Range")
                                .fontWeight(.bold)
                            Spacer()
                            Text("Ticket Status")
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 15.0)

                        HStack {
                            if let pricemin = eventvm.eventdetails.pricemin, let pricemax = eventvm.eventdetails.pricemax, !pricemin.isEmpty, !pricemax.isEmpty {
                                Text("\(eventvm.eventdetails.pricemin)-\(eventvm.eventdetails.pricemax)")
                                    .padding(.top, 0.0)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(eventvm.eventdetails.ticket)")
                                .padding(.horizontal, 16.0)
                                .padding(.bottom, 5.0)
                                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.green/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.white)
                                .cornerRadius(7)


                        }
                        .padding(.horizontal, 15.0)
                        .padding(.bottom, 5.0)
                        .padding(.top, 0.0)
                    }

                    Group {

                        Button(action : {

                            let eventId =  eventidfromtable
                            let eventName = eventvm.eventdetails.evname
                            let eventDate = eventvm.eventdetails.date
                            let eventGenre = eventvm.genre_output
                            let eventVenue = eventvm.eventdetails.venue
                            favvm.fav_list = UserDefaults.standard.object(forKey: "favoriteEvents") as? [[String: String]] ?? [[String: String]]()

                            let eventInfo: [String: String] = [
                                "id": eventId,
                                "name": eventName,
                                "date": eventDate,
                                "genre": eventGenre,
                                "venue": eventVenue
                            ]

                            if favvm.isFavorite {

                                favvm.fav_list.removeAll { $0["id"] == eventId }
                                favvm.isFavorite = false
                                favvm.updateButtonAppearance()
                                showToast(message: "Removed from favorites")
                                print("Fav events is \(favvm.fav_list)")
                            }

                            else {

                                favvm.fav_list.append(eventInfo)
                                favvm.isFavorite = true
                                favvm.updateButtonAppearance()
                                showToast(message: "Added to favorites")
                                print("Fav events is \(favvm.fav_list)")
                            }

                            UserDefaults.standard.set(favvm.fav_list, forKey: "favoriteEvents")


                        })
                        { Text(favvm.SaveButtonText)
                                .padding(.horizontal, 15.0)
                                .padding(.vertical)
                                .background(favvm.buttonBackgroundColor)
                                .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                                .cornerRadius(12)
                        }


                    //}

                    //                        .onAppear {
                    //                            // Check if the event is already in favorites
                    //                            let eventExists = favoriteEvents.contains { event in
                    //                                event["id"] == eventvm.eventdetails.evid
                    //                            }
                    //                            // Update the state variable
                    //                            isFavorite = eventExists
                    //                            // Update the button appearance
                    //                            self.updateButtonAppearance()
                    //                        }
                    //                        //                .onTapGesture {
                    //                }

                    //let processor = RoundCornerImageProcessor(cornerRadius: 10)
                    KFImage.url(URL(string:eventvm.eventdetails.seatmap))
                    //.setProcessor(processor)
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .onSuccess { result in  }
                        .onFailure { error in }
                        .resizable()
                        .frame(width: 250.0, height: 250.0)

                    //Text("Buy Ticket At : [Ticketmaster](\(eventvm.eventdetails.buyat))")
                    if let mapurl = URL(string: eventvm.eventdetails.buyat)
                    {
                        HStack {
                            Text("Buy Ticket At:")
                                .fontWeight(.bold)
                                .font(.system(size: 20))

                            Link("Ticketmaster", destination: mapurl)
                        }
                    }

                    HStack {
                        Text ("Share on : ")
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                        Image("fb")
                            .resizable()
                            .frame(width: 50, height: 50 )
                            .onTapGesture {

                                let fb_url = URL(string:"https://www.facebook.com/sharer/sharer.php?u=\(eventvm.eventdetails.buyat)&src=sdkpreparse")
                                UIApplication.shared.open(fb_url! , options: [:], completionHandler: nil)
                                print(fb_url!)
                            }
                        Image("twitter")
                            .resizable()
                            .frame(width: 50, height: 50 )
                            .onTapGesture {

                                let name_encode = eventvm.eventdetails.evname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                let tweet_url = URL(string:"https://twitter.com/intent/tweet?text=Check%20\(name_encode)%20on%20Ticketmaster.%0A\(eventvm.eventdetails.buyat)")
                                UIApplication.shared.open(tweet_url! , options: [:], completionHandler: nil)
                                print(tweet_url!)
                            }
                    }
                }
                Spacer()

            }
            .padding(.bottom,40.0)
            .tabItem {
                Label("Events" , systemImage: "text.bubble")
            }

            // TAB2 DATA

            if (eventvm.artistdetails.count == 0)
            {
                Text("No music related artist details to show")
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .tabItem {
                        Label("Artist/Team" , systemImage: "guitars.fill")
                    }
            }
            else
            {

                ScrollView{

                    ForEach(eventvm.artistdetails, id: \.self) { artist in
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                VStack(alignment: .leading){
                                    let processor_one = RoundCornerImageProcessor(cornerRadius: 20)
                                    KFImage.url(URL(string: artist.image))
                                        .setProcessor(processor_one)
                                        .loadDiskFileSynchronously()
                                        .cacheMemoryOnly()
                                        .resizable()
                                        .frame(width: 100.0, height: 100.0)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(artist.name)")
                                        .fontWeight(.bold)
                                        .font(.system(size: 20))
                                    Spacer()
                                    HStack{
                                        Text("\(artist.followers)")
                                            .fontWeight(.bold)
                                            .font(.system(size: 16))

                                        Text("Followers")

                                    }
                                    HStack{
                                        Link(destination: URL(string: artist.spotify)!, label: {
                                            Image("spotify_logo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)

                                        })
                                        Text("Spotify")
                                            .foregroundColor(.green)
                                    }


                                    //Text("\(artist.name)")
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Popularity")
                                        .fontWeight(.bold)
                                        .font(.system(size: 16))
                                        .multilineTextAlignment(.trailing)
                                    Spacer()
                                    PopularityView(popularity: artist.popularity)
                                }
                                Spacer()

                            }

                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            HStack{
                                Text("Popular Albums")

                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 20)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                Spacer()
                            }

                            HStack{

                                Spacer()
                                let processor_one = RoundCornerImageProcessor(cornerRadius: 20)
                                KFImage.url(URL(string: artist.album_1))
                                    .setProcessor(processor_one)
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .resizable()
                                    .frame(width: 90.0, height: 90.0)
                                Spacer()


                                KFImage.url(URL(string: artist.album_2))
                                    .setProcessor(processor_one)
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .resizable()
                                    .frame(width: 90.0, height: 90.0)
                                Spacer()

                                KFImage.url(URL(string: artist.album_3))
                                    .setProcessor(processor_one)
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .resizable()
                                    .frame(width: 90.0, height: 90.0)
                                Spacer()
                            }
                            Spacer()
                        }

                        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(red: 0.298, green: 0.298, blue: 0.298)/*@END_MENU_TOKEN@*/)
                        .cornerRadius(15)
                        .padding(15)
                        .foregroundColor(.white)

                    }

                }
                .padding(.top,3)
                .tabItem {
                    Label("Artist/Team" , systemImage: "guitars.fill")
                }
            }





        //TAB 3 DATA
        VStack {

            Group
            {
                Text("\(eventvm.eventdetails.evname)")
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .padding(.horizontal,15.0)
                    .padding(.bottom,20.0)
                    .padding(.top, -35.0)
                    .font(.system(size: 20))
                

                Text("Name")
                    .fontWeight(.bold)
                Text("\(eventvm.venuedetails.name)")
                    .foregroundColor(.gray)
                    .padding(.bottom,15.0)
                


                Text("Address")
                    .fontWeight(.bold)
                Text("\(eventvm.venuedetails.line1)")
                    .foregroundColor(.gray)
                    .padding(.bottom,15.0)
                


                Text("Phone Number")
                    .fontWeight(.bold)
                Text("\(eventvm.venuedetails.phone)")
                    .foregroundColor(.gray)
                    .padding(.bottom,15.0)
                
            }

            Group
            {

                Text("Open Hours")
                    .fontWeight(.bold)
                ScrollView{
                    Text("\(eventvm.venuedetails.openhours)")
                        .foregroundColor(.gray)
                }.padding(.horizontal, 20.0)
                //.frame(width: 380.0, height: 90.0)


                Text("General Rule")
                    .fontWeight(.bold)
                ScrollView(.vertical){
                    Text("\(eventvm.venuedetails.generalrule)")
                        .foregroundColor(.gray)
                }.padding(.horizontal, 20.0)
                //.frame(width: 380.0, height: 90.0)

            }


            Group
            {
                Text("Child Rule")
                    .fontWeight(.bold)
                ScrollView(.vertical){
                    Text(eventvm.venuedetails.childrule ?? "")
                        .foregroundColor(.gray)
                }.padding(.horizontal, 20.0)

            }


            VStack{
                Button("Show Venue on maps") {
                    self.show_map = true
                }
            }
            .padding(.horizontal, 15.0)
            .padding(.vertical , 15.0)
            .foregroundColor(.white)
            .background(.red)
            .cornerRadius(12)
            .buttonStyle(BorderlessButtonStyle())

            .sheet(isPresented: $show_map, content: {
                MapView(latitude: Double(eventvm.venuedetails.latitude) ?? 0.0, longitude: Double(eventvm.venuedetails.longitude) ?? 0.0)
                    .padding(10)
            } )

        }
        .padding(.bottom, 15.0)
        .tabItem {
            Label("Venue" , systemImage: "location.fill")
        }


    }//Tab view end

}//Else
    
} //Body View end
} //EventDetails View end


struct PopularityView: View {
    var popularity: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(.gray)
            Circle()
                .trim(from: 0.0, to: CGFloat(min((Double(popularity))/100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 15.0))
                .foregroundColor(.orange)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text("\(popularity)")
                .font(.system(size: 25))
        }
        .frame(width: 60, height: 60)
    }
}


struct MapView: UIViewRepresentable{
    
    var latitude: Double
    var longitude: Double
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
}

func showToast(message: String) {
    let toastLabel = UILabel()
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    toastLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.height-100, width: UIScreen.main.bounds.width - 40, height: 50)
    UIApplication.shared.keyWindow?.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}




struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(eventidfromtable : "" )
    }
}


//
//References used:
//https://www.hackingwithswift.com/quick-start/swiftui/how-to-respond-to-view-lifecycle-events-onappear-and-ondisappear
//


