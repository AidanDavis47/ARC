//
//  ContentView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/4/25.
//

import SwiftUI
import RealityKit
import CoreLocation // need this for location tracking stuff
import CoreLocationUI


//TO DO LIST:
//PLACE OBJECTS IN AR VIEW: technically done since we have a cube that appears in the screen, if there is time want to make more cubes show up and in random areas
//CONNECT TO GPS FOR LOCATION TRACKING: this one is a bit more difficult than expected, currently only getting nil values, spent 6 or so hours trying to figure this out an still no luck, ask pete for help
//PICK UP OBJECTS: To Start







//global var stuff
var coordinate = 0.800 //just a place holder for the coordinate variable, may be needed may not be needed













//getting some help with this stuff with chatGPT and random articles i have read
//had to go to AI even though i hate it because I have not used swift before and I am losing my mind trying to figure out the gps stuff




struct MainView : View{
    func getLocation(){ //turns out have to declare this within the struct or a class, did not want to make an entirely new class just yet
        let locManager = CLLocationManager() //create a location manager var
       
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //try to get the best accuracy at the moment
        locManager.requestWhenInUseAuthorization() //requesting authorization
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation() //start updating the location
        
        coordinate = locManager.location?.coordinate.latitude ?? 848 //xcode gave me a "fix" for this not sure what it does exactly, supposedly 848 is the default value if the value is nil very interesting, had another thing where it could force unwrap but that would crash the app
        print(locManager.location?.coordinate) //debugging
        
        
        
        //going to do a if statement to find out if location services are even enabled
        //still getting a nil value
        if CLLocationManager.locationServicesEnabled(){ //weird purple error message occurs here
            locManager.requestWhenInUseAuthorization()
            locManager.startUpdatingLocation()
            print("location service work") //so i am getting this which means it is technically working at the moment
        }else{
            print("Location service no work") //debugging
        }
        
        if locManager.location?.coordinate == nil { //this if statement does not catch it still goes infinite and then crashes
            getLocation()
        }
         
         
         
    }
    
    //so i think it is because the value is nil because it takes awhile to get location so proabably want an if statement?
    
    
   
    
    var body: some View {
        
   
        
        
        
        //if statment might work, pete said it might take a while for it to actually appear
        
        
        Text("TEST MAIN SCREEN")
        Button{
            getLocation()
        } label: {
            Text("Get Location")
        }
        Text("\(coordinate)")
            NavigationView {
                
                NavigationLink(destination: SecondView()) {
                    //self.onAppear(){locationManager.checkLocationAuthorization()}
                    Text("TEST") //this is mainly being used to debug the gps location junk
                    
                    
                    NavigationLink(destination: ArView()){
                        Text("AR Screen")
                    }
                    
                    
                }
                
                
            }
            
            
            
            
            
            
            
            /* this whole commented chunk is a template for the ar aspect, just keeping it around until we figure out how to switch screen modes
             RealityView { content in
             
             // Create a cube model
             let model = Entity()
             let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
             let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
             model.components.set(ModelComponent(mesh: mesh, materials: [material]))
             model.position = [0, 0.05, 0]
             
             // Create horizontal plane anchor for the content
             let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
             anchor.addChild(model)
             
             // Add the horizontal plane anchor to the scene
             content.add(anchor)
             
             content.camera = .spatialTracking
             
             }*/
            //.edgesIgnoringSafeArea(.all)
            
            //stuff from xcode tutorial provided by apple yay :)
            .padding()
        
    }

}

#Preview {
    MainView()
    
}

