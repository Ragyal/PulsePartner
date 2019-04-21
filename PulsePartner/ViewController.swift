//
//  ViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 04.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func showController(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterPage1") as? RegisterViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
