//
//  ApiService.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

protocol ApiService {
    func fetchData(from url: URL) -> AnyPublisher<Data, URLError>
}

protocol URLSessionProtocol {
    func dataTaskPublisher(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionProtocol {
    func dataTaskPublisher(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return self
            .dataTaskPublisher(for: url)
            .eraseToAnyPublisher()
    }
}
