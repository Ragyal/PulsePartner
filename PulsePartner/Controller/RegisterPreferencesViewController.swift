//
//  RegisterPreferencesViewController.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 09.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit

class RegisterPreferencesViewController: UIViewController {

    @IBOutlet weak var maleOneCheckbox: UIButton!
    @IBOutlet weak var femaleOneCheckbox: UIButton!
    @IBOutlet weak var maleSecondCheckbox: UIButton!
    @IBOutlet weak var femaleSecondCheckbox: UIButton!

    lazy var checkboxes = [maleOneCheckbox, femaleOneCheckbox, maleSecondCheckbox, femaleSecondCheckbox]

    var registerData: UserRegisterData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for checkbox in checkboxes {
            checkbox!.setImage(UIImage(named: "Checkmarkempty"), for: .normal)
            checkbox!.setImage(UIImage(named: "Checkmark"), for: .selected)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    /**
     Function to check if the other radio button is already selected
     */
    @IBAction func onCheckboxClick(_ sender: UIButton) {

        switch sender.tag {
        case 1...2:
            if sender.tag == 1 {
                femaleOneCheckbox.isSelected = false
            } else {
                maleOneCheckbox.isSelected = false
            }
        case 3...4:
            if sender.tag == 3 {
                femaleSecondCheckbox.isSelected = false
            } else {
                maleSecondCheckbox.isSelected = false
            }
        default:
            break
        }
        //        sender.isSelected = !sender.isSelected
        //        Animation for selection
        UIView.animate(withDuration: 0.05, delay: 0.02, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { (_) in
            UIView.animate(withDuration: 0.05, delay: 0.02, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
        })
    }

    /**
     Function to change the displayed controller
     */
    @IBAction func changePage(_ sender: UIButton) {
        if !femaleOneCheckbox.isSelected && !maleOneCheckbox.isSelected ||
            !femaleSecondCheckbox.isSelected && !maleSecondCheckbox.isSelected {
            let alert = UIAlertController(title: "Error!",
                                          message: "Please select a gender",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            self.performSegue(withIdentifier: "SecondRegisterSegue", sender: self)
        }
    }
}
