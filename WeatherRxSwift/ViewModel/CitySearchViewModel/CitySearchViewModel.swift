//
//  CitySearchViewModel.swift
//  WeatherRxSwift
//
//  Created by Nischal Hada on 4/8/19.
//  Copyright © 2019 NischalHada. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CitySearchDataSource {
    var cityList: Observable<[CityListModel]> { get }
    var isLoading: Observable<Bool> { get }
    func getCityList()
    func searchCityWithName(withName name: Observable<String>)
}

final class CitySearchViewModel: CitySearchDataSource {

    //output
    var cityList: Observable<[CityListModel]>
    var isLoading: Observable<Bool>

    //input
    private let cityListHandler: AddCityListHandlerProtocol
    private let backgroundScheduler: SchedulerType

    private let cityListSubject = PublishSubject<[CityListModel]>()
    private let loadingSubject = BehaviorRelay<Bool>(value: true)

    private var localCityList: [CityListModel]
    private let disposeBag = DisposeBag()

    init(withCityList cityListHandler: AddCityListHandlerProtocol = FileManagerWraper(),
         withSchedulerType backgroundScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.cityListHandler = cityListHandler
        self.backgroundScheduler = backgroundScheduler

        self.cityList = cityListSubject.asObservable()
        self.localCityList = []
        self.isLoading = loadingSubject.asObservable()
    }

    func getCityList() {
        self.loadingSubject.accept(true)

        self.cityListHandler
            .getSearchCityList()
            .subscribeOn(backgroundScheduler)
            .subscribe(onNext: { [weak self] cityList in
                self?.cityListSubject.onNext(cityList)
                self?.localCityList = cityList
                self?.loadingSubject.accept(false)
                }, onError: { error in
                    print("onError: \(error)")
            }).disposed(by: disposeBag)
    }

    func searchCityWithName(withName name: Observable<String>) {
        self.loadingSubject.accept(true)

        name
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] searchQuery in
                self?.loadingSubject.accept(false)

                if searchQuery.isEmpty {
                    self?.cityListSubject.onNext([])
                } else {
                    self?.filterCityname(withCityName: searchQuery)
                }
            }).disposed(by: disposeBag)
    }

    private func filterCityname(withCityName cityName: String) {
        let foundItems = self.localCityList.filter { (($0.name?.range(of: cityName)) != nil) || $0.id == Int(cityName) }
        self.cityListSubject.onNext(foundItems)
    }
}
