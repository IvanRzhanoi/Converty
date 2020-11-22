//
//  ConvertyViewModel.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import Foundation
import Combine


class ConvertyViewModel: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var currencies: [Currency] = []
    @Published var selectedCurrency: Currency?
    @Published var amount: String = ""
    @Published var showAlert: Bool = false
    
    init() {
        fetchCurrencyList()
    }
    
    func fetchCurrencyList() {
        guard let url = URL(string: "\(Constants.baseURL)/list?access_key=\(Constants.apiKey)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Usage
        let dataFetcher = DataFetcher()

        // For getting and decoding the response
        dataFetcher.fetch(request: request)
            .receive(on: DispatchQueue.main)
            .retry(2)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { (response: Response) in
                print("Curerncy List response is: \(response)")
                guard let currencies = response.currencies else {
                    return
                }
                
//                print("currencies: \(currencies)") // <-- Usually I would use some logging library like SwiftyBeaver, but for now I just use print statements. They are not needed right now however
                for currency in currencies {
//                    print("Currency code: \(currency.key); name: \(currency.value)")
                    let item = Currency(source: currency.key, name: currency.value)
                    self.currencies.append(item)
                }
                
                self.currencies = self.currencies.sorted { $0.source ?? "" < $1.source ?? "" }
            })
            .store(in: &subscriptions)
    }
    
    
    // Fetching quotes for the current currency if it has been updated more than 30 minutes ago
    func fetchQuotes() {
        // Checking if more than 30 minutes have passed. If less, then we do not make a request to update
        // Also, if the timestamp does not exist, we proceed with fetching the quotes
        if selectedCurrency?.timestamp?.distance(from: Date(), only: .minute) ?? 60 < 30 {
            print("Currency rate is still fresh")
            return
        }
        
        // Currency source is not supported by the free API
        guard let source = selectedCurrency?.source else {
            showAlert.toggle()
            return
        }
//        guard let url = URL(string: "\(Constants.baseURL)/live?access_key=\(Constants.apiKey)&source=\(source)") else {
//            return
//        }
        
        guard let url = URL(string: "\(Constants.baseURL)/live?access_key=\(Constants.apiKey)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Usage
        let dataFetcher = DataFetcher()

        // For getting and decoding the response
        dataFetcher.fetch(request: request)
            .receive(on: DispatchQueue.main)
            .retry(2)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.showAlert.toggle()
                    print(error.localizedDescription)
                }
            }, receiveValue: { (response: Response) in
                print("Curerncy Quotes response is: \(response)")
                guard let quotes = response.quotes else {
                    return
                }
                
                print("quotes: \(quotes)")
                self.selectedCurrency?.quotes = quotes
                // Setting the current date and time for currency. Later we can see when it was last updated
                self.selectedCurrency?.timestamp = Date()
                
                // Updating the conversion rates for current
                if let row = self.currencies.firstIndex(where: { $0.source == source }) {
                    if let currency = self.selectedCurrency {
                        self.currencies[row] = currency
                    }
                }
            })
            .store(in: &subscriptions)
    }
}
