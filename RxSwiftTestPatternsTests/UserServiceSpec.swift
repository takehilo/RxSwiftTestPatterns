import RxSwift

@testable import RxSwiftTestPatterns
import Quick
import Nimble
import RxBlocking
import Mockingjay

class UserServiceSpec: QuickSpec {
    override func spec() {
        var userService: UserService!
        
        beforeEach {
            userService = UserService()
            
            let userJson = "{\"id\": 1, \"name\": \"test-user\"}"
            self.stub(uri("https://api.example.com/users/1"), jsonData(userJson.data(using: .utf8)!))
        }
        
        it("should fetch an user") {
            let expectedUser = User(id: 1, name: "test-user")
            expect(try! userService.fetchUser(by: 1).toBlocking().single()).to(equal(expectedUser))
        }
    }
}
