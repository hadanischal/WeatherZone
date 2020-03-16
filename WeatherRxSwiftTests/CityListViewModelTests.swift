//
//  CityListViewModelTests.swift
//  WeatherRxSwiftTests
//
//  Created by Nischal Hada on 7/9/19.
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
class CityListViewModelTests: QuickSpec {

    override func spec() {
        var testViewModel: CityListViewModel!
        var mockCityListHandler: MockStartCityListHandlerProtocol!
        var mockGetWeatherHandler: MockGetWeatherHandlerProtocol!
        var testScheduler: TestScheduler!

        describe("CityListViewModel") {
            beforeEach {
                testScheduler = TestScheduler(initialClock: 0)
                mockCityListHandler = MockStartCityListHandlerProtocol()
                stub(mockCityListHandler, block: { stub in
                    when(stub.getStartCityList()).thenReturn(Observable.error(RxError.noElements))
                })
                mockGetWeatherHandler = MockGetWeatherHandlerProtocol()
                stub(mockGetWeatherHandler, block: { stub in
                    when(stub.getWeatherInfo(by: any())).thenReturn(Observable.just(weatherResult))
                    when(stub.getWeatherInfo(byCityIDs: any())).thenReturn(Observable.just(citysWeatherResult))
                })
                testViewModel = CityListViewModel(withCityList: mockCityListHandler,
                                                  withGetWeather: mockGetWeatherHandler)
            }

            describe("Get weather List from server", {

                context("when server request succeed ", {
                    beforeEach {
                        stub(mockCityListHandler, block: { stub in
                            when(stub.getStartCityList()).thenReturn(Observable.just([cityList]))
                        })
                        stub(mockGetWeatherHandler, block: { stub in
                            when(stub.getWeatherInfo(byCityIDs: any())).thenReturn(Observable.just(citysWeatherResult))
                        })
                    }
                    it("calls to the CityListHandler to get city info", closure: {
                        verify(mockCityListHandler).getStartCityList()
                    })
                    it("calls to the GetWeatherHandler to get weather info", closure: {
                        testViewModel.getCityListFromFile()
                        verify(mockGetWeatherHandler).getWeatherInfo(byCityIDs: any())
                    })
                    it("emits weather changed for citylist to the UI", closure: {
                        testViewModel.getCityListFromFile()

                        let testObservable = testViewModel.weatherList
                        let res = testScheduler.start { testObservable }

                        let expectedValue = weatherResult
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement.count).to(equal(1))

                            if !firsElement.isEmpty {
                                // Success
                                expect(firsElement[0].name).to(equal(expectedValue.name))
                                expect(firsElement[0].main?.pressure).to(equal(mainModel.pressure))
                                expect(firsElement[0].main?.humidity).to(equal(mainModel.humidity))
                                expect(firsElement[0].weather?[0].description).to(equal(weather.description))
                                expect(firsElement[0].weather?[0].main).to(equal(weather.main))
                            } else {
                                fail("Expected city, got \(firsElement.count) counts)")
                            }
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }

                    })
                })

                it("emits the weatherList to the UI", closure: {

                    let res = testScheduler.start { testViewModel.weatherList.asObservable() }
                    expect(res.events.count).to(equal(1))
                    expect(res.events.first?.time).to(equal(200))
                    if let firstElement = res.events.first?.value.element {
                        expect(firstElement).to(beEmpty())
                    } else {
                        fail("Expected weather list, got \(res.events) events)")
                    }
                })

                context("when get city info request failed ", {
                    beforeEach {
                        stub(mockCityListHandler, block: { stub in
                            when(stub.getStartCityList()).thenReturn(Observable.error(RxError.noElements))
                        })
                    }
                    it("emits weather list to the UI to update list", closure: {
                        let res = testScheduler.start { testViewModel.weatherList.asObservable() }
                         expect(res.events.count).to(equal(1))
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement).to(beEmpty())
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }
                    })
                })

