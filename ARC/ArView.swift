//
//  arview.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//


import SwiftUI
import RealityKit
import ARKit

//got help from chatgpt for this asked "i am making an ar app in swift, i currently have a cube that i want to dissapear when tapped on the screen, it has most of it in a class but i am writing the function in the ar view struct just to see if it will work, having it in a class is probably cleaner but getting it working it top priority, some bits a pieces are modified

//spent seven or so hours trying to get this to work had to fall back to chatgpt and claude but i think it is working now

//Current Bugs
//ONLY ABLE TO ACESS THIS SCREEN FULL WHEN WE SET IT AS CONTENT VIEW IN APP DELEGATE, UNSURE WHY BUT WILL WORK ON IT WHEN ABLE TO


// Custom UIViewRepresentable for RealityKit to add gesture recognizer
struct RealityViewWithTap: UIViewRepresentable {
    
    @Binding var cubeEntity: Entity? // To track the cube entity
    
    class Coordinator: NSObject { //create a coordinator that handles the cube and its functions
        
        var parent: RealityViewWithTap
        var currentCubeEntity: Entity?
        
        init(parent: RealityViewWithTap) { //initalize functoin
            self.parent = parent
            self.currentCubeEntity = nil
        }
        
        
        //the actual cube tap function
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let content = sender.view as? ARView else { return }
            
        
            
            //get the location of the tap
            let tapLoc = sender.location(in: content)
            
            print("TapLoc: \(tapLoc)") //debugging
            
            let tapResult = content.hitTest(tapLoc) //does a hit test to determine the coordinates of the tap
            
            //just a check to see if anything was captured in the tap
            if tapResult.isEmpty{
                print("nothing tapped")
                return
            }
            
            guard let cubeEntity = self.currentCubeEntity else{ //checks to see if there is even a cube to tap
                print("nothing to combare")
                return
            }
            
            //now a loop that goes through to determine if the cube was tapped
            for hit in tapResult{
                print("thing hit: \(hit.entity.name)") //used for debugging
                    //check to see if we directly hit the cube
                if hit.entity == cubeEntity{
                    print("cube hit") //debugging
                    hit.entity.removeFromParent() //when hit remove the cube
                    self.currentCubeEntity = nil
                    parent.cubeEntity = nil
                    return
                }
                
                //secondary check to see if what we tapped was a child or parent of the cube
                
                if hit.entity.parent == cubeEntity.parent{
                    print("hit cube sibling")
                    if let entityparent = hit.entity.parent{
                        for child in entityparent.children{
                            if child == cubeEntity{ //if the cube is a sibling
                                print("found cube")
                                cubeEntity.removeFromParent() //remove cube
                                self.currentCubeEntity = nil
                                parent.cubeEntity = nil
                                return
                            }
                        }
                    }
                    
                }
                
                //check if cube is child
                if hit.entity.children.contains(where: {$0 == cubeEntity}){
                    print("cube is child")
                    cubeEntity.removeFromParent() //remove cube
                    self.currentCubeEntity = nil
                    parent.cubeEntity = nil
                    return
                }
            }
            
