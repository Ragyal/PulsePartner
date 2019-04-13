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
    @IBOutlet weak var femaleOneCheckbox: UIButton!
    @IBOutlet weak var maleSecondCheckbox: UIButton!
    @IBOutlet weak var femaleSecondCheckbox: UIButton!
    

    lazy var checkboxes = [maleOneCheckbox, femaleOneCheckbox, maleSecondCheckbox, femaleSecondCheckbox]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        
        //Checkbox Style
        for checkbox in checkboxes {
            checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
            checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
        }
        
        // Do any additional setup after loading the view.
    }
    
    //Checkbox function
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        
        switch sender.tag{
        case 1...2:
            if(sender.tag == 1){
                femaleOneCheckbox.isSelected = false
            }else{
                maleOneCheckbox.isSelected = false
            }
            break
        case 3...4:
            if(sender.tag == 3){
                femaleSecondCheckbox.isSelected = false
            }else{
                maleSecondCheckbox.isSelected = false
            }
            break
        default:
            break
        }
        sender.isSelected = !sender.isSelected
//        Animation for selection
//        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
//                sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        }) { (success) in
//            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
//                sender.isSelected = !sender.isSelected
//                sender.transform = .identity
//            }, completion: nil)
//
//        }
    }
}
