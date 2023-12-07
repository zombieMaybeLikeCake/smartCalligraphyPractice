//
//  setViewController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/10/30.
//

import UIKit
struct imagedata: Codable {
    let data: [String]
}
protocol setViewdelegat: AnyObject {
    func setvalue(_ controller: setViewController,wordlengt:CGFloat,colnum:Int,words:[String],flag:Bool,strokefalg:Bool)
}
class setViewController: UIViewController, UITextFieldDelegate,UIColorPickerViewControllerDelegate {
    
    var wordstylebar:UIToolbar!
    var nowwordstytle:UILabel!
    var wordstyle:UIPickerView!
    var wordstyletext:UILabel!
    var wordstytleTextField: UITextField!
    var wordstylebutton:UIButton!
    var wordstyleblenderratio:UISlider!
    var wordstyleblenderratiotext:UILabel!
    var blenderstyle:UIButton!
    var wordlengthslider:UISlider!
    var wordlengthstext : UILabel!
    var sampleTextField : UITextField!
    var wantWordText: UILabel!
    var wantWordstytleText: UILabel!
    var colnumslider:UISlider!
    var colnumtext:UILabel!
    @objc var confirmButton:UIButton!
    var rowwordnum:Int = 8
    var colwordnum:Int = 12
    var wordlength:CGFloat = 75
    var goalStrings:[String] = []
    var goalString:String = "測試文字測試文字"
    var goalwordimagebase64:[String] = []
    var IP:String = "http://192.168.0.103:8080"
    var switchControltext:UILabel!
    var switchControl : UISwitch!
    var strokeControltext : UILabel!
    var strokeControl : UISwitch!
    var changecolor:UIButton!
    var showFormFlag=true
    var showStroke=true
    var nowstyle:Int=0
    var blenderstytle:String="無"
    var blenderstytleindex:Int = 0
    var rationum:Float = 0.0
    var strokecolor:UIColor?
    var strokecolorInts:[Int]=[0,0,0,255]
    weak var delegate:setViewdelegat!
    let style = ["原創","原創二值化", "衡山毛筆", "雁宇落雁","青松手寫","Dengxian","大陸宋體","fzshuti","漢儀新帝永樂大典","微軟正黑體","教育部隸書","王漢中行書","新帝竹林體","仿宋體","中易黑體","漢儀新蒂唐朝體","华文仿宋","STSong","隨峰體","宋體","小賴字體","標楷體"]
    let blender = ["無","原創","原創二值化", "衡山毛筆", "雁宇落雁","青松手寫","Dengxian","大陸宋體","fzshuti","漢儀新帝永樂大典","微軟正黑體","教育部隸書","王漢中行書","新帝竹林體","仿宋體","中易黑體","漢儀新蒂唐朝體","华文仿宋","STSong","隨峰體","宋體","小賴字體","標楷體"]
//    =" 想要練的字"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let fullScreenSize = UIScreen.main.bounds.size
        let viewheight=fullScreenSize.height+200
        let viewwidth=fullScreenSize.width
        let spacingnum=55
        wordstyle=UIPickerView()
        wordstylebar=UIToolbar()
        
        wantWordText=UILabel(frame:CGRect(x:viewwidth/2-40, y:viewheight/2-CGFloat(spacingnum*10), width: 300, height: 40))
        sampleTextField=UITextField(frame: CGRect(x:viewwidth/2-250, y:viewheight/2-CGFloat(spacingnum*9), width: 500, height: 40))
        
        nowwordstytle=UILabel(frame:CGRect(x:viewwidth/2-80, y:viewheight/2-CGFloat(spacingnum*8), width: 300, height: 40))
        wordstylebutton=UIButton(frame: CGRect(x:viewwidth/2-150, y:viewheight/2-CGFloat(spacingnum*5), width: 300, height: 40))
        
        wordstyleblenderratiotext=UILabel(frame:CGRect(x:viewwidth/2-180, y:viewheight/2-CGFloat(spacingnum*6), width: 600, height: 40))
        wordstyleblenderratio=UISlider(frame:CGRect(x:viewwidth/2-200, y:viewheight/2-CGFloat(spacingnum*7), width: 400, height: 40))
//        blenderstyle=UIButton(frame: CGRect(x:viewwidth/2-40, y:viewheight/2-CGFloat(spacingnum*3), width: 300, height: 40))
        
        colnumtext=UILabel(frame:CGRect(x:viewwidth/2-80, y:viewheight/2-CGFloat(spacingnum*4), width: 300, height: 40))
        colnumslider=UISlider(frame:CGRect(x:viewwidth/2-200, y:viewheight/2-CGFloat(spacingnum*3), width: 400, height: 40))
        
