//
//  SearchAcronymViewModelTests.swift
//  FindMyAcronymTests
//
//  Created by Pedro on 16-07-24.
//

import XCTest
import Combine
@testable import FindMyAcronym

final class SearchAcronymViewModelTests: XCTestCase {
    var searchViewModel: SearchAcronymViewModel!
    var mockGetLongFormsUseCase: MockGetLongFormsUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetLongFormsUseCase = MockGetLongFormsUseCase()
        searchViewModel = SearchAcronymViewModel(getLongFormsUseCase: mockGetLongFormsUseCase)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        mockGetLongFormsUseCase = nil
        searchViewModel = nil
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        try super.tearDownWithError()
    }

    func testShowsSuccessUI() throws {
        //Arrange
        let query = AcronymStub.acronym
        let expectedLongFormArray = [LongFormStub.longForm]
        mockGetLongFormsUseCase.stub = Just(expectedLongFormArray)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        //Act
        var receivedStateIsSuccess = false
        var receivedLongFormArray: [LongForm]?
        let expectation = expectation(description: "Search acronym viewModel's state is success")
        searchViewModel.query = query
        searchViewModel
            .$uiState
            .dropFirst()
            .sink {
                if case .success(let results) = $0 {
                    receivedStateIsSuccess = true
                    receivedLongFormArray = results
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        waitForExpectations(timeout: 1)
        
        //Assert
        print(searchViewModel.uiState)
        XCTAssert(receivedStateIsSuccess)
        XCTAssertEqual(receivedLongFormArray?.first?.representativeForm, expectedLongFormArray.first?.representativeForm)
    }
    
    class MockGetLongFormsUseCase: GetLongFormsUseCase {
        var stub: AnyPublisher<[LongForm], Error>!
        func execute(for query: String) -> AnyPublisher<[LongForm], Error> {
            return stub
        }
    }
}
