//
//  arview.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//


import SwiftUI
import RealityKit
import ARKit
import CoreLocation
import CoreLocationUI


//for keeping track of items i think the best thing is to create an array and then whenever an object is tapped we move the objects name? to the array and then we can output what objects we have gathered when a user wants to maybe

//got help from chatgpt for this asked "i am making an ar app in swift, i currently have a cube that i want to dissapear when tapped on the screen, it has most of it in a class but i am writing the function in the ar view struct just to see if it will work, having it in a class is probably cleaner but getting it working it top priority, some bits a pieces are modified

//spent seven or so hours trying to get this to work had to fall back to chatgpt and claude but i think it is working now

//Current Bugs
//ONLY ABLE TO ACESS THIS SCREEN FULL WHEN WE SET IT AS CONTENT VIEW IN APP DELEGATE, UNSURE WHY BUT WILL WORK ON IT WHEN ABLE TO, it fixed itself somehow not sure, want to keep an eye on this



//CURRENTLY WE HAVE TWO COORDINATORS, ONE FOR THE CUBE AND ONE FOR THE ORB
//the orb coordinator is coordinator orb (real good naming convention) if this does not work will want to maybe ask ai on how to have multiple objects with a same coordinator that actually works



// Custom UIViewRepresentable for RealityKit to add gesture recognizer
struct RealityViewWithTap: UIViewRepresentable {
    
    
    
    
    @Binding var cubeEntity: Entity? // To track the cube entity
    @Binding var orbEntity: Entity? //var to keep track of the orb entity
    @Binding var coneEntity: Entity? //var to keep track of the cone entity
    @Binding var score: Int? //var for keeping track of the score
    @Binding var inventory : Array<Any>? //var for keep track of items that have been picked up
    
    //these are just the fixed locatoin for one of the cubes, the one in the front row of the class room
    var fixedLocationOneLat = 47.75391819
    var fixedLocatoinOneLong = -117.41612819
    var fixedLocationOneAlt = 588.2369567041552
    
    //fixed locations for testing at home
    var fixedLocationHomeLat = 47.63730776
    var fixedLocationHomeLong = -117.42897956
    var fixedLocationhomeAlt = 661.4756752904505
    
    var cubelocationhorizontalOne : Double = 0
    var cubeLocationVertical : Double = 0
    var cubelocationhorizontalTwo : Double = 0
    
    
    
    
    /* Coord List
     
     home:
     Home table coords
     +47.63730776,-117.42897956 ALT:661.4756752904505


     upstairs room coords
     +47.63721840,-117.42898652, ALT:662.7344210334122


     backyard coords
     +47.63728471,-117.42908024, ALT:665.6621078665383
     
     
     school:
     coords for first row in class room:47.75391312,-117.41612673   ALT: 588.2369567041552
     
     
     random guesses for coordinates in this room:
     47.75401420,-117.41622780    ALT: 588.2369567041552
     
     
     
     */
    
    //turns out if distances are to far we get a nil value and your phone explodes
    
