//
//  ListView.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import SwiftUI


struct ListView: View {
    
    @EnvironmentObject var convertyVM: ConvertyViewModel
    @Binding var showModal: Bool
    
    var body: some View {
        List(convertyVM.currencies, id: \.id) { currency in
            Button(action: {
                convertyVM.selectedCurrency = currency
                convertyVM.fetchQuotes()
                showModal.toggle()
            }) {
                Text("\(currency.source ?? "") | \(currency.name ?? "")")
            }
        }
        .onAppear {
            // In case fetching the currencies earlier has failed, we try again
            if convertyVM.currencies.isEmpty {
                convertyVM.fetchCurrencyList()
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(showModal: .constant(true))
    }
}
