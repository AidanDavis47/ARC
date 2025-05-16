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


/* CURRENTLY DEALING WITH STUFF BEING NESTED WITHIN EACHOTHER*/
/* ALSO FOR SOME REASON THE CUBES ARE NOT BEING PLACED IN THE LOCATION I WANT WILL NEED TO WORK ON THIS ASWELL*/



//CURRENTLY WE HAVE TWO COORDINATORS, ONE FOR THE CUBE AND ONE FOR THE ORB
//the orb coordinator is coordinator orb (real good naming convention) if this does not work will want to maybe ask ai on how to have multiple objects with a same coordinator that actually works



/* WHEN CHANGING LOCATIONS ALSO HAVE TO CHANGE THE SECONDARY COORDS DUE TO THE WEIRD SPAGHETTI CODE I HAVE WRITTEN, CAN GET COORDINATES BASED OFF CONSOLE OUTPUTS
 IF YOUR LOCATIONS ARE TOO FAR APP WILL CRASH
 
 
 
 */

//GOT CUBE DISTANCE STUFF WORKING, COORDS ARE STILL OFF AND CUBES CAN BE INFINITLY CREATED IF THEY WERE NOT MADE AT START



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
     
     Trophy Coordinates
     47.75401628,-117.41595848, ALT: 584.0630307989195
     
     
     Rock Coordinates
     47.75400978,-117.41619563, ALT: 585.0755367605016
     
     
     
     */
    
    //turns out if distances are to far we get a nil value and your phone explodes
    
    var homeCoords = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75391312 , longitude: -117.41612673), altitude: 588.2369567041552, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
    
     var orbCoords = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75401628, longitude: -117.41595848), altitude: 665.6621078665383, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
    
     var coneCoords = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75400978, longitude: -117.41619563), altitude: 585.0755367605016, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
    
    
    
    

        class Coordinator: NSObject { //create a coordinator that handles the cube and its functions
            
            var parent: RealityViewWithTap
            var currentCubeEntity: Entity?
            var currentOrbEntity: Entity?
            var currentConeEntity: Entity?
            var score: Int?
            var inventory: Array<Any>?
            var cubeCoords2: CLLocation?
            var orbCoords2: CLLocation?
            var coneCoords2: CLLocation?
            var currentARView: ARView?
            
            
            var cubeMade = false
            var orbMade = false
            var coneMade = false
            
            
            init(parent: RealityViewWithTap) { //initalize functoin
                self.parent = parent
                self.currentCubeEntity = nil
                self.currentOrbEntity = nil
                self.currentConeEntity = nil
                self.score = 0
                self.inventory = []
                self.cubeCoords2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75391312 , longitude: -117.41612673), altitude: 588.2369567041552, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
                self.orbCoords2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75401628, longitude: -117.41595848), altitude: 665.6621078665383, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
                self.coneCoords2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 47.75400978, longitude: -117.41619563), altitude: 585.0755367605016, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
            }
            
            
            
            
            
            
            
            
            
            //maybe the way to do this is put this into this function and pretty much when we have deteremind that a cube was not tapped on we do the scan thingy
            
            //got help from claude with this to figure out how to integrate this with the already written code
            //helper function that will be called if the tap hit nothing
            func scanForObjects(in arView: ARView? = nil){
                print("in scan")
                
                //error checking recommende by the AI overlords
                guard let userLoc = mainLoc, let arView = arView ?? currentARView else{
                    print("no user loc or ar view")
                    return
                }
                        //so first want to get the users current location, i think this is constantly running in the background
                        //maybe i can call the gps to ar position thing but maybe not and can just use the basic given lat and longitude
                let distFromCube = Float(((mainLoc?.distance(from: cubeCoords2!))!)) //not sure if this work and give the distance from the cube but it does not hurt
                print(distFromCube) //testing this stuff just a bit
                //looks like this very janky code actually works the errors with getting the user location might cause some issues but im going to run with it for now
                let distFromOrb = Float((((mainLoc?.distance(from: orbCoords2!))!)))
                let distFromCone = Float(((((mainLoc?.distance(from: coneCoords2!))!))))
                //so we should have the distance from all the objects
               // print(distFromOrb) //debugging
                //print(distFromCone) //debugging
                
                //now for the real madness
                //what if i make an if statment and if the user is within the distance limit i then call the create object function
                //this is a very janky way of doing this but we will see if it works
                //will have a different if statement for each object
                if distFromCube < 30 && cubeMade == false{ //if we are in the distance would follow this foundation for the other objects aswell
                    print("in threshold for cube")
                    let cube = parent.createCube(in: arView)
                    self.currentCubeEntity = cube
                    parent.cubeEntity = cube
                    cubeMade = true //make it so that a cube cannot be made again
                    
                }
                
                if distFromOrb < 30 && orbMade == false{
                    let orb = parent.createOrb(in: arView)
                    self.currentOrbEntity = orb
                    parent.orbEntity = orb
                    orbMade = true
                }
                
                if distFromCone < 30 && coneMade == false{
                    let cone = parent.createCone(in: arView)
                    self.currentConeEntity = cone
                    parent.coneEntity = cone
                    coneMade = true
                }
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
                    scanForObjects(in: content)
                    return
                }
                
                
                
                
                
                
                
                //now a loop that goes through to determine if the cube was tapped
                for hit in tapResult{
                    let hitObject = hit.entity
                    print("thing hit: \(hit.entity.name)") //used for debugging
                    //check to see if we directly hit the cube
                    /* */
                    if let currentCubeEntity = self.currentCubeEntity, hitObject == currentCubeEntity{
                        parent.increaseScore() //calls the increase score functoin
                        parent.addItemToInventory(itemName: hit.entity.name) //should hopefully add the name of the item to the array
                        print("cube hit") //debugging
                        hit.entity.removeFromParent() //when hit remove the cube
                        self.currentCubeEntity = nil
                        //parent.cubeEntity = nil
                        
                        return
                    }
                    if let currentOrbEntity = self.currentOrbEntity, hitObject == currentOrbEntity{ //an if statement to determine what object has been hit
                        parent.increaseScore()
                        parent.addItemToInventory(itemName: hit.entity.name)
                        print("orb hit")
                        hit.entity.removeFromParent()
                        self.currentOrbEntity = nil
                    }
                    
                    if let currentConeEntity = self.currentConeEntity, hitObject == currentConeEntity{
                        parent.increaseScore()
                        parent.addItemToInventory(itemName: hit.entity.name)
                        print("cone hit")
                        hit.entity.removeFromParent()
                        self.currentCubeEntity = nil
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
    
        //function that makes the ar view so that we can use tap recognizers in ar
        func makeUIView(context: Context) -> ARView {
            //need to add a location tracker for the user in this scene aswell, tbh i think i could somehow use the one from the main view but that might be to hard to do with so little time
            let tracker = CLLocationManager()
            tracker.delegate = context.coordinator
            tracker.desiredAccuracy = kCLLocationAccuracyBest //want to best accuracy possible for this, may need to tweak this depending on if the accuracy is changing too much
            tracker.requestWhenInUseAuthorization() //get authorization
            tracker.startUpdatingLocation() //start tracking the user
            
            
            
            
            
            
            let arView = ARView(frame: .zero) //create arvies
            context.coordinator.currentARView = arView
            
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
                /*
                
                let modelCube = self.createCube(in: arView) //creates the cube in the view
                let modelOrb = self.createOrb(in: arView) //creates the orb in the view
                let modelCone = self.createCone(in: arView) //creates the cone in the view
                coordinator.currentCubeEntity = modelCube //connect cube to the coordinator
                coordinator.currentOrbEntity = modelOrb //connect the orb to the coordinator
                coordinator.currentConeEntity = modelCone //connect the cone to the coordinator
                self.cubeEntity = modelCube
                self.orbEntity = modelOrb
                self.coneEntity = modelCone
                 */
                if let userLoc = mainLoc{
                    //check distances
                    let cubeDist = Float(userLoc.distance(from: coordinator.cubeCoords2!))
                    let orbDist = Float(userLoc.distance(from: coordinator.orbCoords2!))
                    let coneDist = Float(userLoc.distance(from: coordinator.coneCoords2!))
                    
                    //debugging
                    //print(cubeDist)
                    //print(orbDist)
                    //print(coneDist)
                    
                    
                    //now create any objects that are in the distance threshold
                    if cubeDist < 10{
                        print("Cube in dist creating")
                        let modelCube = self.createCube(in: arView)
                        coordinator.currentCubeEntity = modelCube
                        self.cubeEntity = modelCube
                        
                    }
                    
                    if orbDist < 10{
                        print("Orb in dist creating")
                        let modelOrb = self.createOrb(in: arView)
                        coordinator.currentOrbEntity = modelOrb
                        self.orbEntity = modelOrb
                    }
                    
                    if coneDist < 10{
                        print("Cone in dist creating")
                        let modelCone = self.createCone(in: arView)
                        coordinator.currentConeEntity = modelCone
                        self.coneEntity = modelCone
                    }
                }else{
                    //if we dont have the users location
                    print("User loc unknown")
                }
                
                //auto update for objects did not know this was a thing that could be done, pretty cool
                
                /* not needed currently
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
                    timer in coordinator.scanForObjects()
                }
                */
                
                
                
                
            }
            
            
            
            return arView
        }
        
        //updates the view
        func updateUIView(_ uiView: ARView, context: Context) {
            context.coordinator.currentCubeEntity = cubeEntity
            context.coordinator.currentOrbEntity = orbEntity
            context.coordinator.currentConeEntity = coneEntity
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
            model.position = orbPos! //sets the model position hopefully in the given coordinate location
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
            let model = ModelEntity(mesh: MeshResource.generateBox(size: 0.3, cornerRadius: 0.005)) //makes a cone
            let material = SimpleMaterial(color: .green, roughness: 0.15, isMetallic: true) //makes it brown and metallic
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


    //extension to the coordinator so that it conforms to the location tracking stuff
extension RealityViewWithTap.Coordinator: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLoc locs: [CLLocation]){
        guard let loc = locs.last else {return}
        
        //update location
        mainLoc = loc
        
        //debugging
        print("Cur loc \(loc.coordinate.latitude)")
        
        //now we check to see if the user is in the distance threshold
        DispatchQueue.main.async {
            if let arView = self.currentARView{
                self.scanForObjects(in: arView)
            }
        }
    }
    
    //error function
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location manager error: \(error.localizedDescription)")
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
    
    


