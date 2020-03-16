//
//  FileManagerWraper.swift
//  WeatherRxSwift
//
//  Created by Nischal Hada on 14/3/20.
//  Copyright © 2020 Nischal Hada. All rights reserved.
//

import Foundation
import RxSwift

protocol StartCityListHandlerProtocol {
    func getStartCityList() -> Observable<[CityListModel]>
}

protocol AddCityListHandlerProtocol {
    func getSearchCityList() -> Observable<[CityListModel]>
}

protocol DetailListHandlerProtocol {
    func getDetailInfo() -> Observable<[DetailModel]>
}

typealias FileManagerHandeller = StartCityListHandlerProtocol & AddCityListHandlerProtocol & DetailListHandlerProtocol

final class FileManagerWraper: FileManagerHandeller {

    private let fileManagerHandler: FileManagerHandlerProtocol!

    init(withFileManagerHandler fileManagerHandler: FileManagerHandlerProtocol = FileManagerHandler()) {
        self.fileManagerHandler = fileManagerHandler
    }

    func getStartCityList() -> Observable<[CityListModel]> {
        let resource: FileManagerResource<[CityListModel]> = FileManagerResource(fileName: "StartCity")
        return fileManagerHandler.load(resource: resource)
    }

    func getSearchCityList() -> Observable<[CityListModel]> {
        let resource: FileManagerResource<[CityListModel]> = FileManagerResource(fileName: "cityList")
        return fileManagerHandler.load(resource: resource)
    }

    func getDetailInfo() -> Observable<[DetailModel]> {
        let resource: FileManagerResource<[DetailModel]> = FileManagerResource(fileName: "detailList")
        return fileManagerHandler.load(resource: resource)
    }
}
