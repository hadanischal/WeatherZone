//
//  CitySearchViewModelTests.swift
//  WeatherRxSwiftTests
//
//  Created by Nischal Hada on 5/8/19.
//  Copyright © 2019 NischalHada. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Cuckoo
import RxTest
import RxBlocking
import RxSwift
@testable import WeatherRxSwift

//swiftlint:disable function_body_length
class CitySearchViewModelTests: QuickSpec {

    override func spec() {
        var testViewModel: CitySearchViewModel!
        var mockCityListHandler: MockSearchCityListHandlerProtocol!
        var testScheduler: TestScheduler!

        describe("CitySearchViewModel") {
            beforeEach {
                testScheduler = TestScheduler(initialClock: 0)
                mockCityListHandler = MockSearchCityListHandlerProtocol()
                stub(mockCityListHandler, block: { stub in
                    when(stub.getSearchCityList()).thenReturn(Observable.just([cityList]))
                })
                testViewModel = CitySearchViewModel(withCityList: mockCityListHandler, withSchedulerType: MainScheduler.instance)
            }

            describe("Get city List from json file", {

                context("when getCityInfo withFilename succeed ", {
                    beforeEach {
                        stub(mockCityListHandler, block: { stub in
                            when(stub.getSearchCityList()).thenReturn(Observable.just([cityList]))
                        })
                    }
                    it("calls to the CityListHandler to get city info", closure: {
                        testViewModel.getCityList()
                        verify(mockCityListHandler).getSearchCityList()
                    })

                    it("emits cityList Changed to the UI", closure: {
                        testScheduler.scheduleAt(300, action: {
                            testViewModel.getCityList()
                        })
                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }
                        expect(res.events.count).to(equal(1))
                    })

                    it("emits cityList Changed to the UI", closure: {
                        testScheduler.scheduleAt(300, action: {
                            testViewModel.getCityList()
                        })

                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }

                        let expectedValue = cityList
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement.count).to(equal(1))

                            if !firsElement.isEmpty {
                                // Success
                                expect(firsElement[0].name).to(equal(expectedValue.name))
                                expect(firsElement[0].country).to(equal(expectedValue.country))
                                expect(firsElement[0].id).to(equal(expectedValue.id))
                                expect(firsElement[0].coord?.lat).to(equal(expectedValue.coord?.lat))
                                expect(firsElement[0].coord?.lon).to(equal(expectedValue.coord?.lon))
                            } else {
                                fail("Expected city, got \(firsElement.count) counts)")
                            }
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }

                    })

                })

                context("when get city info request failed ", {
                    beforeEach {
                        stub(mockCityListHandler, block: { stub in
                            when(stub.getSearchCityList()).thenReturn(Observable.error(RxError.noElements))
                        })
                    }
                    it("calls to the CityListHandler to get city info", closure: {
                        testViewModel.getCityList()
                        verify(mockCityListHandler).getSearchCityList()
                    })
                    it("doesnt emits weather list to the UI", closure: {
                        testScheduler.scheduleAt(300, action: {
                            testViewModel.getCityList()
                        })
                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }

                        expect(res.events).to(beEmpty())
                    })
                })
            })

            describe("Search city list with name from json file", {
                var searchText: Observable<String>!

                context("when getCityInfo withFilename succeed ", {
                    beforeEach {
                        searchText = testScheduler.createColdObservable([Recorded.next(300, "Sydney")]).asObservable()

                        stub(mockCityListHandler, block: { stub in
                            when(stub.getSearchCityList()).thenReturn(Observable.just([cityList]))
                        })
                    }

                    it("emits cityList Changed to the UI", closure: {
                        testViewModel.searchCityWithName(withName: searchText)

                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }
                        expect(res.events.count).to(equal(1))
                    })

                    it("emits cityList Changed to the UI", closure: {
                        testScheduler.scheduleAt(300, action: {
                            testViewModel.getCityList()
                        })

                        testViewModel.searchCityWithName(withName: searchText)

                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }

                        let expectedValue = cityList
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement.count).to(equal(1))

                            if !firsElement.isEmpty {
                                // Success
                                expect(firsElement[0].name).to(equal(expectedValue.name))
                                expect(firsElement[0].country).to(equal(expectedValue.country))
                                expect(firsElement[0].id).to(equal(expectedValue.id))
                                expect(firsElement[0].coord?.lat).to(equal(expectedValue.coord?.lat))
                                expect(firsElement[0].coord?.lon).to(equal(expectedValue.coord?.lon))
                            } else {
                                fail("Expected city, got \(firsElement.count) counts)")
                            }
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }

                    })
                })

                context("when getCityInfo withFilename succeed ", {
                    beforeEach {
                        searchText = testScheduler.createColdObservable([Recorded.next(300, "abcd"), Recorded.next(320, "syd")]).asObservable()

                        stub(mockCityListHandler, block: { stub in
                            when(stub.getSearchCityList()).thenReturn(Observable.just([cityList]))
                        })
                    }

                    it("emits cityList Changed to the UI", closure: {
                        testViewModel.searchCityWithName(withName: searchText)

                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }
                        expect(res.events.count).to(equal(1))
                    })

                    it("emits cityList Changed to the UI", closure: {
                        testScheduler.scheduleAt(320, action: {
                            testViewModel.getCityList()
                        })

                        testViewModel.searchCityWithName(withName: searchText)

                        let testObservable = testViewModel.cityList
                        let res = testScheduler.start { testObservable }

                        let expectedValue = cityList
                        if let firsElement = res.events.last?.value.element {
                            expect(firsElement.count).to(equal(1))

                            if !firsElement.isEmpty {
                                // Success
                                expect(firsElement[0].name).to(equal(expectedValue.name))
                                expect(firsElement[0].country).to(equal(expectedValue.country))
                                expect(firsElement[0].id).to(equal(expectedValue.id))
                                expect(firsElement[0].coord?.lat).to(equal(expectedValue.coord?.lat))
                                expect(firsElement[0].coord?.lon).to(equal(expectedValue.coord?.lon))
                            } else {
                                fail("Expected city, got \(firsElement.count) counts)")
                            }
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }

                    })
                })
            })

        }
    }
}

private let coord = Coord(lon: 12.00, lat: 11.00)
private let cityList = CityListModel(id: 1, name: "Bob", coord: coord, country: "Dream Land")

private let mainModel = MainModel(temp: 12.00, pressure: 11.00, humidity: 10.00, temp_min: 9.00, temp_max: 15.00)
private let weatherResult = WeatherResult(main: mainModel, weather: nil, sys: nil, visibility: 10, wind: nil, name: "Sydney")

private let citysWeatherResult = CityWeatherModel(cnt: 1, list: [weatherResult])
