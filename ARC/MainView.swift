//
//  ContentView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/4/25.
//

import SwiftUI
import RealityKit
import ARKit
import CoreLocation // need this for location tracking stuff
import CoreLocationUI


//TO DO LIST:
//PLACE OBJECTS IN AR VIEW: technically done since we have a cube that appears in the screen, if there is time want to make more cubes show up and in random areas
//CONNECT TO GPS FOR LOCATION TRACKING: so this is technically done, need to figure out why my phone is not allowing access for stuff
//PICK UP OBJECTS: DONE for the cube yay





//had help from chat gpt for learning the syntax and how to actually pull coordinates

class GPSGrabber:NSObject, ObservableObject, CLLocationManagerDelegate{
    
    private var locManager = CLLocationManager() //creating a location manager
    @Published var curLoc: CLLocation? //create a var to store the current location
    @Published var coord: CLLocationDegrees = 0.0 //used for storing the coordinate we want
    
    //modify the initlizatoin function
    override init(){
        super.init()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locManager.requestWhenInUseAuthorization() //asks the user for authrorizatoin
        locManager.startUpdatingLocation() //starts keep track of the location
        
    }
    
    
    //now an actual function for manager the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations loc: [CLLocation]){
        if let location = loc.last { //gets the most recent location
            curLoc = location
            coord = location.coordinate.latitude
        }
    }
    
    
    //function for dealing with errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location error: \(error.localizedDescription)")
    }
    
    //function for managing when authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        switch manager.authorizationStatus{
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Acess Denied")
        case .notDetermined:
            print("not determined")
            break;
        default:
            break;
        }
    }
    
    
    //now the function to get the location
    func getLoc() -> CLLocationDegrees{
        locManager.requestLocation()
        return (locManager.location?.coordinate.latitude)!
    }
    
}













//getting some help with this stuff with chatGPT and random articles i have read
//had to go to AI even though i hate it because I have not used swift before and I am losing my mind trying to figure out the gps stuff





//constructor for the main view
struct MainView : View{
    
    
    
    
    
    
    /* old location getting function turns out i want to make a class for this stuff
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
     */
    
    //so i think it is because the value is nil because it takes awhile to get location so proabably want an if statement?
    
    @StateObject private var locationGrabber = GPSGrabber()
    
    
    
    var body: some View {
        
        
        
        
        
        //if statment might work, pete said it might take a while for it to actually appear
        
        
            Text("TEST MAIN SCREEN")
            Text("Lat: \(locationGrabber.coord)")
                
               
            
            NavigationView {
                VStack{
                    
                    NavigationLink(destination: SecondView()) {
                        //self.onAppear(){locationManager.checkLocationAuthorization()}
                        Text("TEST") //this is mainly being used to debug the gps location junk
                        
                        //current bug where i am unable to actually move to the screen, maybe because it is set as a navigation link, might want to just make a button that replaces this view with the ar view stuff, will want to ask pete
                        NavigationLink(destination: ArView()){
                            Text("AR Screen")
                        }
                        
                        
                    }
                    
                    
                }
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
            //.padding()
        
    



#Preview {
    
    
}

