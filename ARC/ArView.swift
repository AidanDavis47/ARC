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


struct ArViewStruct : View{
    @State var cube: ModelEntity? //vars that are for the cube and the anchor for the cube
    @State var anchor: AnchorEntity? //the @State lets me pass these vars into arViewPsuedo, will want to research why at some point
    
    @State var ArView: ARView! //creates a arview variable
    
    var body: some View{
        ArViewPsuedo(ArView: $ArView, cubeEntity: $cube, AnchorEntity: $anchor)
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
        ArView.session.run(config)
        
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
        
        ArView.scene.addAnchor(anchor!) //adds the anchor to the actual view now
        
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
