//
//  ViewController.swift
//  RxSwfitMVVMLoginSample
//
//  Created by 中山 陽介 on 2020/01/03.
//  Copyright © 2020 Yosuke Nakayama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var validationLabel: UILabel!
    private let disposeBag = DisposeBag()

    private lazy var viewModel = ViewModel(
        idTextObservable: self.idTextField.rx.text.asObservable(),
        passwordTextObservable: self.passwordTextField.rx.text.asObservable(),
        model: Model()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.validationText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)

        self.viewModel.loadLabelColor
            .bind { (color) in
                self.validationLabel.textColor = color
        }
            .disposed(by: disposeBag)
        
    }
}

