import Logging
import RxSwift
import UIKit

final class ViewModel {
    private let logger = Logger(label: "ViewModel")
    
    // MARK: - Properties (State)
    public let action = BehaviorSubject<Action?>(value: nil)
    
    public let dBagVM = DisposeBag()
    public let stateChange = PublishSubject<Void>()
    
    public var isError: Bool = false
    public var result: String = ""
    private var current: String = ""
    
    init() {
        self.action
            .subscribe(onNext: { [weak self] _ in self?.process() })
            .disposed(by: dBagVM)
    }
    
    private func process() {
        defer { self.stateChange.onNext(()) }
        
        guard let action = action.value else { return }
                
        logger.info("#process action: \(String(describing: action))")

        switch action {
        case .dot:
            current += "."
        case .hyphen:
            current += "-"
        case .space:
            processSpace()
        case .reset:
            processReset()
        case .closeAlert:
            isError = false
        case .none:
            ()
        }
        
        logger.info("#process current: \(current) result: \(result)")
    }
    
    private func processSpace() {
        guard let morse = ViewModel.decodeMorseSymbol(symbol: current) else {
            processError()
            return
        }
        logger.info("#processSymbol decode symbol \(current) is \(morse)")
        
        logger.info("#processSymbol current result \(result)")
        
        result += morse
        self.current = ""
    }
    
    private func processReset() {
        logger.info("#processReset")
        
        self.current = ""
        self.result = ""
    }
    
    private func processError() {
        logger.info("#processError")
        
        self.isError = true
        self.current = ""
    }
}

extension BehaviorSubject {
    public var value: Element? {
        return try? self.value()
    }
}
