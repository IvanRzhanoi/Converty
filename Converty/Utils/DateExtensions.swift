//
//  DateExtensions.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import Foundation


extension Date {
    // To compare dates (used to find out if the quotes have been updated more than 30 minutes ago)
    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }
}
