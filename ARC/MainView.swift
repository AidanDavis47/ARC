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



var mainlat : Double = 0
var mainLong : Double = 0
var mainAlt : Double = 0
var mainLoc : CLLocation? = nil

//had help from chat gpt for learning the syntax and how to actually pull coordinates

class GPSGrabber:NSObject, ObservableObject, CLLocationManagerDelegate{
    
    private var locManager = CLLocationManager() //creating a location manager
    @Published var curLoc: CLLocation? //create a var to store the current location
    @Published var coord: CLLocationDegrees = 0.0 //used for storing the coordinate we want
    
    //modify the initlizatoin function
    override init(){
        super.init()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization() //asks the user for authrorizatoin
        locManager.startUpdatingLocation() //starts keep track of the location
        
    }
    
    
    //now an actual function for manager the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations loc: [CLLocation]){
        if let location = loc.last { //gets the most recent location
            curLoc = location
            mainLoc = location //need this to pass to the next view
            mainlat = location.coordinate.latitude
            mainLong = location.coordinate.longitude
            mainAlt = location.altitude
            
            
            print(curLoc) //want to get the location and see if we also get elevatoin
            //print(location.altitude) //prints the altitude as well
            
            coord = location.coordinate.latitude
            
            //i want to pass the coordinates to the next screen
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
    
    
    
    
    
    
    
    
    //so i think it is because the value is nil because it takes awhile to get location so proabably want an if statement?
    
    @StateObject private var locationGrabber = GPSGrabber()
    
    
    
    var body: some View {
        
        
        
        
        
        //if statment might work, pete said it might take a while for it to actually appear
        
        
            //Text("TEST MAIN SCREEN")
            //Text("Lat: \(locationGrabber.coord)")
                
               
            
            NavigationView {
                VStack{
                    Image("startlogo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                        NavigationLink(destination: ArView()){
                            Text("AR Screen")
                        }
                        
                        
                    }
                    
                    
                }
            }
        
    }

            
            
            
            
            
            
            
    



#Preview {
    
    
}

