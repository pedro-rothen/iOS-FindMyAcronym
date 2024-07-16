//
//  AcronymRemoteDataSourceImpl.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

class AcronymRemoteDataSourceImpl: AcronymRemoteDataSource {
    let service: ApiService
    
    init(service: ApiService) {
        self.service = service
    }
    
    func getFullforms(forAcronym query: String) -> AnyPublisher<[DictionaryResponse], any Error> {
        let stringUrl = "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=\(query)"
        guard let url = URL(string: stringUrl) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return service
            .fetchData(from: url)
            .decode(type: [DictionaryResponse].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
