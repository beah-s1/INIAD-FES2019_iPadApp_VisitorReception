//
//  QRCodeMigrationViewController.swift
//  INIADFES-2019-Reception
//
//  Created by Kentaro on 2019/11/04.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainAccess
import AVFoundation

class QRDigitalToPaperMigrationViewController:UIViewController,AVCaptureMetadataOutputObjectsDelegate{
    var session:AVCaptureSession!
    let ap = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var qrCodeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceDiscover = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
        self.session = AVCaptureSession.init()
        
        let devices = deviceDiscover.devices
        if let cameraDevice = devices.first{
            do{
                //カメラ入力設定
                let deviceInput = try AVCaptureDeviceInput(device: cameraDevice)
                
                if !self.session.canAddInput(deviceInput){
                }
                self.session.addInput(deviceInput)
                
                //ディスプレイ設定
                let output = AVCaptureMetadataOutput()
                if self.session.canAddOutput(output){
                    self.session.addOutput(output)
                }
                
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.qr]
                
                
                self.qrCodeView.clipsToBounds = true
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                previewLayer.frame = self.qrCodeView.frame
                previewLayer.videoGravity = .resizeAspectFill
                
                self.qrCodeView.layer.addSublayer(previewLayer)
                
                self.session.startRunning()
            }catch{
                
            }
            
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject]{
            if metadata.type != .qr {continue}
            if metadata.stringValue == nil {continue}
            
            guard let url = URL(string: metadata.stringValue!) else{
                continue
            }
            
            if url.host != "app.iniadfes.com" || url.path != "/visitor"{
                return
            }
            
            guard let userId = url.queryParams()["user_id"] else{
                return
            }
            
            self.session.stopRunning()
            printQrCode(user_id: userId)
            
            let alert = UIAlertController(title: "Message", message: "QRコードの移行が完了しました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.session.startRunning()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func printQrCode(user_id:String){
        
        do{
            let builder = StarIoExt.createCommandBuilder(.starPRNT)!
            //builder.beginDocument()
            builder.appendQrCodeData("https://app.iniadfes.com/visitor?user_id=\(user_id)".data(using: .utf8)!, model: .no2, level: .L, cell: 10)
            builder.appendLineFeed()
            //builder.appendInvert(true)
            
            builder.appendData(withLineFeed: "※再発行".data(using: .shiftJIS))
            builder.appendData(withLineFeed: "QRコードを受付で提示してください".data(using: .shiftJIS))
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日"
            builder.appendData(withLineFeed: "来場日：\(formatter.string(from: Date()))".data(using: .shiftJIS))
            builder.appendData(withLineFeed: "ーーーーーーーーーーーーーーーー".data(using: .shiftJIS))
            builder.appendData(withLineFeed: "お帰りの際、アンケートにご協力をお願いいたします".data(using: .shiftJIS))
            builder.appendData(withLineFeed: "ーーーーーーーーーーーーーーーー".data(using: .shiftJIS))
            
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
