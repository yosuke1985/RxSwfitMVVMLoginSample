//
//  Model.swift
//  RxSwfitMVVMLoginSample
//
//  Created by 中山 陽介 on 2020/01/03.
//  Copyright © 2020 Yosuke Nakayama. All rights reserved.
//

import Foundation
import RxSwift

enum ModelError: Error {
    case invalidId
    case invalidPassword
    case invalidIdAndPassword
}

extension ModelError {
    var errorText: String {
        switch self {
        case .invalidIdAndPassword:
            return "ID and Password are not entered."
        case .invalidId:
            return "ID has not been entered."
        case .invalidPassword:
            return "Password has not been entered."
        }
    }
}

protocol ModelProtocol {
    func validate(idText:String?, passwordText:String?)->Observable<Void>
}

class Model: ModelProtocol {
    func validate(idText: String?, passwordText: String?) -> Observable<Void> {
        switch (idText, passwordText) {
        case (.some, .none):
            return Observable.error(ModelError.invalidPassword)
        case (.none, .some):
            return Observable.error(ModelError.invalidId)
        case (.none, .none):
            return Observable.error(ModelError.invalidIdAndPassword)
        case (let idText?, let passwordText?):
            switch (idText.isEmpty, passwordText.isEmpty) {
            case (true, true):
                return Observable.error(ModelError.invalidIdAndPassword)
            case (true, false):
                return Observable.error(ModelError.invalidPassword)
            case (false, true):
                return Observable.error(ModelError.invalidId)
            case (false, false):
                return Observable.just(())
            }
        }
    }
}
