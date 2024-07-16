//
//  AcronymRemoteDataSourceImplTests.swift
//  FindMyAcronymTests
//
//  Created by Pedro on 16-07-24.
//

import XCTest
import Combine
@testable import FindMyAcronym

final class AcronymRemoteDataSourceImplTests: XCTestCase {
    var mockApiService: MockApiService!
    var acronymRemoteDataSource: AcronymRemoteDataSourceImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockApiService = MockApiService()
        acronymRemoteDataSource = AcronymRemoteDataSourceImpl(service: mockApiService)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        try super.tearDownWithError()
    }

    func testDataSuccess() throws {
        //Arrange
        let acronym = AcronymStub.acronym
        let expectedValue = [AcronymStub.dictResponse]
        let data = try JSONEncoder().encode(expectedValue)
        mockApiService.stubData = Just(data).setFailureType(to: URLError.self).eraseToAnyPublisher()
        
        //Act
        var receivedValue: [DictionaryResponse]?
        var receivedError: URLError?
        let expectation = expectation(description: "Success parsing")
        acronymRemoteDataSource
            .getFullforms(forAcronym: acronym)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    receivedError = failure as? URLError
                    expectation.fulfill()
                }
            }) { value in
                receivedValue = value
                expectation.fulfill()
            }.store(in: &cancellables)
        waitForExpectations(timeout: 1)
        
        //Assert
        XCTAssertNotNil(receivedValue)
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedValue?.first?.lfs.first?.lf, expectedValue.first?.lfs.first?.lf)
    }
    
    class MockApiService: ApiService {
        var stubData: AnyPublisher<Data, URLError>!
        
        func fetchData(from url: URL) -> AnyPublisher<Data, URLError> {
            return stubData
        }
    }
}

struct AcronymStub {
    static let acronym = "wth"
    static let longFormApi = LongFormApi(lf: "what the heck", freq: 100, since: 1979)
    static let dictResponse = DictionaryResponse(lfs: [longFormApi])
}
