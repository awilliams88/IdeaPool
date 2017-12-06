//
//  IdeaEditorVC.swift
//  Idea Pool
//
//  Created by Arpit Williams on 06/12/17.
//

import UIKit

class IdeaEditorVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var impact: UILabel!
    @IBOutlet weak var ease: UILabel!
    @IBOutlet weak var confidence: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Properties
    var idea: Idea?

    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let idea = idea {
            updateUI(for: idea)
        }
    }
    
    // Update UI
    func updateUI(for idea: Idea) {
        textView.text = idea.content
        impact.text = "\(idea.impact)"
        ease.text = "\(idea.ease)"
        confidence.text = "\(idea.confidence)"
    }
    
    // Tap Gesture Selector
    @IBAction func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        picker.isHidden = false
        picker.tag = sender.view?.tag ?? 1
        
        // Select current value in picker
        switch picker.tag {
        case 1:
            picker.selectRow(Int(impact.text ?? "1")! - 1, inComponent: 0, animated: true)
        case 2:
            picker.selectRow(Int(ease.text ?? "1")! - 1, inComponent: 0, animated: true)
        case 3:
            picker.selectRow(Int(confidence.text ?? "1")! - 1, inComponent: 0, animated: true)
        default:
            break
        }
    }
    
    // Save Idea
    @IBAction func saveBtnPrsd(_ sender: Any) {
        if !textView.text.isEmpty {
            spinner.startAnimating()
            
            if let idea = idea { // Update existing idea
                IdeaManager.shared.update(idea,
                                          with: textView.text,
                                          confidence: Int(confidence.text ?? "1")!,
                                          ease: Int(ease.text ?? "1")!,
                                          impact: Int(impact.text ?? "1")!,
                                          completion: { (result) in self.handle(result: result) })
            }
            else { // Create new idea
                IdeaManager.shared.create(with: textView.text,
                                          confidence: Int(confidence.text ?? "0")!,
                                          ease: Int(ease.text ?? "0")!,
                                          impact: Int(impact.text ?? "0")!,
                                          completion: { (result) in self.handle(result: result) })
            }
        }
    }
    
    // Handles result from completion handlers
    func handle(result: Result<Any>) {
        do {
            if let idea = try result.unwrap() as? Idea {
                self.idea = idea
                DispatchQueue.main.async { self.performSegue(withIdentifier: Constants.Segue.unwindToIdeasVC, sender: self) }
            }
            
        }
        catch ResponseError.InvalidResponseCode(let reason) {
            if let reason =  reason as? [String: String] {
                let okAction = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                Utility.showAlert(for: self, title: reason.keys.first ?? "", message: reason.values.first ?? "", actions: [okAction])
            }
        }
        catch {
            print(error)
        }
        // Update UI
        DispatchQueue.main.async { self.spinner.stopAnimating() }
    }
    
    // Cancel
    @IBAction func cancelBtnPrsd(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: Picker View Datasource - Delegate - Text View Delegate
extension IdeaEditorVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch picker.tag {
        case 1:
            impact.text = "\(row+1)"
        case 2:
            ease.text = "\(row+1)"
        case 3:
            confidence.text = "\(row+1)"
        default:
            break
        }
        picker.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
