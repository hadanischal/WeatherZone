//
//  WeatherDetailViewModelTests.swift
//  WeatherRxSwiftTests
//
//  Created by Nischal Hada on 17/8/19.
//  Copyright © 2019 NischalHada. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxTest
import RxSwift
import Cuckoo

@testable import WeatherRxSwift

class WeatherDetailViewModelTests: QuickSpec {

    override func spec() {
        var testViewModel: WeatherDetailViewModel!
        var mockDetailListHandler: MockDetailListHandlerProtocol!
        var testScheduler: TestScheduler!
        let mockDetailList = MockData().stubDetailModelList()
        let mockWeatherResult = MockData().stubWeatherResult()

        describe("WeatherDetailViewModel") {
            beforeEach {
                testScheduler = TestScheduler(initialClock: 0)
                mockDetailListHandler = MockDetailListHandlerProtocol()
                stub(mockDetailListHandler, block: { stub in
                    when(stub.getDetailInfo()).thenReturn(Observable.just(mockDetailList))
                })
                testViewModel = WeatherDetailViewModel(withDetailListHandler: mockDetailListHandler,
                                                       withWeatherResultModel: mockWeatherResult,
                                                       withSchedulerType: MainScheduler.instance)
            }
            describe("Get detail information List from json file", {

                context("when get request succeed ", {
                    beforeEach {
                        stub(mockDetailListHandler, block: { stub in
                            when(stub.getDetailInfo()).thenReturn(Observable.just(mockDetailList))
                        })
                    }
                    it("calls to the CityListHandler to get city info", closure: {
                        verify(mockDetailListHandler).getDetailInfo()
                    })

                    it("emits weather changed for detail to the UI", closure: {
                        testScheduler.scheduleAt(300, action: {
                            testViewModel.getDetailResult()
                        })
                        let testObservable = testViewModel.detailList
                        let res = testScheduler.start { testObservable }
                        expect(res.events.count).to(equal(1))

                        let expectedValue = mockDetailList[0]
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement.count).to(equal(8))

                            if !firsElement.isEmpty {
                                // Success
                                expect(firsElement[0].title).to(equal(expectedValue.title))
                                expect(firsElement[0].description).to(equal("6:32 AM"))
                            } else {
                                fail("Expected city, got \(firsElement.count) counts)")
                            }
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }

                    })
                })

                context("when get detail information List fails ", {
                    beforeEach {
                        stub(mockDetailListHandler, block: { stub in
                            when(stub.getDetailInfo()).thenReturn(Observable.error(RxError.noElements))
                        })
                    }
                    it("calls to the CityListHandler to get city info", closure: {
                        verify(mockDetailListHandler).getDetailInfo()
                    })

                    it("emits weather changed for detail to the UI", closure: {
                        testScheduler.scheduleAt(300, action: {
                            testViewModel.getDetailResult()
                        })
                        let testObservable = testViewModel.detailList
                        let res = testScheduler.start { testObservable }
                        expect(res.events.count).to(equal(0))
                    })
                })

            })

        }

    }
}
