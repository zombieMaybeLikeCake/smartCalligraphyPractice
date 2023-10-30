//
//  tabController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/10/30.
//

import UIKit

class tabController: UITabBarController{
    var Ismainview:Bool=true
    @objc func changtosetView(_ sender: UIBarButtonItem){
        Ismainview=false
        let setview = self.createNav(vc: setViewController())
        self.setViewControllers([setview], animated: true)
        
    }
    @objc func changtosetwordView(_ sender: UIBarButtonItem){
        Ismainview=false
        let setwordview = self.createNav(vc: setwordViewController())
        self.setViewControllers([setwordview], animated: true)
        
    }
    @objc func changtoMainView(_ sender: UIBarButtonItem){
        Ismainview=true
        let mainview = self.createNav(vc: ViewController())
        self.setViewControllers([mainview], animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabs()
    }
    private func setupTabs(){
        let mainview = self.createNav(vc: ViewController())
        self.setViewControllers([mainview], animated: true)
        
    }
    private func createNav(vc:UIViewController)->UINavigationController{
        
        let nav = UINavigationController(rootViewController: vc)
        let setImage = UIImage(systemName: "gearshape")
        let setWordImage = UIImage(systemName: "textformat")
        let backImage = UIImage(systemName:"arrow.uturn.backward")
        if Ismainview {
            nav.viewControllers.first?.navigationItem.rightBarButtonItem = UIBarButtonItem(image:setImage, style: .plain, target: self, action: #selector(changtosetwordView(_:)))
//            nav.viewControllers.first?.navigationItem.leftBarButtonItem = UIBarButtonItem(image:setWordImage, style: .plain, target:self, action:#selector(changtosetView(_:)))
        }
        else{
            nav.viewControllers.first?.navigationItem.rightBarButtonItem = UIBarButtonItem(image:backImage, style: .plain, target: self, action: #selector(changtoMainView(_:)))
        }
        
        
        return nav
    }
    

}