    var homeCoords = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75391312 , longitude: -117.41612673), altitude: 588.2369567041552, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
    
    var orbCoords = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75401420, longitude: -117.41622780), altitude: 588.2369567041552, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
    /*
    //this function is for getting the difference between the users locatoin and the fixed location of the cube
    func getCoordinateDifferences(lat : Double, long : Double, alt : Double){
        print("in coordinate difference")
        var curlat : Double = mainlat //hopefully will carry the coordinate from the first screen to this one
        print(curlat) //just for debugging
        var curlong: Double = mainLong
        var curAlt : Double = mainAlt
        print(curlong)
        print(curAlt)
        
        //now we want to get the differences from each of the values
        var latDif : Double = lat - curlat
        var longDif : Double = long-curlong
        var altDif : Double = alt-curAlt
        print(latDif)
        print(longDif)
        print(altDif)
        
        //now with these differences want to convert it into meters so that we know where to place the cube now
        var latDifMeter = latDif * 111111 //should hopefullt convert to meters
        var longDifMeter = 111111 * longDif
        //dont think i need to convert the altitude stuff just yet
        print("differences in meters")
        print(latDifMeter)
        print(longDifMeter)
        
        //now want to put these coordinates into vars that i can then pass back into the cube creator
    }
   */
    
    //asked ai for help on a better way of getting coordinates for latitude and longitude
    func gpsToARPosition(userLocation: CLLocation, poiLocation: CLLocation) -> SIMD3<Float>? {
                // Calculate distance between user and POI
                let distance = Float(userLocation.distance(from: poiLocation))
                
                // If POI is too far away, don't show it
                if distance > 100 { // Maximum 100 meters
                    return nil
                }
                
                // Calculate bearing between user and POI
                let bearing = getBearingBetween(userLocation, poiLocation)
                
                // Calculate X and Z coordinates (horizontal plane)
                // X is east-west, Z is north-south in AR coordinate system
                let x = distance * sin(bearing)
                let z = -distance * cos(bearing) // Negative because AR's Z axis points south
                
                // Calculate Y (vertical) based on altitude difference
                let altitudeDifference = Float(poiLocation.altitude - userLocation.altitude)
                print(poiLocation.altitude)
                print(userLocation.altitude)
                print("Alt Dif")
                print(altitudeDifference)
                
                // Return 3D position vector
                return SIMD3<Float>(x, altitudeDifference, z)
            }
    //now something that deals with the angles, thankfully the ai actually knows how to do this math
    func getBearingBetween(_ startLocation: CLLocation, _ endLocation: CLLocation) -> Float {
                // Convert lat/long to radians
                let lat1 = Float(startLocation.coordinate.latitude * .pi / 180)
                let lon1 = Float(startLocation.coordinate.longitude * .pi / 180)
                let lat2 = Float(endLocation.coordinate.latitude * .pi / 180)
                let lon2 = Float(endLocation.coordinate.longitude * .pi / 180)
                
                // Calculate bearing
                let dLon = lon2 - lon1
                let y = sin(dLon) * cos(lat2)
                let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
                var bearing = atan2(y, x)
                
                // Convert to positive angle if needed
                if bearing < 0 {
                    bearing += 2 * .pi
                }
                
                return bearing
            }
    
    
        class Coordinator: NSObject { //create a coordinator that handles the cube and its functions
            
            var parent: RealityViewWithTap
            var currentCubeEntity: Entity?
            var currentOrbEntity: Entity?
            var currentConeEntity: Entity?
            var score: Int?
            var inventory: Array<Any>?
            
            init(parent: RealityViewWithTap) { //initalize functoin
                self.parent = parent
                self.currentCubeEntity = nil
                self.currentOrbEntity = nil
                self.currentConeEntity = nil
                self.score = 0
                self.inventory = []
            }
            
            
            //the actual cube tap function
            @objc func handleTap(_ sender: UITapGestureRecognizer) {
                guard let content = sender.view as? ARView else { return }
                print("in cube tapping function")
                
                
                //get the location of the tap
                let tapLoc = sender.location(in: content)
                
                print("TapLoc: \(tapLoc)") //debugging
                
                let tapResult = content.hitTest(tapLoc) //does a hit test to determine the coordinates of the tap
                
                //just a check to see if anything was captured in the tap
                if tapResult.isEmpty{
                    print("nothing tapped")
                    return
                }
                
                
                //guards for checking to see if the objects exist to be compared to
                
                guard let cubeEntity = self.currentCubeEntity else{ //checks to see if there is even a cube to tap
                    print("nothing to combare(Cube)")
                    return
                }
                
                guard let orbEntity = self.currentOrbEntity else{
                    print("nothing to compare(orb)")
                    return
                }
                
                
                
                
                //now a loop that goes through to determine if the cube was tapped
                for hit in tapResult{
                    print("thing hit: \(hit.entity.name)") //used for debugging
                    //check to see if we directly hit the cube
                    /* */
                    if hit.entity == cubeEntity{
                        parent.increaseScore() //calls the increase score functoin
                        parent.addItemToInventory(itemName: hit.entity.name) //should hopefully add the name of the item to the array
                        print("cube hit") //debugging
                        hit.entity.removeFromParent() //when hit remove the cube
                        self.currentCubeEntity = nil
                        //parent.cubeEntity = nil
                        
                        return
                    }
                    if hit.entity == orbEntity{ //an if statement to determine what object has been hit
                        parent.increaseScore()
                        parent.addItemToInventory(itemName: hit.entity.name)
                        print("orb hit")
                        hit.entity.removeFromParent()
                        self.currentOrbEntity = nil
                    }
                    
                    
                    
                }
                
                //final debug
                print("cube was not hit")
                
                
                
                
                
                
            }
        }
        
        func makeCoordinator() -> Coordinator { //function that makes the actual coordinatior, this is currently the main coordinator and is connected to the cube
            print("cube coordinator maker")
            return Coordinator(parent: self)
        }
    
    
        //function that makes the ar view so that we can use tap recognizers in ar
        func makeUIView(context: Context) -> ARView {
            let arView = ARView(frame: .zero) //create arvies
            
            // Set up the AR session and configure it how we want
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal //detects ONLY horizontal planes at the moment
            arView.session.run(configuration) //runs the actual ar view
            arView.environment.lighting.intensityExponent = 1.0
            
            arView.debugOptions = [.showFeaturePoints, .showWorldOrigin] //used for debugging the ar screen
            
            // Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:))) //this is the main gesture handler for the app, it is currently only linked to the cube
            //let tapGesterOrb = UITapGestureRecognizer(target: context.coordinator, action: #selector(CoordinatorOrb.handleTap(_:))) //gesture that is only linked to the orb
            tapGesture.cancelsTouchesInView = false
            //tapGesterOrb.cancelsTouchesInView = false
            tapGesture.delegate = context.coordinator //creates a delegator
            //tapGesterOrb.delegate = context.coordinator
            arView.addGestureRecognizer(tapGesture) //adds the tap gesture function to the gesture that are recognized in the ar view
            //arView.addGestureRecognizer(tapGesterOrb)
            arView.session.delegate = context.coordinator
            
            let coordinator = context.coordinator
            
            //add a wait so cube does not appear before plane had a little bit of issues where the cube would appear first and not be on the right plane
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                
                let modelCube = self.createCube(in: arView) //creates the cube in the view
                let modelOrb = self.createOrb(in: arView) //creates the orb in the view
                //let modelCone = self.createCone(in: arView) //creates the cone in the view
                coordinator.currentCubeEntity = modelCube //connect cube to the coordinator
                coordinator.currentOrbEntity = modelOrb //connect the orb to the coordinator
                //coordinator.currentConeEntity = modelCone //connect the cone to the coordinator
                self.cubeEntity = modelCube
                self.orbEntity = modelOrb
                //self.coneEntity = modelCone
                
                
                
                
            }
            
            
            
            return arView
        }
        
        //updates the view
        func updateUIView(_ uiView: ARView, context: Context) {
            context.coordinator.currentCubeEntity = cubeEntity
            context.coordinator.currentOrbEntity = orbEntity
            //context.coordinator.currentConeEntity = coneEntity
        }
        
        
        
        //CREATING OBJECTS FUNCTION LISTS
        
        //create orb
        
        func createOrb(in arView: ARView) -> Entity{
            print("In orb maker")
            
            // Create a orb model
            
            //ok so via debugging for some reason the generate orb thing is not working but the generate cube is working
            let model = ModelEntity(mesh: MeshResource.generateBox(size: 0.2, cornerRadius: 0.005)) //makes a sphere with a radius of 1.5
            let material = SimpleMaterial(color: .blue, roughness: 0.15, isMetallic: true) //makes it blue and metallic
            model.model?.materials = [material]
            
            
            model.generateCollisionShapes(recursive: true) //need this so that the orb acutally gets hit by taps
            
            // Create horizontal plane anchor
            let anchor = AnchorEntity(plane: .horizontal)
            
            let orbPos = gpsToARPosition(userLocation: mainLoc!, poiLocation: orbCoords)
            model.position = orbPos! //sets the model .1 meter in the sky and .5 to the right
            model.name = "Mr.Orb" //names the orb
            
            anchor.addChild(model) //adds the orb to the anchor
            
            arView.scene.addAnchor(anchor) //adds the anchor to the ar view
            
            
            
            //more debugging
            print("orb added at \(model.position)")
            print("anchorOrb added \(anchor.position)")
            
            
            return model
            
            
            
            
        }
        
        //create cone,
        
        func createCone(in arView: ARView) -> Entity{
            print("In cone maker")
            
            // Create a orb model
            
            //ok so via debugging for some reason the generate orb thing is not working but the generate cube is working
            let model = ModelEntity(mesh: MeshResource.generateBox(size: 0.2, cornerRadius: 0.005)) //makes a cone
            let material = SimpleMaterial(color: .brown, roughness: 0.15, isMetallic: true) //makes it brown and metallic
            model.model?.materials = [material]
            
            
            model.generateCollisionShapes(recursive: true) //need this so that the cone acutally gets hit by taps
            
            // Create horizontal plane anchor
            let anchor = AnchorEntity(plane: .horizontal)
            
            model.position = [0.5, 0.1, 0] //sets the model .5 meter in the sky and .5 to the right
            model.name = "Mr.Cone" //names the orb
            
            anchor.addChild(model) //adds the cone to the anchor
            
            arView.scene.addAnchor(anchor) //adds the anchor to the ar view
            
            
            
            //more debugging
            print("cone added at \(model.position)")
            print("anchorCone added \(anchor.position)")
            
            
            return model
            
            
            
            
        }
        
        //create cylinder
        
        //create text object? not sure if needed but interesting
        
        
        
        
        
        //create cube
        //i think the best way for making multiple objects is maybe making different functions for each object for now until i figure out how to automate all of this
    func createCube(in arView: ARView) -> Entity {
            print("In cube maker")
            //getCoordinateDifferences(lat: fixedLocationHomeLat, long: fixedLocationHomeLong, alt: fixedLocationhomeAlt) //want to get coordinate differences
            
            // Create a cube model
            let model = ModelEntity(mesh: MeshResource.generateBox(size: 0.9, cornerRadius: 0.005)) //makes a box with a size of .2 meters
            let material = SimpleMaterial(color: .red, roughness: 0.15, isMetallic: true) //makes it red and metallic
            model.model?.materials = [material]
            
            
            model.generateCollisionShapes(recursive: true) //need this so that the cube acutally gets hit by taps
            
            // Create horizontal plane anchor
            let anchor = AnchorEntity(plane: .horizontal)
            
            let arPOS = gpsToARPosition(userLocation: mainLoc!, poiLocation: homeCoords)
            print(arPOS)
        
            model.position = arPOS! //sets the model .1 meter in the sky
            model.name = "Mr.Cube" //names the cube
            
            
            anchor.addChild(model) //adds the cube to the anchor
            
            arView.scene.addAnchor(anchor) //adds the anchor to the ar view
            
            
            
          
            
            //more debugging
            print("Cube added at \(model.position)")
            print("anchor added \(anchor.position)")
          
            
            return model
        }
        
        
        //Functions for score counting and other game stuff
        
        //function to increase score when a object is tapped
        func increaseScore(){
            //so this should be a simple function
            //just a basic add 1 to the score var
            print("increasing score")
            score = score! + 1
            
        }
        
        //function for adding items to the array to keep track of items the user has picked up
        func addItemToInventory(itemName : String){
            print("add item to inventory")
            inventory?.append(itemName) //should hopefully just add the item to the array
            //print(inventory?.first)
            print(inventory)
        }
    }
    
    
    
    //something to help with debugging trying to find the anchor points
    extension RealityViewWithTap.Coordinator: ARSessionDelegate{
        func session(_ session: ARSession, didUpdate frame: ARFrame){
            if frame.anchors.isEmpty{
                print("No anchors yay")
            }else{
                //print("Anchors: \(frame.anchors.count)")
            }
        }
    }
    
    extension RealityViewWithTap.Coordinator: UIGestureRecognizerDelegate{
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimul: UIGestureRecognizer) -> Bool{
            return true
        }
    }
