//
//  FloatingTextField.swift
//  student
//
//  Created by Hien Ho on 2/20/20.
//

import UIKit

struct FloatingTextFieldStyle {
    var backgroundColor: UIColor
    var titleColor: UIColor
    var borderColor: UIColor = .clear
    var borderWidth: CGFloat = 0
    var titleFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
}

enum FloatingTextFieldState {
    case focus
    case unfocus
    case error
    case nothing
}

protocol FloatingTextFieldDelegate: UITextFieldDelegate {
    func didChangeText(_ floatingTextField: FloatingTextField, newText: String?)
}

extension FloatingTextFieldDelegate {
    func didChangeText(_ floatingTextField: FloatingTextField, newText: String?) {}
}

class FloatingTextField: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var requireMarkLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var seePasswordButton: UIButton!
        
    weak var delegate: FloatingTextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }
    
    var isSecureTextEntry: Bool = false {
        didSet {
            seePasswordButton.isHidden = !isSecureTextEntry
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var isShowRequireMark: Bool = false {
        didSet {
            requireMarkLabel.isHidden = !isShowRequireMark
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    var focusStyle   = FloatingTextFieldStyle(backgroundColor: .focusTextFieldColor(), titleColor: .chocolateBrownColor(), borderColor: .borderFocusColor(), borderWidth: 1)
    var unfocusStyle = FloatingTextFieldStyle(backgroundColor: .appLightGreyColor(), titleColor: .chocolateBrownColor())
    var errorStyle   = FloatingTextFieldStyle(backgroundColor: .appLightGreyColor(), titleColor: .borderErrorColor(), borderColor: .borderErrorColor(), borderWidth: 1)
    var nothingStyle = FloatingTextFieldStyle(backgroundColor: .appLightGreyColor(), titleColor: .placeholderTextColor(), titleFont: UIFont.systemFont(ofSize: 14, weight: .medium))
    
    var state: FloatingTextFieldState = .nothing {
        didSet {
            setVisibleSeePasswordIfNeeded(isHidden: false)
            textField.isHidden = false
            switch state {
            case .unfocus:
                applyStyle(style: unfocusStyle)
            case .focus:
                applyStyle(style: focusStyle)
            case .error:
                 applyStyle(style: errorStyle)
                // only show placeholder with no Text Field
            case .nothing:
                applyStyle(style: nothingStyle)
                textField.isHidden = true
                setVisibleSeePasswordIfNeeded(isHidden: true)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBAction func didTouchDownSeeButton(_ sender: Any) {
        textField.isSecureTextEntry = false
    }
    
    @IBAction func didTouchUpSeeButton(_ sender: Any) {
         textField.isSecureTextEntry = true
    }
    
    @IBAction func didBeginFocusTextField(_ sender: Any) {
        state = .focus
    }
    
    @IBAction func didEndFocusTextField(_ sender: Any) {
        if isEmptyText() {
            state = .nothing
        } else {
            state = .unfocus
        }
        
    }
    
    @IBAction func didTapWholeView(_ sender: Any) {
        state = .focus
        textField.becomeFirstResponder()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(FloatingTextField.typeName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setupUI() {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                            for: .editingChanged)
        titleLabel.text = title
        initState()
    }
    
    private func initState() {
        state = .nothing
        isShowRequireMark = true
    }
    
    private func applyStyle(style: FloatingTextFieldStyle) {
        contentView.backgroundColor = style.backgroundColor
        contentView.borderWidth = style.borderWidth
        contentView.borderColor = style.borderColor
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
    }
    
    private func isEmptyText() -> Bool {
        return String.isNilOrEmpty(value: textField.text)
    }
    
    
    /// Set visible hide/show See password button
    ///  Condition: Field must be Password based on property [isSecureTextEntry]
    /// - Parameter isHidden: hidden/show
    private func setVisibleSeePasswordIfNeeded(isHidden: Bool) {
        guard isSecureTextEntry == true else { return }
        seePasswordButton.isHidden = isHidden
    }
}

// MARK: Active Functions
extension FloatingTextField {
    func unfocusTextField() {
        textField.resignFirstResponder()
    }
    
    func focusTextField() {
        state = .focus
        textField.becomeFirstResponder()
    }
}

// MARK: Text Field did change
extension FloatingTextField {
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.didChangeText(self, newText: textField.text)
    }
}
