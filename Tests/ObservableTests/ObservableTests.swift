import XCTest
@testable import Observable

final class ObservableTests: XCTestCase {

    func testObservableEmitsValueOnChange() {
        var observedValue: String?
        let expectation = self.expectation(description: #function)
        let observable = Observable("Test 1")
        bindObservable(observable) { oldValue, newValue in
            observedValue = newValue
            expectation.fulfill()
        }
        observable.post("Test 2")

        waitForExpectations(timeout: 1)
        XCTAssertEqual("Test 2", observedValue)
    }

    func testObservableEmitsInitialValue() {
        var observedOldValue: String?
        var observedNewValue: String?
        let expectation = self.expectation(description: #function)
        let observable = Observable("Test 1")
        bindObservable(observable, initial: true) { oldValue, newValue in
            observedOldValue = oldValue
            observedNewValue = newValue
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual("Test 1", observedOldValue)
        XCTAssertEqual(observedOldValue, observedNewValue,
                       "oldValue and newValue should be the same for an initial binding")
    }

    func testObservableOnlyEmitsInitialValueWhenRequested() {
        var callbackCalled = false
        let expectation = self.expectation(description: #function)
        expectation.isInverted = true
        let observable = Observable("Test 1")
        bindObservable(observable) { _, _ in
            callbackCalled = true
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertFalse(callbackCalled)
    }
}

extension ObservableTests {
    static var allTests = [
        ("testObservableEmitsValueOnChange", testObservableEmitsValueOnChange),
        ("testObservableEmitsInitialValue", testObservableEmitsInitialValue),
        ("testObservableOnlyEmitsInitialValueWhenRequested", testObservableOnlyEmitsInitialValueWhenRequested)
    ]
}
