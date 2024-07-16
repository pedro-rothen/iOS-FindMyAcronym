//
//  ApiServiceImplTests.swift
//  FindMyAcronymTests
//
//  Created by Pedro on 16-07-24.
//

import XCTest
import Combine
@testable import FindMyAcronym

final class ApiServiceImplTests: XCTestCase {
    var apiService: ApiServiceImpl!
    var mockSession: MockUrlSession!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        mockSession = MockUrlSession()
        apiService = ApiServiceImpl(session: mockSession)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        mockSession = nil
        apiService = nil
        cancellables.forEach { $0.cancel() }
        cancellables = nil
    }

    func testDataSuccess() throws {
        //Arrange
        let url = URL(string: "https://domain.com")!
        let expectedData = Data([0, 1, 2])
        let expectedResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let stubSession = Just((data: expectedData, response: expectedResponse)).setFailureType(to: URLError.self).eraseToAnyPublisher()
        mockSession.stubSession = stubSession
        
        //Act
        var receivedData: Data?
        var receivedError: URLError?
        let expectation = expectation(description: "Get data")
        apiService
            .fetchData(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    receivedError = failure
                }
            }) { data in
                receivedData = data
                expectation.fulfill()
            }.store(in: &cancellables)
        waitForExpectations(timeout: 1)
        
        //Assert
        XCTAssertNotNil(receivedData)
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedData, expectedData)
    }
    
    class MockUrlSession: URLSessionProtocol {
        var stubSession: AnyPublisher<(data: Data, response: URLResponse), URLError>!
        
        func dataTaskPublisher(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            return stubSession
        }
    }
}
