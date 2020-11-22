//
//  ApplicationExtension.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import SwiftUI


// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
