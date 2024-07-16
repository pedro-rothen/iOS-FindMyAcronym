//
//  AcronymRepositoryImplTests.swift
//  FindMyAcronymTests
//
//  Created by Pedro on 16-07-24.
//

import XCTest
import Combine
@testable import FindMyAcronym

final class AcronymRepositoryImplTests: XCTestCase {
    var acronymRepository: AcronymRepositoryImpl!
    var mockAcronymRemoteDataSource: MockAcronymRemoteDataSource!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAcronymRemoteDataSource = MockAcronymRemoteDataSource()
        acronymRepository = AcronymRepositoryImpl(acronymDataSource: mockAcronymRemoteDataSource)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        acronymRepository = nil
        mockAcronymRemoteDataSource = nil
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        try super.tearDownWithError()
    }

    func testSuccess() throws {
        //Arrange
        let response = [AcronymStub.dictResponse]
        let expectedLongForm = LongFormMapper.map(response.first!.lfs.first!)
        let query = AcronymStub.acronym
        mockAcronymRemoteDataSource.stub = Just(response).setFailureType(to: Error.self).eraseToAnyPublisher()
        
        //Act
        var receivedLongForm: [LongForm]?
        var receivedError: Error?
        let expectation = expectation(description: "Get long form")
        acronymRepository
            .getFullforms(forAcronym: query)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    receivedError = failure
                    expectation.fulfill()
                }
            }) { value in
                receivedLongForm =  value
                expectation.fulfill()
            }.store(in: &cancellables)
        waitForExpectations(timeout: 1)
        
        //Assert
        XCTAssertNotNil(receivedLongForm)
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedLongForm?.first?.representativeForm, expectedLongForm.representativeForm)
    }
    
    class MockAcronymRemoteDataSource: AcronymRemoteDataSource {
        var stub: AnyPublisher<[DictionaryResponse], Error>!
        
        func getFullforms(forAcronym query: String) -> AnyPublisher<[DictionaryResponse], Error> {
            return stub
        }
    }
}
