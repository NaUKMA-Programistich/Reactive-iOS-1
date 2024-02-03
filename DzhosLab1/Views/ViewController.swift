import Logging
import RxSwift
import UIKit

final class ViewController: UIViewController {
    
    private var viewModel = ViewModel()
    private let dBagVC = DisposeBag()
    
    private let logger = Logger(label: "ViewController")

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info("#viewDidLoad")
        
        view.addSubview(buildView)
        setupConstraints()
        logger.info("#viewDidLoad setup view")
        
        viewModel.stateChange.subscribe(
            onNext: {[weak self] in self?.onVMStateChange()}
        ).disposed(by: dBagVC)
    }
    
    private func onVMStateChange() {
        let text = self.viewModel.result
        if text.isEmpty {
            self.resultView.text = "Try Input"
        } else {
            self.resultView.text = text
        }
        
        if self.viewModel.isError {
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    private lazy var alertView: UIAlertController = {
        let alert = UIAlertController(
            title: "Bag symbols",
            message: "Symbols cannot parse",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Close",
            style: .destructive,
            handler: { _ in self.viewModel.action.onNext(.closeAlert) }
        )
        alert.addAction(action)
        return alert
    }()

    private lazy var resultView: UILabel = {
        let label = UILabel()
        label.text = "Try Input"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var resetButton: UIButton = { buildButton(action: .reset) }()
    
    private lazy var dotButton: UIButton = { self.buildButton(action: .dot) }()

    private lazy var hyphenButton: UIButton = { self.buildButton(action: .hyphen) }()

    private lazy var spaceButton: UIButton = { self.buildButton(action: .space) }()
    
    private lazy var actionButtons: UIView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(dotButton)
        stackView.addArrangedSubview(hyphenButton)
        stackView.addArrangedSubview(spaceButton)
        
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var buildView: UIView = {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        stackView.addArrangedSubview(resultView)
        stackView.addArrangedSubview(actionButtons)
        stackView.addArrangedSubview(resetButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buildView.widthAnchor.constraint(equalToConstant: 200),
            buildView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buildView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            resultView.topAnchor.constraint(equalTo: buildView.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: buildView.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: buildView.trailingAnchor),
            
            actionButtons.leadingAnchor.constraint(equalTo: buildView.leadingAnchor),
            actionButtons.trailingAnchor.constraint(equalTo: buildView.trailingAnchor),
            actionButtons.topAnchor.constraint(equalTo: resultView.bottomAnchor),
            
            resetButton.leadingAnchor.constraint(equalTo: buildView.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: buildView.trailingAnchor),
            resetButton.topAnchor.constraint(equalTo: actionButtons.bottomAnchor)
        ])
    }
    
    private func buildButton(action: ViewModel.Action) -> UIButton {
        let button = UIButton()
        
        button.setTitle(action.description, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12

        button.tag = action.rawValue
        button.addTarget(self, action: #selector(processButton), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func processButton(_ sender: UIButton) {
        let action = ViewModel.Action(rawValue: sender.tag)
        self.viewModel.action.onNext(action)
    }
}

#Preview {
    return ViewController()
}


