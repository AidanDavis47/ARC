//
//  arview.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//


import SwiftUI
import RealityKit
import ARKit


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

    
    
    //create a coordinator for the orb maybe
    //dont think this is going to work going to comment it out and related code just incase it will be be useful in future
    /*
    class CoordinatorOrb: NSObject{
        var parent: RealityViewWithTap
        var currentOrbEntity: Entity?
        
        
        init(parent: RealityViewWithTap, currentOrbEntity: Entity? = nil) {
            self.parent = parent
            self.currentOrbEntity = nil
        }
        //the actual orb tap function copied from the cube code
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let content = sender.view as? ARView else { return }
            print("in orb tapping function")
            
            
            
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
            
            
            guard let orbEntity = self.currentOrbEntity else{
                print("notthing to compare (orb)")
                return
            }
            
            
            
            
            //now a loop that goes through to determine if the cube was tapped
            for hit in tapResult{
                print("thing hit(orb): \(hit.entity.name)") //used for debugging
                //check to see if we directly hit the cube
                /* */
                if hit.entity == orbEntity{
                    parent.increaseScore() //calls the increase score functoin
                    parent.addItemToInventory(itemName: hit.entity.name) //should hopefully add the name of the item to the array
                    print("orb hit") //debugging
                    hit.entity.removeFromParent() //when hit remove the cube
                    self.currentOrbEntity = nil
                    //parent.cubeEntity = nil
                    
                    return
                }
                
                
                //secondary check to see if what we tapped was a child or parent of the cube not used
                /*
                if hit.entity.parent == orbEntity.parent{
                    print("hit cube sibling")
                    if let entityparent = hit.entity.parent{
                        for child in entityparent.children{
                            if child == orbEntity{ //if the cube is a sibling
                                print("found cube")
                                orbEntity.removeFromParent() //remove cube
                                self.currentOrbEntity = nil //makes sure to remove cube
                                //parent.cubeEntity = nil
                                return
                            }
                        }
                    }
                    
                }
                
                
                /*
                //check if cube is child not needed at the moment
                if hit.entity.children.contains(where: {$0 == orbEntity}){
                    print("cube is child")
                    orbEntity.removeFromParent() //remove cube
                    self.currentOrbEntity = nil
                    //parent.cubeEntity = nil
                    return
                }
                 */ */
                
            }
            
            //final debug
            print("orb was not hit")
            
        }
    }
        
      */
        
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
                
                /*
                 guard let orbEntity = self.currentOrbEntity else{
                 print("notthing to compare (orb)")
                 return
                 }
                 
                 guard let coneEntity = self.currentConeEntity else{
                 print("no compare cone")
                 return
                 }
                 */
                
                
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
                    
                    
                    //secondary check to see if what we tapped was a child or parent of the cube not used
                    /*
                    if hit.entity.parent == cubeEntity.parent{
                        print("hit cube sibling")
                        if let entityparent = hit.entity.parent{
                            for child in entityparent.children{
                                if child == cubeEntity{ //if the cube is a sibling
                                    print("found cube")
                                    cubeEntity.removeFromParent() //remove cube
                                    self.currentCubeEntity = nil //makes sure to remove cube
                                    //parent.cubeEntity = nil
                                    return
                                }
                            }
                        }
                        
                    }
                    
                    
                    
                    //check if cube is child not needed at the moment
                    if hit.entity.children.contains(where: {$0 == cubeEntity}){
                        print("cube is child")
                        cubeEntity.removeFromParent() //remove cube
                        self.currentCubeEntity = nil
                        //parent.cubeEntity = nil
                        return
                    }
                    */
                }
                
                //final debug
                print("cube was not hit")
                
                
                
                
                
                
            }
        }
        
        func makeCoordinator() -> Coordinator { //function that makes the actual coordinatior, this is currently the main coordinator and is connected to the cube
            print("cube coordinator maker")
            return Coordinator(parent: self)
        }
    
    /*
        func makeOrbCoordinator() -> CoordinatorOrb{ //makes the coordinator for the orb coordinator
            print("orn coordinator maker")
            return CoordinatorOrb(parent: self)
        }
        */
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
            
            model.position = [0.0, 0.5, 0] //sets the model .1 meter in the sky and .5 to the right
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
            
            
            // Create a cube model
            let model = ModelEntity(mesh: MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)) //makes a box with a size of .2 meters
            let material = SimpleMaterial(color: .red, roughness: 0.15, isMetallic: true) //makes it red and metallic
            model.model?.materials = [material]
            
            
            model.generateCollisionShapes(recursive: true) //need this so that the cube acutally gets hit by taps
            
            // Create horizontal plane anchor
            let anchor = AnchorEntity(plane: .horizontal)
            
            model.position = [0, 0.1, 0.0] //sets the model .1 meter in the sky
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
    
    
    

