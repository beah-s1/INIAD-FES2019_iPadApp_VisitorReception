//
//  ReceptionViewController.swift
//  INIADFES-2019-Reception
//
//  Created by Kentaro on 2019/11/01.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ReceptionWaitingViewController:UIViewController{
    @IBOutlet weak var LogoImageView: UIImageView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startButtonOnPress(_ sender: UIButton) {
        UIView.animate(withDuration: 1.0, animations: {
            self.LogoImageView.center.y -= 30
            self.LogoImageView.alpha = 0
            self.welcomeText.center.y -= 30
            self.welcomeText.alpha = 0
            self.startButton.center.y -= 30
            self.startButton.alpha = 0
        }, completion: {action in
            print("Complete")
            
            let view = self.storyboard!.instantiateViewController(withIdentifier: "ChooseIssueCodeOrReadCodeView") as! ChooseIssueCodeOrReadCodeViewController
            view.modalPresentationStyle = .fullScreen
            
            self.present(view, animated: false, completion: {
                self.LogoImageView.center.y += 30
                self.LogoImageView.alpha = 1.0
                self.welcomeText.center.y += 30
                self.welcomeText.alpha = 1.0
                self.startButton.center.y += 30
                self.startButton.alpha = 1.0
            })
        })
    }
    
}

class ChooseIssueCodeOrReadCodeViewController:UIViewController{
    @IBOutlet weak var InstructionLabel: UILabel!
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    
    override func viewDidLoad() {
        InstructionLabel.center.y -= 30
        InstructionLabel.alpha = 0
        
        YesButton.center.y -= 30
        YesButton.alpha = 0
        
        NoButton.center.y -= 30
        NoButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, animations: {
            self.InstructionLabel.center.y += 30
            self.InstructionLabel.alpha = 1.0
            
            self.YesButton.center.y += 30
            self.YesButton.alpha = 1.0
            
            self.NoButton.center.y += 30
            self.NoButton.alpha = 1.0
        })
    }
    
    @IBAction func pressButton(_ sender: UIButton) {
        switch sender.restorationIdentifier{
        case "Yes":
            UIView.animate(withDuration: 1.0, animations: {
                self.InstructionLabel.center.y -= 30
                self.InstructionLabel.alpha = 0.0
                
                self.NoButton.center.y -= 30
                self.NoButton.alpha = 0.0
            })
            
            UIView.animate(withDuration: 1.0, delay: 0.3, animations: {
                
                self.YesButton.center.y -= 30
                self.YesButton.alpha = 0.0
            }, completion: {_ in
                print("complete")
            })
            break
        case "No":
            UIView.animate(withDuration: 1.0, animations: {
                self.InstructionLabel.center.y -= 30
                self.InstructionLabel.alpha = 0.0
                
                self.YesButton.center.y -= 30
                self.YesButton.alpha = 0.0
            })
            
            UIView.animate(withDuration: 1.0, delay: 0.3, animations: {
                self.NoButton.center.y -= 30
                self.NoButton.alpha = 0.0
            }, completion: {_ in
                let view = self.storyboard!.instantiateViewController(withIdentifier: "VisitorAttributeForm") as! VisitorAttributeFormViewController
                view.modalPresentationStyle = .fullScreen
                self.present(view, animated: false, completion: nil)
            })
            break
        default:break
        }
    }
    
}

class VisitorAttributeFormViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    @IBOutlet weak var agePicker: UIPickerView!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var jobPicker: UIPickerView!
    @IBOutlet weak var nopPicker: UIPickerView!
    
    var availableAge = [[String:String]]()
    var availableGender = [[String:String]]()
    var availableJob = [[String:String]]()
    var availableNumberOfPeople = [[String:String]]()
    
    var selectedAge = [String:String]()
    var selectedGender = [String:String]()
    var selectedJob = [String:String]()
    var selectedNumberOfPeople = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let attributeBaseJsonFilePath = Bundle.main.path(forResource: "VisitorAttributeBase", ofType: "json") else{
            fatalError("COULD NOT FIND ATTRIBUTE BASE JSON FILE")
        }
        
        guard let attributeBaseJsonString = try? String.init(contentsOfFile: attributeBaseJsonFilePath) else{
            fatalError("COULD NOT PARSE ATTRIBUTE BASE JSON FILE")
        }
        
        let attributeBaseJsonObject = JSON.init(parseJSON: attributeBaseJsonString)
        
        for object in attributeBaseJsonObject["gender"]{
            availableGender.append(["dataString":object.1["dataString"].stringValue,"displayString":object.1["displayString"].stringValue])
        }
        
        for object in attributeBaseJsonObject["age"]{
            availableAge.append(["dataString":object.1["dataString"].stringValue,"displayString":object.1["displayString"].stringValue])
        }
        
        for object in attributeBaseJsonObject["job"]{
            availableJob.append(["dataString":object.1["dataString"].stringValue,"displayString":object.1["displayString"].stringValue])
        }
        
        for object in attributeBaseJsonObject["number_of_people"]{
            availableNumberOfPeople.append(["dataString":object.1["dataString"].stringValue,"displayString":object.1["displayString"].stringValue])
        }
        
        self.agePicker.delegate = self
        self.agePicker.dataSource = self
        
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
        
        self.jobPicker.delegate = self
        self.jobPicker.dataSource = self
        
        self.nopPicker.delegate = self
        self.nopPicker.dataSource = self
        
        self.selectedAge = self.availableAge[0]
        self.selectedGender = self.availableGender[0]
        self.selectedJob = self.availableJob[0]
        self.selectedNumberOfPeople = self.availableNumberOfPeople[0]
    }
    
    @IBAction func submit(_ sender: Any) {
        print(self.selectedAge)
        print(self.selectedJob)
        print(self.selectedGender)
        print(self.selectedNumberOfPeople)
        
        //TODO:QRコードの取得、印字
        let config = Configuration()

        var apiKey = ""
        var user_id = ""
        
        DispatchQueue.main.async{
            var semaphore = DispatchSemaphore(value: 0)
            var queue = DispatchQueue.global(qos: .utility)
            Alamofire.request("\(config.value(forKey: "base_url"))/api/v1/user/new", method: .post, parameters: ["device_type":"qr"]).responseJSON(queue: queue, completionHandler: {response in
                guard let value = response.result.value else{
                    let alert = UIAlertController(title: "Error", message: "通信に失敗しました", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "リトライ", style: .destructive, handler: {action in
                        self.submit(sender)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let createUserResponseJsonObject = JSON(value)
                apiKey = createUserResponseJsonObject["secret"].stringValue
                
                semaphore.signal()
            })
            
            semaphore.wait()
            
            semaphore = DispatchSemaphore(value: 0)
            queue = DispatchQueue.global(qos: .utility)
            
            Alamofire.request("\(config.value(forKey: "base_url"))/api/v1/visitor/attributes", method: .post, parameters: [
                "gender":self.selectedGender["dataString"]!,
                "age":self.selectedAge["dataString"]!,
                "job":self.selectedJob["dataString"]!,
                "number_of_people":self.selectedJob["dataString"]!
            ], headers: ["Authorization":"Bearer \(apiKey)"]).responseJSON(queue: queue, completionHandler: {response in
                guard let value = response.result.value else{
                    let alert = UIAlertController(title: "Error", message: "通信に失敗しました", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "リトライ", style: .destructive, handler: {action in
                        self.submit(sender)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let responseJsonObject = JSON(value)
                user_id = responseJsonObject["visitor_code"].stringValue
                
                semaphore.signal()
            })
            
            semaphore.wait()
            
            self.printQrCode(user_id: user_id)
            
            let view = self.storyboard!.instantiateViewController(withIdentifier: "VisitorAttributeRegisterCompleteView") as! VisitorAttributeRegisterCompleteViewController
            
            self.present(view, animated: true, completion: nil)
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.restorationIdentifier{
        case "age":
            return self.availableAge.count
        case "gender":
            return self.availableGender.count
        case "job":
            return self.availableJob.count
        case "numberOfPeople":
            return self.availableNumberOfPeople.count
        default:break
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.restorationIdentifier{
        case "age":
            return self.availableAge[row]["displayString"]
        case "gender":
            return self.availableGender[row]["displayString"]
        case "job":
            return self.availableJob[row]["displayString"]
        case "numberOfPeople":
            return self.availableNumberOfPeople[row]["displayString"]
        default:return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.restorationIdentifier{
        case "age":
            self.selectedAge = self.availableAge[row]
            break
        case "gender":
            self.selectedGender = self.availableGender[row]
            break
        case "job":
            self.selectedJob = self.availableJob[row]
            break
        case "numberOfPeople":
            self.selectedNumberOfPeople = self.availableNumberOfPeople[row]
            break
        default:break
        }
    }
    
    func printQrCode(user_id:String){
        let ap = UIApplication.shared.delegate as! AppDelegate
        
        do{
            let builder = StarIoExt.createCommandBuilder(.starPRNT)!
            //builder.beginDocument()
            builder.appendQrCodeData("https://app.iniadfes.com/visitor?user_id=\(user_id)".data(using: .utf8)!, model: .no2, level: .L, cell: 10)
            builder.appendLineFeed()
            //builder.appendInvert(true)
            builder.appendData(withLineFeed: "QRコードを受付で提示してください".data(using: .utf8))
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日"
            builder.appendData(withLineFeed: "来場日：\(formatter.string(from: Date()))".data(using: .utf8))
            builder.appendData(withLineFeed: "ーーーーーーーーーーーーーーーー".data(using: .utf8))
            builder.appendData(withLineFeed: "「INIAD-FES 公式アプリ」配信中！".data(using: .utf8))
            builder.appendData(withLineFeed: "見やすい館内マップも！".data(using: .utf8))
            builder.appendData(withLineFeed: "AppStoreで「INIAD-FES」と検索！".data(using: .utf8))
            builder.appendData(withLineFeed: "※iOS版のみのご提供となります".data(using: .utf8))
            builder.appendData(withLineFeed: "ーーーーーーーーーーーーーーーー".data(using: .utf8))
            
            builder.appendCutPaper(.fullCutWithFeed)
            //builder.endDocument()
            
            var command = [UInt8]()
            let command_data = NSData.init(bytes: builder.commands.mutableBytes, length: builder.commands.length)
            command = [UInt8](Data(command_data))
            
            print(command)
            
            var total: UInt32 = 0
            while total < UInt32(command.count) {
                var written: UInt32 = 0
                // 印刷データ送信
                try! ap.manager.port.write(writeBuffer: command, offset: total, size: UInt32(command.count) - total, numberOfBytesWritten: &written)
                total += written
            }
        }catch{
            let alert = UIAlertController(title: "Error", message: "QRコードの印字に失敗しました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "リトライ", style: .destructive, handler: {action in
                self.printQrCode(user_id: user_id)
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }

    }
}

class VisitorAttributeRegisterCompleteViewController:UIViewController{
    @IBOutlet weak var completeMessage1: UILabel!
    @IBOutlet weak var completeMessage2: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBAction func finish(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.completeMessage1.alpha = 0.0
            self.completeMessage2.alpha = 0.0
            self.completeButton.alpha = 0.0
        },completion: {_ in
            //guard let waitingView = self.presentingViewController?.presentingViewController?.presentingViewController as? ReceptionWaitingViewController else{
            //    return
            //}

            
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
        
    }
    
}
