//
//  GetLongFormsImplTests.swift
//  FindMyAcronymTests
//
//  Created by Pedro on 16-07-24.
//

import XCTest
import Combine
@testable import FindMyAcronym

final class GetLongFormsImplTests: XCTestCase {
    var mockAcronymRepository: MockAcronymRepository!
    var getLongFormsUseCase: GetLongFormsUseCaseImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAcronymRepository = MockAcronymRepository()
        getLongFormsUseCase = GetLongFormsUseCaseImpl(acronymRepository: mockAcronymRepository)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        mockAcronymRepository = nil
        getLongFormsUseCase = nil
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        try super.tearDownWithError()
    }

    func testSuccess() throws {
        //Arrange
        let query = AcronymStub.acronym
        let longForm = LongFormSub.longForm
        let expectedLongFormArray = [longForm]
        mockAcronymRepository.stub = Just(expectedLongFormArray).setFailureType(to: Error.self).eraseToAnyPublisher()
        
        //Act
        var receivedLongFormArray: [LongForm]?
        var receivedError: Error?
        let expectation = expectation(description: "Get long from array from query")
        getLongFormsUseCase
            .execute(for: query)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    receivedError = failure
                    expectation.fulfill()
                }
            }) { value in
                receivedLongFormArray = value
                expectation.fulfill()
            }.store(in: &cancellables)
        waitForExpectations(timeout: 1)
        
        //Assert
        XCTAssertNotNil(receivedLongFormArray)
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedLongFormArray, expectedLongFormArray)
    }
    
    func testFailsWhenEmpty() throws {
        //Arrange
        let query = AcronymStub.acronym
        let expectedError: AcronymError = .empty
        mockAcronymRepository.stub = Just([LongForm]()).setFailureType(to: Error.self).eraseToAnyPublisher()
        
        //Act
        var receivedError: AcronymError?
        var receivedLongFormArray: [LongForm]?
        let expectation = expectation(description: "Fails when get a [] response, handle it into a custom error")
        getLongFormsUseCase
            .execute(for: query)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    receivedError = failure as? AcronymError
                    expectation.fulfill()
                }
            }) { value in
                receivedLongFormArray = value
                expectation.fulfill()
            }.store(in: &cancellables)
        waitForExpectations(timeout: 1)
        
        //Assert
        XCTAssertNotNil(receivedError)
        XCTAssertNil(receivedLongFormArray)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    class MockAcronymRepository: AcronymRepository {
        var stub: AnyPublisher<[LongForm], Error>!
        
        func getFullforms(forAcronym query: String) -> AnyPublisher<[LongForm], Error> {
            return stub
        }
    }
}

struct LongFormSub {
    static let longForm = LongForm(representativeForm: "deoxyribonucleic acid", occurrences: 100, since: 1979)
}
