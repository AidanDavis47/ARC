//
//  ContentView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/4/25.
//

import SwiftUI
import RealityKit
import CoreLocation
import CoreLocationUI
//got this from a very helpfule medium artical link in google doc






class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    var currentLocation: CLLocation?
    
    func checkLocationAuthorization(){
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location restricted")
        case .denied:
            print("Location denied")
        case .authorizedAlways:
            print("Location authorized alway")
            lastKnownLocation = manager.location?.coordinate
        case .authorizedWhenInUse:
            print("location authorized when in use")
            lastKnownLocation = manager.location?.coordinate
            
        
            
            
            @unknown default:
            print("location service disabled")
            
        
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    
    
    func locationManage(_manager: CLLocationManager, didUpdateLocation locations: [CLLocation]){
        lastKnownLocation = locations.first?.coordinate
    }
}



struct MainView : View {
    @StateObject private var locationManager = LocationManager()
    

    
    var body: some View {
        
        let coordinate = locationManager.lastKnownLocation
        
        
        //if statment might work, pete said it might take a while for it to actually appear
        
        if (coordinate != nil){
            NavigationView {
                
                NavigationLink(destination: SecondView()) {
                    self.onAppear(){locationManager.checkLocationAuthorization()}
                    Text("\(coordinate?.longitude)")
                    
                    
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

}

#Preview {
    MainView()
}
