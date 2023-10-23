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
    var lineWidth: CGFloat = 10.0 // Set your desired line width
    var viewsize:CGSize!
    var drawingPaths: [UIBezierPath] = []
    var multipledrawingPaths:[[UIBezierPath]]=[]
    var IP:String = "http://192.168.0.103:8080"
    var imagenum:Int = 290
    var hopenum:Int=0
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let fullScreenSize = UIScreen.main.bounds.size
        viewsize=CGSize(width: fullScreenSize.width, height: fullScreenSize.height/2)
        let canvas = UIView(frame: CGRect(x: 0, y: fullScreenSize.height/2, width: fullScreenSize.width, height: fullScreenSize.height/2))
        canvas.backgroundColor = UIColor.white // 设置背景颜色
        self.view.addSubview(canvas) // 添加到当前视图控制器的视图上
        let imageviewheight=(fullScreenSize.height/2)
        showWordImageView=UIImageView(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: imageviewheight))
        self.view.addSubview(showWordImageView)
//        sampleTextField=UITextField(frame: CGRect(x: 10, y: 10, width: 300, height: 40))
//        setuptextfield()
//        sampleTextField.delegate = self
//        self.view.addSubview(sampleTextField)
        setupButton()
        // 设置 canvasView 为创建的 UIView
        getImage()
        nextButton.addTarget(self, action: #selector(nextaction), for: .touchDown)
        setcheckButton()
        checkButton.addTarget(self, action: #selector(checkaction), for: .touchDown)
        setshowkButton()
        // 文字顏色
        canvasView = canvas
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
//            self.view.addGestureRecognizer(tap)
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
                   ctx.cgContext.setLineWidth(4)
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
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data,response,error)
            in guard data != nil
            else{
                print("error data")
                return}

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

