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
