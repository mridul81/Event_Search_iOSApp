//
//  FavViewModel.swift
//  EventSearch
//
//  Created by Mridul Shah on 5/3/23.
//

import Foundation
import SwiftUI


public class FavViewModel: ObservableObject {
    
    static let sharedUserDefaults = UserDefaults.standard
    @Published var fav_list = sharedUserDefaults.object(forKey: "favoriteEvents") as? [[String: String]] ?? [[String: String]]()
    @Published var isFavorite = false
    @Published var SaveButtonText = "Save Event"
    @Published var buttonBackgroundColor = Color.blue
    
    
    func updateButtonAppearance() {
        if self.isFavorite {
                self.buttonBackgroundColor = Color.red
                self.SaveButtonText = "Remove F..."
            }
        else {
                self.buttonBackgroundColor = Color.blue
                self.SaveButtonText = "Save Event"
            }
    }
    
}