        wordlengthstext=UILabel(frame:CGRect(x:viewwidth/2-80, y:viewheight/2-CGFloat(spacingnum*2), width: 300, height: 40))
        wordlengthslider=UISlider(frame:CGRect(x:viewwidth/2-200, y:viewheight/2-CGFloat(spacingnum*1), width: 400, height: 40))
        
        switchControltext=UILabel(frame:CGRect(x:viewwidth/2-300, y:viewheight/2+CGFloat(spacingnum)*0, width: 150, height: 40))
        switchControl=UISwitch(frame: CGRect(x:viewwidth/2-150, y:viewheight/2+CGFloat(spacingnum)*0, width: 150, height: 40))
        strokeControltext=UILabel(frame:CGRect(x:viewwidth/2, y:viewheight/2+CGFloat(spacingnum)*0, width: 250, height: 40))
        strokeControl=UISwitch(frame: CGRect(x:viewwidth/2+150, y:viewheight/2+CGFloat(spacingnum)*0, width: 250, height: 40))
        changecolor=UIButton(frame: CGRect(x:viewwidth/2+230, y:viewheight/2+CGFloat(spacingnum)*0, width: 40, height: 40))
        confirmButton=UIButton(frame: CGRect(x:viewwidth/2-150, y:viewheight/2+CGFloat(spacingnum)*1, width: 300, height: 40))
        
        wordstytleTextField=UITextField()
       
