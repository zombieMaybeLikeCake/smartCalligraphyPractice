//
//  setViewController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/10/30.
//

import UIKit

class setViewController: UIViewController {
    var sampleTextField : UITextField!
    var wantWordText: UILabel!
    var wantWordstytleText: UILabel!
//    = "想要練的字體"
//    =" 想要練的字"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let fullScreenSize = UIScreen.main.bounds.size
        sampleTextField=UITextField(frame: CGRect(x: 20, y: 200, width: 100, height: 40))
        setuptextfield()
        // Do any additional setup after loading the view.
    }
    func setuptextfield(){
        self.view.addSubview(sampleTextField)
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        NSLayoutConstraint.activate([sampleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),sampleTextField.centerYAnchor.constraint(equalTo:view.centerYAnchor, constant: 20),sampleTextField.widthAnchor.constraint(equalToConstant: 100),sampleTextField.heightAnchor.constraint(equalToConstant: 25)])
    }
    


}
