//
//  ContentView.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import SwiftUI
import Combine


struct ContentView: View {
    
    @StateObject var convertyVM = ConvertyViewModel()
    @State private var showModal = false
    
    init() {
        print("ContentView inited")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                Text("NOTE: Free subscription does NOT support source switching. The default currency will always be USD")
                    .font(.title2)
                TextField("Amount", text: $convertyVM.amount)
                    .keyboardType(.numberPad)
                    .onReceive(Just(convertyVM.amount)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.convertyVM.amount = filtered
                        }
                    }
                Button(action: {
                    showModal.toggle()
                }) {
//                    Text("\(convertyVM.selectedCurrency?.name != nil ? "Selected currency: \(convertyVM.selectedCurrency?.name ?? "not found :(")": "Tap to select the currency")")
                    Text("\(convertyVM.selectedCurrency?.name != nil ? "Selected currency: United States Dollar": "Tap to select the currency")")
                }
                Text("Hello, world!")
                    .padding()
                
                let threeColumns = [GridItem(alignment: .top), GridItem(alignment: .top), GridItem(alignment: .top)]
                
                LazyVGrid(columns: threeColumns) {
                    ForEach(convertyVM.selectedCurrency?.quotes?.sorted(by: <) ?? [], id: \.key) { key, value in
                        VStack {
//                            Text(key.suffix(3))
                            Text(convertyVM.currencies[convertyVM.currencies.firstIndex(where: { $0.source ?? "" == key.suffix(3) }) ?? 0].name ?? "") // <-- I realise this is an abomination
                            Spacer()
                            Text("\(String(format: "%.2f", value * (Double(convertyVM.amount) ?? 0.0)))") // <-- This one could be better too
                        }
                        .padding(.vertical)
                    }
                }
            }
            .padding()
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .sheet(isPresented: $showModal, content: {
            ListView(showModal: $showModal)
                .environmentObject(convertyVM)
        })
        .alert(isPresented: $convertyVM.showAlert, content: {
            Alert(title: Text("Error"), message: Text("Could not load the currency"), dismissButton: .default(Text("OK")))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
