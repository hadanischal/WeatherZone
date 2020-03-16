//
//  CityListViewModel.swift
//  WeatherRxSwift
//
//  Created by Nischal Hada on 6/20/19.
//  Copyright © 2019 NischalHada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CityListDataSource {
    var weatherList: Observable<[WeatherResult]> { get }
    var errorMessage: Observable<String> { get }
    func getCityListFromFile()
    func fetchWeatherFor(selectedCity cityName: CityListModel)
}

final class CityListViewModel: CityListDataSource {

    //output
    var cityList: [CityListModel]!
    var weatherList: Observable<[WeatherResult]>
    var errorMessage: Observable<String>

    //input
    private let cityListHandler: StartCityListHandlerProtocol
    private let weatherHandler: GetWeatherHandlerProtocol
    private let weatherListBehaviorRelay: BehaviorRelay<[WeatherResult]> = BehaviorRelay(value: [])
    private let errorSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    init(withCityList cityListHandler: StartCityListHandlerProtocol = FileManagerWraper(),
         withGetWeather weatherHandler: GetWeatherHandlerProtocol = GetWeatherHandler()) {
        self.cityListHandler = cityListHandler
        self.weatherHandler = weatherHandler
        self.weatherList = weatherListBehaviorRelay.asObservable()
        self.errorMessage = errorSubject.asObserver()

        self.cityList = []
        self.syncTask()
        self.getCityListFromFile()
    }

    private func syncTask() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        Observable<Int>.interval(.seconds(200), scheduler: scheduler)
            .subscribe(onNext: { [weak self] _ in
                self?.getWeatherInfoForCityList()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Get Citylist from jsonfile

    func getCityListFromFile() {
        self.cityListHandler
            .getStartCityList()
            .subscribe(onNext: { [weak self] cityListModel in
                self?.cityList = cityListModel
                self?.getWeatherInfoForCityList()
                }, onError: { error in
                    print("getCityInfo onError: \(error)")
                    self.errorSubject.onNext("Unable to get city list.")
            }).disposed(by: disposeBag)
    }

    // Get weather list for city list
    private func getWeatherInfoForCityList() {
        let arrayId = cityList.map { String($0.id!) }
        let stringIds = arrayId.joined(separator: ",")

        self.weatherHandler
            .getWeatherInfo(byCityIDs: stringIds)
            .subscribe(onNext: { [weak self] cityListWeather in
                if let weatherList = cityListWeather.list {
                    self?.weatherListBehaviorRelay.accept(weatherList)
                }
                }, onError: { error in
                    print("WeatherInfoForCityList onError: \(error)")
                    self.errorSubject.onNext("Unable to get weather information for city list.")
            }).disposed(by: disposeBag)
    }

    // MARK: - Fetch weather for selected city

    func fetchWeatherFor(selectedCity city: CityListModel) {
        let foundItems = self.cityList.filter {$0.id == city.id }

        if foundItems.isEmpty, //add city if its not in list
            let cityId = city.name {

            self.cityList.append(city)

            self.weatherHandler
                .getWeatherInfo(by: "\(cityId)")
                .filter { $0 != nil}
                .map { $0!}
                .subscribe(onNext: { [weak self] weatherResult in
                    if let weatherRelayValue = self?.weatherListBehaviorRelay.value {

                        var weatherListAppended = weatherRelayValue
                        weatherListAppended.append(weatherResult)

                        self?.weatherListBehaviorRelay.accept(weatherListAppended)
                    }

                    }, onError: { error in
                        print("selectedCity onError: \(error)")
                        self.errorSubject.onNext("Unable to get weather information for selected city.")
                }).disposed(by: disposeBag)
        } else {
            self.errorSubject.onNext("City already added in city list.")
        }

    }
}
