import Foundation

extension ViewModel {
    enum Action: Int, CustomStringConvertible {
        case dot
        case hyphen
        case space
        case reset
        case closeAlert
        
        var description: String {
            switch self {
            case .dot: return "."
            case .hyphen: return "-"
            case .space: return "_"
            case .reset: return "Reset"
            case .closeAlert: return "Close"
            }
        }
    }
}
