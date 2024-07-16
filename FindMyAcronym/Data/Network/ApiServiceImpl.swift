//
//  ApiServiceImpl.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

class ApiServiceImpl: ApiService {
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchData(from url: URL) -> AnyPublisher<Data, URLError> {
        return session
            .dataTaskPublisher(url: url)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
