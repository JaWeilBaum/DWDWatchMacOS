//
//  ContentViewViewModel.swift
//  DWDWatch
//
//  Created by Léon Friedmann on 06.07.21.
//

import Foundation
import SwiftUI
import Combine

class ContentViewViewModel: ObservableObject {
    @Published var images = [ImageWrapper]()
    @Published var selectedImage = UUID()
    private var trash = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    private let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyMMddHHmm"
    }
    
    func getDates(numDates: Int = 5) -> [Date] {
        let now = Date()
        let component = Calendar.current.dateComponents([.hour, .minute], from: now)
        guard let minute = component.minute else {
            return []
        }
        
        let diffLastFiveMinutes = -1 * (minute % 5)
        guard let nowMinutesSet = Calendar.current.date(byAdding: DateComponents(minute: diffLastFiveMinutes), to: now),
              let nowClean = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nowMinutesSet)) else {
            return []
        }
        
        return (0..<numDates).map { offset in
            nowClean.addingTimeInterval(-1 * Double(offset) * 60 * 5)
        }
    }
    
    func getImages(numImages: Int = 5) {
        var dates = [Date: [String: String]]()
        
        for date in getDates() {
            dates[date] = ["src": "rad/ri_\(self.dateFormatter.string(from: date)).png"]
        }
        
        
        let requests = dates.compactMapValues { self.networkManager.createRequestWith(components: [PathComponents.getImage.rawValue], params: $0) }
        
        for (date, request) in requests {
            networkManager.getImageWith(request: request)
                .sink(receiveValue: { image in
                    guard let image = ImageWrapper(image: image, date: date) else {
                        return
                    }
                    if self.images.first(where: { $0.date == date }) != nil {
                        return
                    }
                    self.images.append(image)
                })
                .store(in: &trash)
        }
    }
}
