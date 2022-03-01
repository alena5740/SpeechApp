//
//  ViewController.swift
//  SpeechApp
//
//  Created by Алена on 01.03.2022.
//

import UIKit

// Главный экран приложения
final class ViewController: UIViewController {
    
    private let speechManager: SpeechManagerProtocol
    
    private let textField = UITextField()
    private let buttonSay = UIButton()
    private let buttonOpen = UIButton()
    
    private let boundsDevices = UIScreen.main.bounds
        
    init(speechManager: SpeechManagerProtocol) {
        self.speechManager = speechManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        
        speechManager.makeRequestAuthorizationUsers(button: buttonSay)
    }
    
    override func viewWillLayoutSubviews() {
        setupTextField()
        setupButtonSay()
        setupButtonOpen()
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "Speech"
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите или скажите что-то"
        textField.textAlignment = .center
        textField.frame = CGRect(x: 40,
                                 y: boundsDevices.height / 3,
                                 width: boundsDevices.width - 80,
                                 height: 50)
    }
    
    private func setupButtonSay() {
        view.addSubview(buttonSay)
        buttonSay.backgroundColor = .systemTeal
        buttonSay.setTitle("Распознать", for: .normal)
        buttonSay.layer.cornerRadius = 16
        buttonSay.isEnabled = false
        buttonSay.addTarget(self, action: #selector(buttonSayAction), for: .touchUpInside)
        buttonSay.frame = CGRect(x: 40,
                                 y: textField.frame.maxY + 40,
                                 width: boundsDevices.width - 80,
                                 height: 50)
    }
    
    @objc func buttonSayAction() {
        if buttonSay.isSelected {
            speechManager.stopRecognition()
            buttonSay.backgroundColor = .systemTeal
        } else {
            buttonSay.setTitle("Стоп", for: .selected)
            buttonSay.backgroundColor = .systemGreen
            speechManager.startRecognition { model in
                self.textField.text = model.speechText
            }
        }
        buttonSay.isSelected = !buttonSay.isSelected
    }
    
    private func setupButtonOpen() {
        view.addSubview(buttonOpen)
        buttonOpen.backgroundColor = .systemTeal
        buttonOpen.setTitle("Открыть", for: .normal)
        buttonOpen.layer.cornerRadius = 16
        buttonOpen.addTarget(self, action: #selector(buttonOpenAction), for: .touchUpInside)
        buttonOpen.frame = CGRect(x: 40,
                                  y: buttonSay.frame.maxY + 40,
                                  width: boundsDevices.width - 80,
                                  height: 50)
    }
    
    @objc func buttonOpenAction() {
        let speechText = speechManager.model?.speechText
        let textFieldText = textField.text
        
        if speechText == "Да" || textFieldText == "Да" {
            self.present(PresentViewController(), animated: true)
        } else if speechText == "Нет" || textFieldText == "Нет" {
            self.navigationController?.pushViewController(PushViewController(), animated: true)
        } else {
            showAlertAction()
            return
        }
    }
    
    private func showAlertAction() {
        let alertController = UIAlertController(title: "Упс, что-то не так", message: "Попробуйте ввести «Да» или «Нет»", preferredStyle: .alert)
        let action = UIAlertAction(title: "Окей", style: .default, handler: nil)
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
