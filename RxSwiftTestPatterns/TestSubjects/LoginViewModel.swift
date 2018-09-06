import RxSwift
import RxCocoa

class LoginViewModel {
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")

    var isValidEmail: Driver<Bool> {
        return email.asDriver().map { !$0.isEmpty }
    }
    
    var isValidPassword: Driver<Bool> {
        return password.asDriver().map { !$0.isEmpty }
    }
    
    var isValidForm: Driver<Bool> {
        return Driver.combineLatest(isValidEmail, isValidPassword).map { $0 && $1 }
    }
}
