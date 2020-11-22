//
//  ContentView.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import SwiftUI


struct ContentView: View {
    
    @ObservedObject var convertyVM = ConvertyViewModel()
    
    init() {
        print("ContentView inited")
    }
    
    var body: some View {
        ScrollView {
            VStack {
                TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                Button(action: {
                    print("")
                }) {
                    Text("currency")
                }
                Text("Hello, world!")
                    .padding()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