/*
    extension RealityViewWithTap.CoordinatorOrb: UIGestureRecognizerDelegate{
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimul: UIGestureRecognizer) -> Bool{
        return true
        }
    }
*/


//function for transfering gps coordinates to relative coordinates based off chat gpt code at the bottom of the page
/*
func convertgpsToArCoords(orgin: CLLocationCoordinate2D, dest: CLLocation) -> SCNVector3 {
    //dont know exactly how to do this kind of following what the evil ai which i dont like but will see if it works
    let distance = dest.distance(from: orgin)
    let bearing = getBearing(from: origin.coordinate, to: destination.coordinate)
    
}
 */

    struct ArView: View {
        
        @State private var cubeEntity: Entity? = nil // To keep track of the cube entity
        @State private var orbEntity: Entity? = nil
        @State private var coneEntity: Entity? = nil
        @State var score: Int? = 0
        @State var inventory: Array<Any>? = []
        
        var body: some View {
            Text("Test Score Keeper: \(score!)")
            
            RealityViewWithTap(  cubeEntity: $cubeEntity, orbEntity: $orbEntity, coneEntity: $coneEntity, score: $score, inventory: $inventory) //calls the reality view with tap struct
                .onAppear {
                    
                    
                }
                
                .edgesIgnoringSafeArea(.all) //makes it full screen
                //.navigationBarBackButtonHidden() //hides the back arrow on the nav bar
            
        }
    }
    
    


