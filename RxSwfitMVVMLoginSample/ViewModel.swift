//
//  ViewModel.swift
//  RxSwfitMVVMLoginSample
//
//  Created by 中山 陽介 on 2020/01/03.
//  Copyright © 2020 Yosuke Nakayama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ViewModel {
    var validationText: Observable<String>
    var loadLabelColor: Observable<UIColor>
    
    init(idTextObservable: Observable<String?>, passwordTextObservable: Observable<String?>, model: ModelProtocol) {
        
        let event = Observable
            .combineLatest(idTextObservable, passwordTextObservable)
            .skip(1)
            .flatMap { (idText, passwordText) in
                model.validate(idText: idText, passwordText: passwordText)
                .materialize()
        }.share()
        
        self.validationText = event
            .flatMap({ (event) -> Observable<String> in
                switch event {
                case .next():
                    return Observable<String>.just("OK")
                case .error(let error as ModelError):
                    return Observable<String>.just(error.errorText)
                case .completed, .error(_):
                    return Observable<String>.empty()
                }
            })
            .startWith("Please enter your User ID and Password")
        
        self.loadLabelColor = event
            .flatMap({ (event) -> Observable<UIColor> in
                switch event {
                case .next():
                    return Observable<UIColor>.just(.green)
                case .error(_):
                    return Observable<UIColor>.just(.red)
                case .completed:
                    return Observable<UIColor>.empty()
                }
            })
    }
}