                context("when server request failed for get weather info", {
                    beforeEach {

                        stub(mockCityListHandler, block: { stub in
                            when(stub.getStartCityList()).thenReturn(Observable.just([cityList]))
                        })
                        stub(mockGetWeatherHandler, block: { stub in
                            when(stub.getWeatherInfo(byCityIDs: any())).thenReturn(Observable.error(RxError.noElements))
                        })
                    }
                    it("emits weather list to the UI to update list", closure: {
                        let res = testScheduler.start { testViewModel.weatherList.asObservable() }
                        expect(res.events.count).to(equal(1))
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement).to(beEmpty())
                        } else {
                            fail("Expected city list, got \(res.events) events)")
                        }
                    })
                })

            })

            describe("fetch weather info for selected city from server", {

                context("when server request succeed ", {
                    beforeEach {
                        stub(mockGetWeatherHandler, block: { stub in
                            when(stub.getWeatherInfo(by: any())).thenReturn(Observable.just(weatherResult))
                        })
                    }
                    it("calls to the GetWeatherHandler to get weather info", closure: {
                        testViewModel.fetchWeatherFor(selectedCity: cityList)
                        verify(mockGetWeatherHandler).getWeatherInfo(by: any())
                    })
                    it("emits weather changed for citylist to the UI", closure: {
                        testViewModel.fetchWeatherFor(selectedCity: cityList)

                        let testObservable = testViewModel.weatherList
                        let res = testScheduler.start { testObservable }

                        let expectedValue = weatherResult
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement.count).to(equal(1))

                            if !firsElement.isEmpty {
                                // Success
                                expect(firsElement[0].name).to(equal(expectedValue.name))
                                expect(firsElement[0].main?.pressure).to(equal(mainModel.pressure))
                                expect(firsElement[0].main?.humidity).to(equal(mainModel.humidity))
                                expect(firsElement[0].weather?[0].description).to(equal(weather.description))
                                expect(firsElement[0].weather?[0].main).to(equal(weather.main))
                            } else {
                                fail("Expected weather, got \(firsElement.count) counts)")
                            }
                        } else {
                            fail("Expected weather list, got \(res.events) events)")
                        }

                    })
                })

                it("emits the weatherList to the UI", closure: {

                    let res = testScheduler.start { testViewModel.weatherList.asObservable() }
                    expect(res.events.count).to(equal(1))
                    expect(res.events.first?.time).to(equal(200))
                    expect(res.events.last?.time).to(equal(200))

                    if let firstElement = res.events.first?.value.element {
                        expect(firstElement).to(beEmpty())
                    } else {
                        fail("Expected weather list, got \(res.events) events)")
                    }
                })

                context("when get city info request failed ", {
                    beforeEach {
                        stub(mockGetWeatherHandler, block: { stub in
                            when(stub.getWeatherInfo(by: any())).thenReturn(Observable.error(RxError.noElements))
                        })
                    }
                    it("emits weather list to the UI to update list", closure: {
                        let res = testScheduler.start { testViewModel.weatherList.asObservable() }
                        expect(res.events.count).to(equal(1))
                        if let firsElement = res.events.first?.value.element {
                            expect(firsElement).to(beEmpty())
                        } else {
                            fail("Expected weather list, got \(res.events) events)")
                        }
                    })
                })

            })

        }
    }
}

private let coord = Coord(lon: 151.207321, lat: -33.867851)
private let cityList = CityListModel(id: 2147714, name: "Sydney", coord: coord, country: "AU")

private let mainModel = MainModel(temp: 18.52, pressure: 1003, humidity: 72, temp_min: 17.78, temp_max: 19.44)
private let weather = Weather(id: 803, main: "Clouds", description: "broken clouds", icon: "04d")
private let weatherResult = WeatherResult(main: mainModel, weather: [weather], sys: nil, visibility: 10, wind: nil, name: "Sydney")

private let citysWeatherResult = CityWeatherModel(cnt: 1, list: [weatherResult])
