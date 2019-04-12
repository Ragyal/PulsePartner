//
//  RegisterViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 12.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var maleOneCheckbox: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        
        maleOneCheckbox.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
        maleOneCheckbox.setImage(UIImage(named: "Checkmark"), for: .selected)
        // Do any additional setup after loading the view.
    }
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
            
        }
    }
}
