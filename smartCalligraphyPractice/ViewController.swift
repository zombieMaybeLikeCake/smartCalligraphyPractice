//
//  ViewController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/10/23.
//

import UIKit
class ViewController: UIViewController, UITextFieldDelegate{
    let nextButton = UIButton()
    let checkButton = UIButton()
    let showindexButton = UIButton()
    var sampleTextField : UITextField!
    var nowIndextext: UILabel!
    @IBOutlet var canvasView: UIView! // The drawing canvas
    @IBOutlet var showWordImageView: UIImageView!
    var image:UIImage?
    var strokeColor: UIColor = .black // Set your desired stroke color here
    var lineWidth: CGFloat = 4.0 // Set your desired line width
    var viewsize:CGSize!
    var drawingPaths: [UIBezierPath] = []
    var multipledrawingPaths:[[UIBezierPath]]=[]
    var IP:String = "http://192.168.0.103:8080"
    var imagenum:Int = 290
    var hopenum:Int=0
    var test:String!
    var viewheight:CGFloat = 0.0
    var viewwidth:CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullScreenSize = UIScreen.main.bounds.size
        viewsize=CGSize(width: fullScreenSize.width, height: fullScreenSize.height)
        let canvas = UIView(frame: CGRect(x: 0, y:0 , width: fullScreenSize.width, height: fullScreenSize.height))
        canvas.backgroundColor = UIColor.white // 设置背景颜色
       // 添加到当前视图控制器的视图上
        let imageviewheight=(fullScreenSize.height)
        self.viewheight=fullScreenSize.height
        self.viewwidth=fullScreenSize.width
        showWordImageView=UIImageView(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: imageviewheight))
        // 文字顏色
        canvasView = canvas
       
        drawWordForm(screenwidth: fullScreenSize.width,screenheight: fullScreenSize.height)
        self.view.addSubview(canvas)
    }
    func setuptextfield(){
           sampleTextField.placeholder = "Enter text here"
           sampleTextField.font = UIFont.systemFont(ofSize: 15)
           sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
           sampleTextField.autocorrectionType = UITextAutocorrectionType.no
           sampleTextField.keyboardType = UIKeyboardType.default
           sampleTextField.returnKeyType = UIReturnKeyType.done
           sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
           sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    }
    
    func textField(_ textField: UITextField) -> Int {
        let strnum = textField.text
        let num = Int(strnum!)
        hopenum=num!
        return num!
    }
    @objc func dismissKeyboard() {
            self.view.endEditing(true)
        }
        
        // 當按下右下角的return鍵時觸發
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // 關閉鍵盤
            return true
    }
    func setupButton(){
        view.addSubview(nextButton)
        nextButton.configuration = .filled()
        nextButton.configuration?.baseBackgroundColor = .systemBlue
        nextButton.configuration?.title = "Next"
        nextButton.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([nextButton.centerXAnchor.constraint(equalTo: view.rightAnchor, constant: -60),nextButton.centerYAnchor.constraint(equalTo:view.topAnchor, constant: 60),nextButton.widthAnchor.constraint(equalToConstant: 100),nextButton.heightAnchor.constraint(equalToConstant: 25)])
        
    }
    func setcheckButton(){
        view.addSubview(checkButton)
        checkButton.configuration = .filled()
        checkButton.configuration?.baseBackgroundColor = .systemBlue
        checkButton.configuration?.title = "send"
        checkButton.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([checkButton.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: 60),checkButton.centerYAnchor.constraint(equalTo:view.topAnchor, constant: 60),checkButton.widthAnchor.constraint(equalToConstant: 100),checkButton.heightAnchor.constraint(equalToConstant: 25)])
    }
    func setshowkButton(){
        view.addSubview(showindexButton)
        showindexButton.configuration = .filled()
        showindexButton.configuration?.baseBackgroundColor = .systemBlue
        showindexButton.configuration?.title = "0"
        showindexButton.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([showindexButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),showindexButton.centerYAnchor.constraint(equalTo:view.topAnchor, constant: 60),showindexButton.widthAnchor.constraint(equalToConstant: 100),showindexButton.heightAnchor.constraint(equalToConstant: 25)])
    }
    // Handle touches when the user starts drawing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPath = UIBezierPath()
            currentPath.lineWidth = lineWidth
            currentPath.lineCapStyle = .round
            currentPath.lineJoinStyle = .round
            let location = touch.location(in: canvasView)
            currentPath.move(to: location)
            drawingPaths.append(currentPath)
            drawOnCanvas()
        }
    }

    // Handle touches as the user continues drawing
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let path = drawingPaths.last {
            let currentLocation = touch.location(in: canvasView)
            path.addLine(to: currentLocation)
            path.move(to: currentLocation)
//            let currentPath = UIBezierPath()
//            currentPath.lineWidth = lineWidth
//            currentPath.lineCapStyle = .round
//            currentPath.lineJoinStyle = .round
            drawOnCanvas()
            
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let path = drawingPaths.last {
            let currentLocation = touch.location(in: canvasView)
            path.addLine(to: currentLocation)
            saveLastStrokeAsImage()
        }
    }
    // Draw the current path on the canvas
    func drawOnCanvas() {
        guard let path = drawingPaths.last else { return }
        let strokeLayer = CAShapeLayer()
        strokeLayer.path = path.cgPath
        strokeLayer.strokeColor = strokeColor.cgColor
        strokeLayer.lineWidth = path.lineWidth
        // Convert CGLineCap to String
        switch path.lineCapStyle {
        case .butt:
            strokeLayer.lineCap = .butt
        case .round:
            strokeLayer.lineCap = .round
        case .square:
            strokeLayer.lineCap = .square
        @unknown default:
            strokeLayer.lineCap = .butt // Default to .butt for unknown cases
        }
        // Convert CGLineJoin to String
        switch path.lineJoinStyle {
        case .miter:
            strokeLayer.lineJoin = .miter
        case .round:
            strokeLayer.lineJoin = .round
        case .bevel:
            strokeLayer.lineJoin = .bevel
        @unknown default:
            strokeLayer.lineJoin = .miter // Default to .miter for unknown cases
        }
        canvasView.layer.addSublayer(strokeLayer)
    }
    func drawWordForm(screenwidth:CGFloat,screenheight:CGFloat){
        var wordlength:CGFloat = 75
        var bottomlength:CGFloat = 20.0
        var rightlength:CGFloat = 10.0
        var rowwordnum=8
        var colwordnum=12
        var formLineWidth:CGFloat = 1
        var toplength:CGFloat = (screenheight-CGFloat(colwordnum)*wordlength)/2
        var leftlength:CGFloat = (screenwidth-CGFloat(rowwordnum)*wordlength)/2
        let formLayer = CAShapeLayer()
        let dasfLineLayer = CAShapeLayer()
        formLayer.lineCap = .round
        formLayer.lineJoin = .round
        formLayer.lineWidth = formLineWidth
        formLayer.strokeColor = UIColor.systemBlue.cgColor
        let formPath = UIBezierPath()
        formPath.lineCapStyle = .round
        formPath.lineJoinStyle = .round
        
        for index in 0...colwordnum{
            formPath.move(to: CGPoint(x:leftlength, y:toplength+wordlength*CGFloat(index)))
            formPath.addLine(to: CGPoint(x:screenwidth-leftlength,y:toplength+wordlength*CGFloat(index)))
            bottomlength = toplength+wordlength*CGFloat(index)
        }
        for index in 0...rowwordnum{
            formPath.move(to: CGPoint(x:leftlength+wordlength*CGFloat(index), y:toplength))
            formPath.addLine(to: CGPoint(x:leftlength+wordlength*CGFloat(index),y:bottomlength))
        }
        
        formLayer.path = formPath.cgPath
        canvasView.layer.addSublayer(formLayer)
        for index in 1...rowwordnum{
            let image = UIImage(named: String(index))
            let imageLayer = CALayer()
            imageLayer.backgroundColor = UIColor.clear.cgColor
            imageLayer.bounds = CGRect(x:leftlength+wordlength*(CGFloat(index-1)+0.5),y:toplength+wordlength/2,width:wordlength-5, height:wordlength-5)
            imageLayer.position = CGPoint(x:leftlength+wordlength*(CGFloat(index-1)+0.5),y:toplength+wordlength/2)
            imageLayer.contents =  image?.cgImage
            canvasView.layer.addSublayer(imageLayer)
        }
        
        let dashLineLayer = CAShapeLayer()
        dashLineLayer.strokeColor = UIColor.systemBlue.cgColor
        dashLineLayer.lineCap = .round
        dashLineLayer.lineJoin = .round
        dashLineLayer.lineWidth = 0.5
        let dashPath = UIBezierPath()
        for index in 1...colwordnum*3{
            dashPath.move(to: CGPoint(x:leftlength, y:toplength+wordlength*CGFloat(index)/3))
            dashPath.addLine(to: CGPoint(x:screenwidth-leftlength,y:toplength+wordlength*CGFloat(index)/3))
            bottomlength = toplength+wordlength*CGFloat(index)/3
        }
        for index in 1...rowwordnum*3{
            dashPath.move(to: CGPoint(x:leftlength+wordlength*CGFloat(index)/3, y:toplength))
            dashPath.addLine(to: CGPoint(x:leftlength+wordlength*CGFloat(index)/3,y:bottomlength))
        }
//        dashPath.setLineDash(dashConfig, count:dashConfig.count, phase: 0)
        let dashpattern:[NSNumber] = [2,2]
        dashLineLayer.lineDashPattern=dashpattern
        dashLineLayer.path=dashPath.cgPath
        canvasView.layer.addSublayer(dashLineLayer)
    }
    // Save the last stroke as an independent image
    func saveLastStrokeAsImage() {
        let fmt = UIGraphicsImageRendererFormat()
               fmt.scale = 1
               fmt.opaque = true
        let rndr = UIGraphicsImageRenderer(size:self.viewsize, format: fmt)
               let newImg = rndr.image { ctx in
                   ctx.cgContext.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
                   ctx.cgContext.addRect(CGRect(origin: .zero, size: self.viewsize))
                   ctx.cgContext.drawPath(using: .fill)
                   let bez = drawingPaths.last
                   ctx.cgContext.setFillColor(UIColor.clear.cgColor)
                   ctx.cgContext.setStrokeColor(strokeColor.cgColor)
                   ctx.cgContext.setLineWidth(lineWidth)
                   ctx.cgContext.setLineJoin(.round)
                   ctx.cgContext.setLineCap(.round)
                   ctx.cgContext.addPath(bez!.cgPath)
                   ctx.cgContext.drawPath(using: .stroke)
               }
        let pngData = newImg.pngData()
        let stringData=pngData!.base64EncodedString()
        guard let url : URL=URL(string:IP)
        else{
            print("error")
            return
        }
        let paramStr:String = "image=\(String(describing: stringData))"
        let parmData:Data=paramStr.data(using: .utf8) ?? Data()
        var urlRequest : URLRequest = URLRequest(url: url)
        urlRequest.httpMethod="POST"
        urlRequest.httpBody=parmData
        urlRequest.setValue("application/x-www-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data,response,error) in
            guard let data = data, error == nil else {
                           print("出现错误：\(error?.localizedDescription ?? "未知错误")")
                           return
                       }
                       
            if let image = UIImage(data: data) {
                       // 在主线程中更新 UI
                       DispatchQueue.main.async {
                           let imageLayer = CALayer()
                           imageLayer.backgroundColor = UIColor.clear.cgColor
                           imageLayer.bounds = CGRect(x:0, y: 0 , width: self.viewwidth, height:self.viewheight)
                           imageLayer.position = CGPoint(x:self.viewwidth/2,y:self.viewheight/2)
                           imageLayer.contents =  image.cgImage
                           self.canvasView.layer.addSublayer(imageLayer)
                       }
                   } else {
                           print(data)
                           print("无法将接收到的数据转换为图像")
                       }
            
        }).resume()
