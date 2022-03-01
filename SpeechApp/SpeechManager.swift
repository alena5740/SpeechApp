//
//  SpeechManager.swift
//  SpeechApp
//
//  Created by Алена on 01.03.2022.
//

import AVFoundation
import Speech
import UIKit

// Протокол менеджера для работы с распознаванием речи
protocol SpeechManagerProtocol {
    func makeRequestAuthorizationUsers(button: UIButton)
    func startRecognition(completion: @escaping(Model) -> Void)
    func stopRecognition()
    var model: Model? { get }
}

// Менеджер для работы с распознаванием речи
final class SpeechManager: SpeechManagerProtocol {
        
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU"))
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var model: Model?
        
    func makeRequestAuthorizationUsers(button: UIButton) {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    button.isEnabled = true
                }
            case .denied:
                print("status denied")
            case .notDetermined:
                print("status not determined")
            case .restricted:
                print("status restricted")
            @unknown default:
                print("error request authorization")
            }
        }
    }
    
    func startRecognition(completion: @escaping(Model) -> Void) {
        let node = audioEngine.inputNode
        let recognitionFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recognitionFormat) {
            [weak self](buffer, audioTime) in
            guard let self = self else { return }
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch let error {
            print("\(error.localizedDescription)")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request,
                                                            resultHandler: {[weak self] (result, error) in
            guard let self = self else { return }
            if let res = result?.bestTranscription {
                DispatchQueue.main.async {
                    let text = res.formattedString
                    let model = Model(speechText: text)
                    self.model = model
                    completion(model)
                }
            } else if let error = error {
                print("\(error.localizedDescription)")
                node.removeTap(onBus: 0)
            }
        })
    }
    
    func stopRecognition() {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}