            //final debug
            print("cube was not hit")
            
        
                
                
                
            
        }
    }
    
    func makeCoordinator() -> Coordinator { //function that makes the actual coordinatior
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
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = context.coordinator //creates a delegator
        arView.addGestureRecognizer(tapGesture) //adds the tap gesture function to the gesture that are recognized in the ar view
        
        arView.session.delegate = context.coordinator
        
        let coordinator = context.coordinator
        
        //add a wait so cube does not appear before plane had a little bit of issues where the cube would appear first and not be on the right plane
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            let model = self.createCube(in: arView)
            coordinator.currentCubeEntity = model
            self.cubeEntity = model
            
        }
        
      
        
        return arView
    }
    
    //updates the view
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.currentCubeEntity = cubeEntity
    }
    
    //function that actually makes the cube, will need to expand for other objects eventually
    func createCube(in arView: ARView) -> Entity {
        print("In cube maker")
        // Create a cube model
        let model = ModelEntity(mesh: MeshResource.generateBox(size: 0.2, cornerRadius: 0.005)) //makes a box with a size of .2 meters
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

struct ArView: View {
    
    @State private var cubeEntity: Entity? = nil // To keep track of the cube entity
    
    var body: some View {
        
        RealityViewWithTap(cubeEntity: $cubeEntity) //calls the reality view with tap struct
            .onAppear {
               
            }
            .edgesIgnoringSafeArea(.all) //makes it full screen
            .navigationBarBackButtonHidden() //hides the back arrow on the nav bar
            
    }
    
    /* moving this to the ui view representable
    func createCube() {
        print("In cube maker")
        // Create a cube model
        let model = Entity()
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        model.components.set(ModelComponent(mesh: mesh, materials: [material]))
        model.position = [0, 0.05, 0]
        
        // Store the model in the state variable to track it
        self.cubeEntity = model
        
        // Create horizontal plane anchor
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.addChild(model)
        
        // Find the ARView and add the anchor
        if let arVIEW = getarVIEW(){
            arVIEW.scene.addAnchor(anchor)
        } else {
            print("Ar view is still not being found yipeee")
        }
    }
     */
    
    
    /* as usual the ai lied
    //apparently we need a helper function to get the view where we are placing the cube, you could do this easier before ios 15 but that functionality got deprecated so chagpt said this is how you do it now
    func getarVIEW() -> ARView?{
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene{
            return scene.windows.first?.rootViewController?.view as? ARView
        }
        return nil
    }
     */
}



/* old colde from the first attempt
 
 struct ArView : View{
 
 
 @State var cube: ModelEntity? //vars that are for the cube and the anchor for the cube
 @State var anchor: AnchorEntity? //the @State lets me pass these vars into arViewPsuedo, will want to research why at some point
 
 @State var ArVarView: ARView //creates a ar view variable
 
 var body: some View{
 ArViewPsuedo(ArView: $ArVarView, cube: $cube, anchor: $anchor) //this is used to intergrate the actual ar view into the ui view because apparently in order to interact with objects both the ar view and ui view need to be integrated
 .edgesIgnoringSafeArea(.all)
 .onAppear{ //when the body appears we want to create the actual ar view, wonder why it is different compared to how the xcode template made it
 createARView()
 }
 }
 
 //now the function for creating the ar view itself xcode just calls a reality view obeject while this way looks like it creates a "session" and runs it based off the configuration variable which is set to ar world configuration
 func createARView(){
 //create a configuration var which is declared as a ar configuration
 let config = ARWorldTrackingConfiguration()
 //now we create a session based off the config
 ArVarView.session.run(config)
 
 
 //now a helper function to add a cube to the screen, can probably modify this for when we want to add different objects and such
 
 addCube()
 }
 
 func addCube(){
 //from the xcode template
 let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
 let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
 
 cube = ModelEntity(mesh: mesh, materials: [material]) //creates the cube itself
 
 anchor = AnchorEntity(world: SIMD3(x: 0, y:0, z: -0.5)) //creates the anchor, could modify it for later for more random anchoring
 
 anchor?.addChild(cube!) //connects the cube to the anchor
 
 ArVarView.scene.addAnchor(anchor!) //adds the anchor to the actual view now
 
 }
 
 }
 
 
 //now the constructer for the pseudo ar view, the ai calls its an representable(not entirely sure what that means yet)
 //i wonder if there is a way to not have to integrate, i think the problem is that we are using structs and not classes
 //could probably redo if time
 struct ArViewPsuedo : UIViewRepresentable{
 @Binding var ArView: ARView
 @Binding var cube: ModelEntity?
 @Binding var anchor :AnchorEntity?
 //very interesting thing i found out is if you create an empty struct it will give an error saying that it does not conform to whatever protocol you are using, you can then ask it to fix it and it spits out these template functions and now it works,
 //for some reason it did not like the functions i made below these maybe because of the function name? good to know for the future
 
 func makeUIView(context: Context) -> ARView {
 let ArView = ARView(frame: .zero) //creates the view
 
 let config = ARWorldTrackingConfiguration()
 ArView.session.run(config)
 
 
 //now we create a gesture recognizer for the tap which is the whole point of these weird struct integrations
 let tapScreen = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapHandler(_:)))
 ArView.addGestureRecognizer(tapScreen)
 
 
 
 //now the view should update itself
 self.ArView = ArView
 return ArView
 }
 
 
 
 func updateUIView(_ uiView: ARView, context: Context) {
 
 }
 
 typealias UIViewType = ARView //not sure exactly what this does but the error told me it need it to conform to the UI View protocol
 
 func makeCoordinator() -> Coordinator {
 return Coordinator(cube: $cube, anchor: $anchor, ArView: ArView)
 }
 
 
 
 
 //now a function for making the actual view
 /*
  func makeView(context: Context) -> ARView{
  let ArView = ARView(frame: .zero) //creates the view
  
  let config = ARWorldTrackingConfiguration()
  ArView.session.run(config)
  
  
  //now we create a gesture recognizer for the tap which is the whole point of these weird struct integrations
  let tapScreen = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapHandler(_:)))
  ArView.addGestureRecognizer(tapScreen)
  
  
  
  //now the view should update itself
  self.ArView = ArView
  return ArView
  }
  
  
  //apparently you need a update view function to conform to uiViewRepresntable, but we are not using it just yet so keep it empty?
  
  func updateView(_ uiView: ARView, context : Context){
  
  }
  */
 
 
 //now apparently we make something called a coordinator which is what actually handles the tap recognization
 class Coordinator: NSObject{
 var cube: Binding<ModelEntity?>
 var anchor: Binding<AnchorEntity?>
 var ArView: ARView
 
 
 init(cube: Binding<ModelEntity?>, anchor: Binding<AnchorEntity?>, ArView: ARView!) {
 self.cube = cube
 self.anchor = anchor
 self.ArView = ArView
 }
 
 
 //the handler for the actual tap
 @objc func tapHandler(_ gesture: UIGestureRecognizer){
 //figure out where the screen was tapped
 let loc = gesture.location(in: ArView)
 
 
 //now we use a hit test function which already exists, pretty cool
 let test = ArView.hitTest(loc, query: .nearest, mask: .all)
 //if check to see if the tap was on the cube
 let tapLoc = test.first?.entity
 if tapLoc == cube.wrappedValue{ //if we tap on the cube
 cube.wrappedValue?.removeFromParent() //we remove it from the parent
 }
 
 }
 }
 
 
 
 
 
 }
 
 
 
 
 
 
 /* from the template that was made by xcode, does not work as wanted
  struct Arview : UIViewRepresentable{
  let tapScreen = UITapGestureRecognizer(target: self, action: #selector(cubeTap(_:)))
  
  
  
  var body: some View {
  // this whole commented chunk is a template for the ar aspect, just keeping it around until we figure out how to switch screen modes
  
  
  
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
  
  
  }
  .edgesIgnoringSafeArea(.all)
  .navigationBarBackButtonHidden(true)
  
  }
  
  }
  */
 */
