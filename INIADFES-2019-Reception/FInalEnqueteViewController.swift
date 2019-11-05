//
//  FInalEnqueteViewController.swift
//  INIADFES-2019-Reception
//
//  Created by Kentaro on 2019/11/03.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import KeychainAccess
import AVFoundation
import WebKit

class FinalEnqueteQrCodeReaderVuewController:UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    var session:AVCaptureSession!
    @IBOutlet weak var qrCodeView: UIView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.session = AVCaptureSession()
        let deviceDiscover = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
        
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
            finalEnqueteRequest(userId: userId)
        }
    }
    
    func finalEnqueteRequest(userId:String){
        let view = storyboard!.instantiateViewController(withIdentifier: "FinalEnqueteForm") as! FinalEnqueteFormViewController
        view.userId = userId
        
        self.present(view, animated: true, completion: {
            self.session.startRunning()
        })
    }
}

class FinalEnqueteFormViewController:UIViewController,WKNavigationDelegate, WKUIDelegate{
    @IBOutlet weak var webView: WKWebView!
    var userId = ""
    
    override func viewDidLoad(){
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        let config = Configuration()
        
        self.webView.load(URLRequest(url: URL(string: "\(config.value(forKey: "base_url"))/visitor/final-enquete?user_id=\(userId)")!))
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
