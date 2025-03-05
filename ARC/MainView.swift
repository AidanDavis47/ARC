//
//  ContentView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/4/25.
//

import SwiftUI
import RealityKit

struct MainView : View {

    var body: some View {
        NavigationView {
            NavigationLink(destination: SecondView()) {
                Text("Second Screen")
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
        VStack {
            Image(systemName: "moon")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("App testing time yay")
            HStack{
                VStack {
                    Text("learning stacks")
                    Label("Now learning how to lable objects", systemImage: "none")
                }
                VStack {
                    Text("very interesting thing, i guess H stacks are horizontal while V stacks are vertical, makes sense")
                }
            }
        }
        .padding()
    }

}

#Preview {
    MainView()
}
