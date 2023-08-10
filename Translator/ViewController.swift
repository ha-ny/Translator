//
//  ViewController.swift
//  Translator
//
//  Created by 김하은 on 2023/08/10.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet var detectSwitch: UISwitch!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var toLanguageTextField: UITextField!
    @IBOutlet var fromLanguageTextField: UITextField!
    @IBOutlet var toTextView: UITextView!
    @IBOutlet var fromTextView: UITextView!
    @IBOutlet var translateButton: UIButton!
    
    let toLanguagePickerView = UIPickerView()
    let fromLanguagePickerView = UIPickerView()
    
    let dataList = TranslatorInfo.languageList
    let detectText = "언어 감지"
    var toCode = ""
    var fromCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toLanguageTextField.inputView = toLanguagePickerView
        fromLanguageTextField.inputView = fromLanguagePickerView
        settingView()
    }
    
    @IBAction func translateButtonClick(_ sender: UIButton) {
        
        if detectSwitch.isOn{
            let alert = UIAlertController(title: "알림", message: "언어 감지 기능이 작동중입니다", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        }else{
            
            let fromLanguageText = toLanguageTextField.text
            let toLanguageText = fromLanguageTextField.text
            let fromCodeText = toCode
            let toCodeText = fromCode
            
            toLanguageTextField.text = toLanguageText
            fromLanguageTextField.text = fromLanguageText
            toCode = toCodeText
            fromCode = fromCodeText
        }
    }
    
    
    @IBAction func detectSwitchChange(_ sender: UISwitch) {
        
        if sender.isOn{
            toLanguageTextField.isEnabled = false
            toLanguageTextField.backgroundColor = .systemGray3
            toLanguageTextField.text = detectText
        }else{
            toLanguageTextField.isEnabled = true
            toLanguageTextField.backgroundColor = nil
            
            if toLanguageTextField.text != detectText{
                for data in dataList{
                    if toLanguageTextField.text == data.name{
                        toCode = data.code
                        return
                    }
                }
            }else{
                toCode = dataList[0].code
                toLanguageTextField.text = dataList[0].name
            }
        }
    }
    
    @IBAction func keyboardDown(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

//TextView
extension ViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        
        if detectSwitch.isOn{
            languageDetectAPI()
        }

        translateAPI()
    }
}

//API
extension ViewController{

    func translateAPI(){

        guard let toText = (toTextView.text == "" ? nil : toTextView.text) else { return }
        
        let url = "https://openapi.naver.com/v1/papago/n2mt"
        
        let headers = HTTPHeaders([
            "X-Naver-Client-Id": APIKey.naverID,
            "X-Naver-Client-Secret": APIKey.naverSecret,
            ])
        
        let parameters: Parameters = [
            "source": toCode,
            "target": fromCode,
            "text": toTextView.text ?? "",
        ]
        
        AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                print("---------------------------------", #function, json)
                self.fromTextView.text = json["message"]["result"]["translatedText"].stringValue
            case .failure(let error):
                print(#function, error)
            }
        }
    }
    
    func languageDetectAPI(){
 
        guard let toText = (toTextView.text == "" ? nil : toTextView.text) else { return }
        
        let url = "https://openapi.naver.com/v1/papago/detectLangs"
        
        let headers = HTTPHeaders([
            "X-Naver-Client-Id": APIKey.naverID,
            "X-Naver-Client-Secret": APIKey.naverSecret,
            ])
        
        let parameters: Parameters = [
            "query": toText
        ]
        
        AF.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                print("---------------------------------", #function, json)
                for data in self.dataList{
                    if json["langCode"].stringValue.contains(data.code){
                        self.toLanguageTextField.text = data.name
                        return
                    }
                }
                
            case .failure(let error):
                print(#function, error)
            }
        }
    }
}

//design
extension ViewController: UITextFieldDelegate{
    func settingView(){

        navigationItem.title = "T R A N S L A T O R"
        
        toLanguagePickerView.delegate = self
        toLanguagePickerView.dataSource = self
        fromLanguagePickerView.delegate = self
        fromLanguagePickerView.dataSource = self
        toTextView.delegate = self
        
        for textField in textFields{
            textField.layer.borderWidth = 1.5
            textField.layer.borderColor = UIColor.systemYellow.cgColor
            textField.layer.cornerRadius = 5
            textField.textAlignment = .center
            textField.tintColor = .clear
            textField.delegate = self
        }

        toCode = dataList[0].code
        fromCode = dataList[1].code
        toLanguageTextField.text = dataList[0].name
        fromLanguageTextField.text = dataList[1].name
        
        toTextView.layer.cornerRadius = 5
        toTextView.layer.borderWidth = 2
        toTextView.layer.borderColor = UIColor.systemGreen.cgColor
        
        fromTextView.layer.cornerRadius = 5
        fromTextView.layer.borderWidth = 2
        fromTextView.layer.borderColor = UIColor.systemTeal.cgColor
        
        detectSwitch.onTintColor = .systemMint
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

//PickerView
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        nameLabel.text = dataList[row].name
        nameLabel.textAlignment = .center
        
        let codeLabel = UILabel(frame: CGRect(x: 100, y: 0, width: 100, height: 60))
        codeLabel.text = dataList[row].code
        codeLabel.textAlignment = .center

        view.addSubview(nameLabel)
        view.addSubview(codeLabel)
         
         return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == toLanguagePickerView{
            toCode = dataList[row].code
            toLanguageTextField.text = dataList[row].name
        }else{
            fromCode = dataList[row].code
            fromLanguageTextField.text = dataList[row].name
        }
    }
}