        setuptextfield()
        setupwordlengthslide()
        setupcolnumslide()
        setupconfirmButton()
        setupwordstyle()
        setupwordstyleblenderratio()
        setupSwitcher()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func setupwordstyle(){
        self.view.addSubview(nowwordstytle)
        self.view.addSubview(wordstylebutton)
        self.view.addSubview(wordstytleTextField)
        wordstytleTextField.isHidden=true
        nowwordstytle.font = UIFont.systemFont(ofSize: 20)
        nowwordstytle.textColor = UIColor.black
        nowwordstytle.text="目前字體:"+style[0]
        wordstylebutton.configuration = .filled()
        wordstylebutton.configuration?.baseBackgroundColor = .systemBlue
        wordstylebutton.configuration?.title = "更改字體&混合字體"
        
        wordstylebutton.addTarget(self, action: #selector(openstylepicker), for: .touchDown)
        let cancelbutton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelstylepicker))
        let spacebutton=UIBarButtonItem(systemItem: .flexibleSpace)
        let changebutton = UIBarButtonItem(title: "更改", style: .plain, target:self, action: #selector(closestylepicker))
        wordstylebar.setItems([cancelbutton,spacebutton,changebutton], animated: true)
        wordstylebar.translatesAutoresizingMaskIntoConstraints = false
//        wordstylebar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        wordstylebar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        wordstylebar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        wordstyle.dataSource = self
        wordstyle.delegate = self
        wordstytleTextField.inputAccessoryView = wordstylebar
        wordstytleTextField.inputView = wordstyle
        
        
    }
    func setupwordstyleblenderratio(){
        self.view.addSubview(wordstyleblenderratiotext)
        self.view.addSubview(wordstyleblenderratio)
//        self.view.addSubview(blenderstyle)
        wordstyleblenderratiotext.font = UIFont.systemFont(ofSize: 20)
        wordstyleblenderratiotext.textColor = UIColor.black
        wordstyleblenderratiotext.text="目前混合比率:"+String(rationum)+"目前混合字體:"+blenderstytle
        wordstyleblenderratio.maximumValue=1
        wordstyleblenderratio.minimumValue=0
        wordstyleblenderratio.setValue(0, animated: true)
        wordstyleblenderratio.addTarget(self, action: #selector(wordstyleblenderratioChange(_:)), for: .valueChanged)
        wordstyleblenderratio.isContinuous = true
//        blenderstyle.configuration = .filled()
//        blenderstyle.configuration?.baseBackgroundColor = .systemBlue
//        blenderstyle.configuration?.title = "選擇混合字體"
    }
    func setuptextfield(){
        self.view.addSubview(sampleTextField)
        self.view.addSubview(wantWordText)
        wantWordText.text="想練的字"
        wantWordText.font = UIFont.systemFont(ofSize: 20)
        wantWordText.textColor=UIColor.black
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.delegate = self
    }
    func setupwordlengthslide(){
        self.view.addSubview(wordlengthstext)
        self.view.addSubview(wordlengthslider)
        wordlengthslider.maximumValue=120
        wordlengthslider.minimumValue=20
        wordlengthslider.setValue(75, animated: true)
        wordlengthslider.addTarget(self, action: #selector(wordlengthsliderValueChanged(_:)), for: .valueChanged)
        wordlengthstext.font = UIFont.systemFont(ofSize: 20)
        wordlengthstext.textColor = UIColor.black
        wordlengthstext.text = "目前練字框大小："+String(wordlengthslider.value)
        
    }
    func setupcolnumslide(){
        self.view.addSubview(colnumslider)
        self.view.addSubview(colnumtext)
        colnumslider.maximumValue=12
        colnumslider.minimumValue=2
        colnumslider.setValue(7, animated: true)
        colnumslider.addTarget(self, action: #selector(colnumsliderValueChanged(_:)), for: .valueChanged)
        colnumtext.font = UIFont.systemFont(ofSize: 20)
        colnumtext.textColor = UIColor.black
        colnumtext.text = "目前練字框數目："+String(Int(colnumslider.value))
        
    }
    func setupconfirmButton(){
        self.view.addSubview(confirmButton)
        confirmButton.configuration = .filled()
        confirmButton.configuration?.baseBackgroundColor = .systemBlue
        confirmButton.configuration?.title = "確認設定"
        confirmButton.addTarget(self, action: #selector(returndata), for: .touchDown)
    }
    func setupSwitcher(){
        view.addSubview(switchControltext)
        view.addSubview(switchControl)
        view.addSubview(strokeControltext)
        view.addSubview(strokeControl)
        view.addSubview(changecolor)
        
        switchControltext.text="字帖模式"
        strokeControltext.text="筆畫預測"
        strokeControl.isOn = true
        switchControl.isOn = true
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        strokeControl.addTarget(self, action: #selector(strokeChanged(_:)), for: .valueChanged)
        changecolor.configuration = .filled()
        changecolor.configuration?.baseBackgroundColor = .systemBlue
        changecolor.configuration?.image=UIImage(systemName:"paintpalette")
        changecolor.addTarget(self, action: #selector(tapcolorpicker), for: .touchDown)
    }
    @objc func tapcolorpicker(){
        let colorPickerVC=UIColorPickerViewController()
        colorPickerVC.isModalInPresentation=true
        colorPickerVC.delegate=self
        present(colorPickerVC,animated: true)
        
        
    }
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color=viewController.selectedColor
        strokecolorInts=color.toRGBA()
        transmitcolor()
    }
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
    }
    @objc func wordstyleblenderratioChange(_ sender: UISlider){
        let discreteValues: [Float] = [0,0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.95,1.0] // 定義分段的值
        let value = sender.value
        let roundedValue = roundValue(value: value, discreteValues: discreteValues)
        rationum = roundedValue
        wordstyleblenderratiotext.text="目前混合比率:"+String(rationum)+"目前混合字體:"+blenderstytle
    }
    @objc func wordlengthsliderValueChanged(_ sender: UISlider) {
            // 当滑块值发生变化时，更新标签文本
        let roundedValue = Int(round(sender.value))
        wordlengthupdateValueLabel(value: roundedValue)

    }
    func wordlengthupdateValueLabel(value: Int) {
        wordlength=CGFloat(value)
        wordlengthstext.text = "目前練字框大小："+String(value)
    }
    @objc func colnumsliderValueChanged(_ sender: UISlider) {
            // 当滑块值发生变化时，更新标签文本
        let roundedValue = Int(round(sender.value))
        colnumupdateValueLabel(value: roundedValue)
    }
    func colnumupdateValueLabel(value: Int) {
        colwordnum = value
        colnumtext.text = "目前練字框數目："+String(value)
    }
    // 關閉瑩幕小鍵盤
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // 當按下右下角的return鍵時觸發
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goalString=textField.text!
        textField.resignFirstResponder() // 關閉鍵盤
        return true
    }
    @objc func openstylepicker(){
        wordstytleTextField.becomeFirstResponder()
    }
    @objc func closestylepicker(){
        let stylerow = wordstyle.selectedRow(inComponent: 0)
        let blenderrow = wordstyle.selectedRow(inComponent: 1)
        nowwordstytle.text="目前字體:"+style[stylerow]
        nowstyle=stylerow
        blenderstytle=blender[blenderrow]
        blenderstytleindex=blenderrow
        wordstyleblenderratiotext.text="目前混合比率:"+String(rationum)+"目前混合字體:"+blenderstytle
        transmitstyle()
        self.view.endEditing(true)
    }
    @objc func cancelstylepicker(){
        self.view.endEditing(true)
    }
    @objc func returndata(){
        if showFormFlag{
            producewordimage(goalword: self.goalString)
        }
        else{
            delegate.setvalue(self, wordlengt: wordlength, colnum:colwordnum,words:goalStrings,flag:showFormFlag,strokefalg: showStroke)
                    dismiss(animated: true)
        }
//        print(goalwordimagebase64)
//        delegate.setvalue(self, wordlengt: wordlength, colnum: colwordnum,words:goalwordimagebase64,flag: showFormFlag)
//        dismiss(animated: true)
    }
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            showFormFlag=true
        }
        else {
            showFormFlag=false
        }
    }
    @objc func strokeChanged(_ sender: UISwitch) {
        if sender.isOn {
            showStroke=true
        }
        else {
            showStroke=false
        }
    }
    func roundValue(value: Float, discreteValues: [Float]) -> Float {
           var closestValue: Float = discreteValues[0]
           var minDifference = abs(discreteValues[0] - value)

           for discreteValue in discreteValues {
               let difference = abs(discreteValue - value)
               if difference < minDifference {
                   minDifference = difference
                   closestValue = discreteValue
               }
           }

           return closestValue
       }
    func transmitstyle(){
        let urlString = IP+"/?stytle="+String(nowstyle)+"&blender="+String(blenderstytleindex)+String(Int(rationum*100))
        let goodurl = urlString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
//        imageDownloader.downloadImage(from: goodurl!)
        guard let url : URL = URL(string: goodurl!)
        else{
            print("get image error")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error)  in
            print(url)
                if let data = data {
//                    DispatchQueue.main.async{
//                        do{
//                            let waitview = smartCalligraphyPractice.LoadingViewController()
//                            waitview.delegate = self
//                            self.showDetailViewController(waitview, sender: self)
//                            self.present(waitview, animated: true, completion: nil)
//                            let decoder = JSONDecoder()
//                            let images = try decoder.decode(imagedata.self, from: data)
//                            self.goalStrings = images.data
//                            usleep(2000000)
//                            self.dismiss(animated: true, completion: nil)
//                        }
                        //                        self.label.text = "test"
                        
//                    catch _ {
//                            print("JSON Error")
//                        }
//                    }
                }
        }
        task.resume()
    }
    func transmitcolor(){
        let urlString = IP+"/?red="+String(strokecolorInts[0])+"&green="+String(strokecolorInts[1])+"&blue="+String(strokecolorInts[2])+"&alph="+String(strokecolorInts[3])
        let goodurl = urlString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
//        imageDownloader.downloadImage(from: goodurl!)
        guard let url : URL = URL(string: goodurl!)
        else{
            print("get image error")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error)  in
            print(url)
                if let data = data {
//                    DispatchQueue.main.async{
//                        do{
//                            let waitview = smartCalligraphyPractice.LoadingViewController()
//                            waitview.delegate = self
//                            self.showDetailViewController(waitview, sender: self)
//                            self.present(waitview, animated: true, completion: nil)
//                            let decoder = JSONDecoder()
//                            let images = try decoder.decode(imagedata.self, from: data)
//                            self.goalStrings = images.data
//                            usleep(2000000)
//                            self.dismiss(animated: true, completion: nil)
//                        }
                        //                        self.label.text = "test"
                        
//                    catch _ {
//                            print("JSON Error")
//                        }
//                    }
                }
        }
        task.resume()
    }
    func producewordimage(goalword:String){
        let urlString = IP+"/?goalword="+goalword
        let goodurl = urlString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
//        imageDownloader.downloadImage(from: goodurl!)
        guard let url : URL = URL(string: goodurl!)
        else{
            print("get image error")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [self] (data, response, error)   in
                if let data = data {
                    DispatchQueue.main.async{
                        do{
//                            let waitview = smartCalligraphyPractice.LoadingViewController()
//                            waitview.delegate = self
//                            self.showDetailViewController(waitview, sender: self)
//                            self.present(waitview, animated: true, completion: nil)
                            
                            let decoder = JSONDecoder()
                            let images = try decoder.decode(imagedata.self, from: data)
                            let goalStrings = images.data
                            delegate.setvalue(self, wordlengt: wordlength, colnum:colwordnum,words:goalStrings,flag:showFormFlag,strokefalg: showStroke)
                            dismiss(animated: true)
                            

                            
                        }
                        //                        self.label.text = "test"
                        
                        catch let parseError {
                            print("JSON Error")
                        }
                    }
                }
            
            
        }
        task.resume()
//        return goalStrings
    }
}
extension setViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
                   return style.count // 第一個分組的行數
               } else {
                   return blender.count // 第二個分組的行數
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return style[row] // 第一個分組的標題
        }
        else {
            return blender[row] // 第二個分組的標題
        }
    }
}
extension UIColor {
    func toRGBA() -> [Int] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return [] // Unable to get RGBA components
        }
        
        let intRed = Int(red * 255.0)
        let intGreen = Int(green * 255.0)
        let intBlue = Int(blue * 255.0)
        let intAlpha = Int(alpha * 255.0)
        
        return [intRed, intGreen, intBlue, intAlpha]
    }
}
