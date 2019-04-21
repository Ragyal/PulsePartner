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
    @IBOutlet weak var fitnessLevelLab: UILabel!
    

    lazy var checkboxes = [maleOneCheckbox, femaleOneCheckbox, maleSecondCheckbox, femaleSecondCheckbox]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Checkbox Style
        if(self.restorationIdentifier! == "RegisterPage1"){
            for checkbox in checkboxes {
                checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
                checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
            }
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
    
    @IBAction func changePage(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            if(!femaleOneCheckbox.isSelected && !maleOneCheckbox.isSelected || !femaleSecondCheckbox.isSelected && !maleSecondCheckbox.isSelected){
                let alert = UIAlertController(title: "Error!", message: "Please select a gender", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }else{
                pushController(with: "RegisterPage2")
            }
            break
        case 2:
            pushController(with: "RegisterPage3")
            break
        case 3:
            pushController(with: "RegisterPage4")
        default:
            break
        }
        
    }
    
    func pushController(with identifier: String){
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: identifier) as? RegisterViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        //        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setFitnessLevel(_ sender: UISlider) {
        fitnessLevelLab.text = String(Int(sender.value))
    }
    
    
}
