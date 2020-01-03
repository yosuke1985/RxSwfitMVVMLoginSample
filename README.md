# RxSwiftMVVMログイン画面.md

## 要件

- id, passを入力する。
- id, pass未記入ならば、"IDとPassを入力してください"　と表示
- passが未記入ならば、"IDを入力してください"と表示。
- idが未記入ならば、"Passを入力してください"と表示。
- id,passが記入済みならば、"OK"と表示。

## 技術要件

- Swift5
- アーキテクチャはMVVM
- 作り方
  1. StoryboardでViewを作成し、ViewControllerに宣言する。
  2. Modelを定義する。エラーとバリデーションを定義。
     1. ここでは、ビジネスロジックがバリデーションになるためこれをモデルとする。
  3. Viewのロジックを担うViewModelを作成。
     1. Viewから流れてきたid,passの文字列をテキストを受け取る。
     2. そのテキスト内容に連動したメッセージ（エラー含む）、そのメッセージの色を流す。Viewはそれを受けて表示する。
  4. ViewModelとのデータバインディングを行う。

## Model

- enum ModelError: Errorの定義
  - invalidId
  - invalidPassword
  - invalidIdAndPassword
- enumにvar errorText: Stringを定義
  - .invalidIdAndPassword "IDとPasswordが未入力です。"
  - .invalidId "IDが未入力です。"
  - .invalidPassword "Passwordが未入力です。"
- protocol ModelProtocolでvalidateを定義
- そのprotocolに批准したModelクラスを作成
- validate関数はid,passのOptional Stringのタプルを引数。戻り値は、Observable<Void>
  - 渡ってきたタプルをswitchで判定。Optional.none, Optional.some。
    - そのswitch文にて定義したenum ModelError: Error に振り分ける。
    - 空文字の場合も判定する。 case (let idText.isEmpty, passwordText.isEmpty)
    - どちらも空文字でなければ、Observable.just(())

## View(ViewController)

- idTextField: UITextField, passwordTextField: UITextField, validationLabel: UILabelをOutletで宣言する。
- idTextField, passwordTextFieldからViewModelへのデータバインディング＆ViewModelのインスタンス化
  - viewModelはidTextField, passwordTextFieldのtextをObservable化したもの、他にModelから初期化する。
- viewModelからのデータバインディング
  - viewModelのvalidtionTextをvalidationLabelのtextにバインド
  - viewModelのloadLabelColorをvalidationDescriptionのUIColorにバインドする
    - Binderの作り方　<https://blog.a-azarashi.jp/entry/2018/01/13/222537/>

## ViewModel

- validationText: Observable<String>, loadLabelColor: Observable<UIColor>をメンバ変数を持つ。
  - この２つのObseravableのメンバ変数がViewとデータバインディングされる。
- initでidTextObservable: Observable<String?>,passwordTextObservable: Observable<String?>,model: ModelProtocol
  - からvalidationText: Observable<String>, loadLabelColor: Observable<UIColor>のストリームに流す。
  - （ViewControllerがViewModelクラスのインスタンスを保持している。）
  - combineLatestでidTextObservable, passwordTextObservableをひとまとめにする。
  - 渡ってきた２つのObservable<String?>をmodel.validateでバリデーションをかける。
    - materializeを使うと、Observable<T>をObservable<Event<T>に変換することができます。
    - <https://egg-is-world.com/2018/08/04/rxswift-materialize-dematealize/>
  - そのバリデーションした結果をもとにvalidationTextとloadLabelColorの変数に入れたいので、share()を記述。
  - validationText
    - .next: .just("OK"), .error(let error): just(エラーの内容), .error, .completed: .empty()
  - loadLabelColor
    - next: .green, .error: .red, .completed: .empty()