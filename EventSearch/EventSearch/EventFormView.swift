//
//  EventFormView.swift
//  EventSearch
//
//  Created by Mridul Shah on 4/7/23.
//

import SwiftUI
import Kingfisher

struct EventFormView: View {
    //Var declarations
    @ObservedObject private var formdata = FormDataViewModel()
    @State private var form_valid:Bool = false
    @State private var display_result:Bool = false
    @State private var display_sheet:Bool = false
    
    
    //Body
    var body: some View {
        
        VStack {
            NavigationView{
                
                Form {
                    
                    HStack{
                        Text("Keyword:")
                            .foregroundColor(Color.gray)
                        TextField("Required", text: $formdata.keyword)
                            .onChange(of: formdata.keyword) { x in
                                form_valid = formdata.check_form_valid()
                                
                            }
                    }
                    .onSubmit()
                    {
                        display_sheet = true
                        formdata.display_spinner = true
                        formdata.suggest_karo()
                        
                    }
                    .sheet(isPresented: $display_sheet ){
                        
                        if (formdata.display_spinner)
                        {
                            VStack
                            {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Loading...")
                                    .foregroundColor(Color.gray)
                                
                            }.id(UUID())

                        }
                        else
                        {
                            
                            Text("Suggestions")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 10.0)
                            
                            List{
                                ForEach(formdata.sugg_list, id: \.self) { sugg in
                                    Text("\(sugg)")
                                        .onTapGesture {
                                            formdata.keyword = sugg
                                            display_sheet = false
                                            
                                        }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                    HStack{
                        Text("Distance:")
                            .foregroundColor(Color.gray)
                        TextField("", text: $formdata.distance)
                    }
                    
                    HStack{
                        Text("Category:")
                            .foregroundColor(Color.gray)
                        Picker("", selection: $formdata.selectedCategory)
                        {
                            Text("Default").tag("Default")
                            Text("Music").tag("Music")
                            Text("Sports").tag("Sports")
                            Text("Arts & Theatre").tag("Arts & Theatre")
                            Text("Film").tag("Film")
                            Text("Miscellaneous").tag("Miscellaneous")
                            
                        }.pickerStyle(.menu)
                    }
                    
                    if formdata.autoDetLocation_toggle == false
                    {
                        HStack{
                            Text("Location:")
                                .foregroundColor(Color.gray)
                            TextField("Required", text: $formdata.location)
                                .onChange(of: formdata.location) { x in
                                    form_valid = formdata.check_form_valid()
                                }
                            
                        }
                    }
                    
                    Toggle("Auto-detect my location" , isOn: $formdata.autoDetLocation_toggle)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                        .onChange(of: formdata.autoDetLocation_toggle) { x in
                            
                            form_valid = formdata.check_form_valid()
                            if (x)
                            {
                                formdata.location = ""
                            }
                        }
                    
                    // Well I picked this up from ChatGPT, was running out of clean ideas.
 

                    HStack{
                        
                        Button("Submit") {
                        }
                        .padding(.horizontal, 35.0)
                        .padding(.vertical , 15.0)
                        .foregroundColor(.white)
                        .background(form_valid ? Color.red: Color.gray)
                        .cornerRadius(12)
                        .padding(.trailing, 25)
                        .onTapGesture {
                            if (form_valid)
                            {
                                display_result = true
                                formdata.submit_click()
                            }
                        }
                        
                        
                        Button("Clear") {
                            
                        }
                        .padding(.horizontal, 35.0)
                        .padding(.vertical , 15.0)
                        .foregroundColor(.white)
                        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
                        .cornerRadius(12)
                        .onTapGesture {
                            display_result = false
                            formdata.clickclear()
                        }
                        
                    }
                    .padding(.horizontal, 18.0)
                    .padding(.vertical, 15.0)
                    
                    //FORM END
                    //RESULT SECTION START
                    
                    if (display_result)
                    {
                        Section (header : Text(""))
                        {
                            Text("Results")
                                .font(.title3)
                                .fontWeight(.bold)
                            //TODO: FORMAT
                            if (formdata.display_table1)
                            {
                                
                                ForEach(formdata.event_list, id: \.self) { subarray in
                                    NavigationLink(destination: EventDetailsView(eventidfromtable: subarray[6] ?? "")) {
                                        HStack {
                                            //Text("\(formdata.event_details.count)")
                                            Text("\(subarray[0] ?? "")|\(String(subarray[1]?.prefix(5) ?? "")) ")
                                                .font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/)
                                                .fontWeight(.thin)
                                                .foregroundColor(/*@START_MENU_TOKEN@*/.gray/*@END_MENU_TOKEN@*/)
                                            //Text("\(subarray[2] ?? "")")
                                            
                                            let processor = RoundCornerImageProcessor(cornerRadius: 10)
                                            KFImage.url(URL(string: subarray[2] ?? ""))
                                                .setProcessor(processor)
                                                .loadDiskFileSynchronously()
                                                .cacheMemoryOnly()
                                                .onSuccess { result in  }
                                                .onFailure { error in }
                                                .resizable()
                                                .frame(width: 60.0, height: 60.0)
                                            
                                            //AsyncImage(url: URL(string: subarray[2] ?? ""))
                                            Text("\(subarray[3] ?? "")").lineLimit(3)
                                            //Text("\(subarray[4] ?? "")")
                                            Text("\(subarray[5] ?? "")")
                                            //Text("\(subarray[6] ?? "")")
                                        }
                                    }
                                }
                                if (formdata.event_list.count == 0)
                                {
                                    Text("No result available")
                                        .foregroundColor(Color.red)
                                    
                                }
                            }
                            else
                            {
                                    VStack()
                                    {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Text("Please Wait...")
                                            .foregroundColor(.gray)
                                        
                                    }
                                    .id(UUID())
                                    .frame(maxWidth: .infinity)
                                
                                
                                
                            }
                            
                        }
                    }
                    
                    
                }//Form end
                .navigationTitle(Text("Event Search"))
                //Ref Code : https://stackoverflow.com/questions/57024263/how-to-navigate-to-a-new-view-from-navigationbar-button-click-in-swiftui
                .navigationBarItems(trailing:
                                        NavigationLink( destination: FavView() )
                                    {
                    Image(systemName: "heart.circle")
                        .imageScale(.large)
                })
            }//Navview End
            
        }//Vstack end
        
    }
}

struct EventFormView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView()
    }
}



//References:
//
//https://stackoverflow.com/questions/75570322/swiftui-progressview-in-list-can-only-be-displayed-once
//
//
//
