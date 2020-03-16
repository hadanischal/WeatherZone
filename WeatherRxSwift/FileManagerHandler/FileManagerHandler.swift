//
//  FileManagerHandler.swift
//  WeatherRxSwift
//
//  Created by Nischal Hada on 14/3/20.
//  Copyright © 2020 Nischal Hada. All rights reserved.
//

import Foundation
import RxSwift

struct FileManagerResource<T> {
    let fileName: String
}

protocol FileManagerHandlerProtocol {
    func load<T: Decodable>(resource: FileManagerResource<T>) -> Observable<T>
}

final class FileManagerHandler: FileManagerHandlerProtocol {

    func load<T: Decodable>(resource: FileManagerResource<T>) -> Observable<T> {
        return Observable<T>.create { observer in

            if let url = Bundle.main.url(forResource: resource.fileName, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(T.self, from: data)
                    observer.on(.next(jsonData))
                    observer.on(.completed)
                } catch {
                    print("error:\(error)")
                    observer.on(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}
