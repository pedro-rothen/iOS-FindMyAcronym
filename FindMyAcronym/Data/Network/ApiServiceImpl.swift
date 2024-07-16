//
//  ApiServiceImpl.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

class ApiServiceImpl: ApiService {
    func fetchData(from url: URL) -> AnyPublisher<Data, URLError> {
        return URLSession
            .shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
