//
//  FavView.swift
//  EventSearch
//
//  Created by Mridul Shah on 4/14/23.
//

import SwiftUI

struct FavView: View {
    
    @State var favoriteEvents = [[String: String]]()
    @State var isFavListEmpty = false
    
    var body: some View {
        
        
        NavigationView{
            
            if (favoriteEvents.count == 0)
            {
                VStack
                {
                    Text("No Favorites found")
                        .foregroundColor(.red)
                }
            }
            else
            {
                List{
                    ForEach(favoriteEvents, id: \.self) { event in
                        HStack {
                            Text(event["date"] ?? "Unknown Date")
                                .font(.system(size: 14))
                                .fixedSize(horizontal: true, vertical: false)
                            Text(event["name"] ?? "Unknown Event")
                                .lineLimit(2)
                                .font(.system(size: 14))
                            Text(event["genre"] ?? "Unknown Genre")
                                .font(.system(size: 14))
                            Text(event["venue"] ?? "Unknown Venue")
                                .font(.system(size: 14))
                        }
                    }
                    .onDelete(perform: removeRows)
                }//List end
            }
            
        }
        .navigationTitle("Favorites")
        .onAppear {
            if let storedFavoriteEvents = UserDefaults.standard.array(forKey: "favoriteEvents") as? [[String: String]] {
                self.favoriteEvents = storedFavoriteEvents
                if self.favoriteEvents.count == 0 { self.isFavListEmpty = true }
            }
        }
        
        
    }
    
    func removeRows(at offsets: IndexSet)
    {
        //Actual Remove functionality for UserDefaults
        favoriteEvents.remove(atOffsets: offsets)
        UserDefaults.standard.set(favoriteEvents, forKey: "favoriteEvents")
    }
    
}

struct FavView_Previews: PreviewProvider {
    static var previews: some View {
        FavView()
    }
}

//References for the above code :
//https://www.hackingwithswift.com/books/ios-swiftui/deleting-items-using-ondelete
//
