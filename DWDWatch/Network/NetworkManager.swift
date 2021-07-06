//
//  NetworkManager.swift
//  DWDWatch
//
//  Created by Léon Friedmann on 06.07.21.
//

import Foundation
import Combine
import SwiftUI
import os

class NetworkManager {
    static let shared = NetworkManager()
    let secretManager = SecretManager.shared
    let urlSession: URLSession
    let trash = Set<AnyCancellable>()
    private let baseURL = "https://www.flugwetter.de/"
    
    init() {
        urlSession = URLSession.shared
    }
    
    private func extend(url: URL, with components: [String], _ params: [String: String]) -> URL? {
        var extendedUrl: URL? = url
        components.forEach { component in
            extendedUrl = extendedUrl?.appendingPathComponent(component)
        }
        let queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        guard let extendedUrl = extendedUrl,
              var urlComponents = URLComponents(string: extendedUrl.absoluteString) else {
            return nil
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
    
    func createRequestWith(components: [String], params: [String: String] = [:]) -> URLRequest? {
        guard let url = URL(string: baseURL) else {
            return nil
        }
        guard let fullUrl = extend(url: url, with: components, params) else {
            return nil
        }
        var request = URLRequest(url: fullUrl)
        request.addValue("Basic \(secretManager.getAuth())", forHTTPHeaderField: "Authorization")
        os_log(.debug, "\(request.description)")
        return request
    }
    
    
    func getDataWith(request: URLRequest) -> AnyPublisher<Data, Never> {
        urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .replaceError(with: Data())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getImageWith(request: URLRequest) -> AnyPublisher<NSImage?, Never> {
        getDataWith(request: request)
            .map { NSImage(data: $0) }
            .eraseToAnyPublisher()
    }
}