//        UIImageWriteToSavedPhotosAlbum(newImg, nil, nil, nil)
        
    }
     func getImage(){
        let imggetone:String = IP+"/?filename="
        let imggettwo:String = ".png&data=Hello%20World"
        let imageurl = imggetone+String(imagenum)+imggettwo
        guard let url : URL=URL(string:imageurl)
        else{
            print("get image error")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data{
                self.image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.showWordImageView.image=self.image
                }
                    
                
            }
        }
        task.resume()
        imagenum+=1
        showindexButton.configuration?.title = String(imagenum)
    }
    func jumpImage(){
//       imagenum = textField(sampleTextField)
       imagenum-=1
        showindexButton.configuration?.title = String(imagenum)
       let imggetone:String = IP+"/?filename="
       let imggettwo:String = ".png&data=Hello%20World"
       let imageurl = imggetone+String(imagenum)+imggettwo
       guard let url : URL=URL(string:imageurl)
       else{
           print("get image error")
           return
       }
       let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
           if let data = data{
               self.image = UIImage(data: data)
               DispatchQueue.main.async {
                   self.showWordImageView.image=self.image
               }
                   
               
           }
       }
       task.resume()
   }
    @objc func nextaction(){
        getImage()
        drawingPaths.removeAll() // 移除所有筆劃
        canvasView.layer.sublayers = nil // 移除所有已繪製的筆劃圖層
    }
    @objc func checkaction(){
        jumpImage()
        drawingPaths.removeAll() // 移除所有筆劃
        canvasView.layer.sublayers = nil // 移除所有已繪製的筆劃圖層
    }
    // Action to save the last stroke as an image
    
}

