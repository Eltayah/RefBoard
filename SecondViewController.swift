//
//  SecondViewController.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 14.02.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import UIKit
import RealmSwift
import Photos
import BSImagePicker
import SizeClasser
import DeviceKit
import GoogleMobileAds

class SecondViewController: UIViewController, GADBannerViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var upperBarView: UIView!
    @IBOutlet weak var hiddenUpperBarView: UIView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editingButton: UIButton!
    @IBOutlet weak var writingButton: UIButton!
    @IBOutlet weak var lookingButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    var SelectedAssets = [PHAsset]()
    var PhotoArray = [UIImage]()
    var imageViewArray = [UIImageView]()
    var imageItems: Results<Item>?
    var initialCenter = CGPoint()
    var labelArray = [UILabel]()
    var noteArray = [String]()
    var locationOfLongTap = CGPoint()
    var realRotationDegrees = CGFloat()
    var locationOfPinchTap = CGPoint()
    var photoBool = false
    var noteItems: Results<Note>?
    var locationX = CGFloat()
    var locationY = CGFloat()
    var selectedBoard: Board?
    var passedImageItems: Item?
    var bannerView: GADBannerView!
    var products: [SKProduct] = []
    var removeAdsIndex = 4
    
    let realm = try! Realm()
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
    }
    
    
    var interstitial: GADInterstitial!
    
    func loadInterstitial() {
        let request = GADRequest()
        
        
        request.scene = view.window?.windowScene
        
        interstitial.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadBannerAd() {
        let bannerWidth = view.frame.size.width
        
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)
        
        let request = GADRequest()
        request.scene = view.window?.windowScene
        bannerView.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Received Ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let removeAdsIndex = UserDefaults.standard.integer(forKey: "removeAdsIndex")
        
        if removeAdsIndex == 1 {
            self.removeAdsIndex = 1
        } else if removeAdsIndex == 2 {
            self.removeAdsIndex = 2
        } else if removeAdsIndex == 3 {
            self.removeAdsIndex = 3
        }
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-2344003946089796/9065298930"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        
        SubscribtionProducts.store.requestProducts { [weak self] success, products in
          guard let self = self else { return }
          guard success else {
            let alertController = UIAlertController(title: "Failed to load list of products",
                                                    message: "Check logs for details",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
          }
          self.products = products!
        }
        if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.monthlySub) || SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.monthly2Sub) || SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.yearlySub) {
            
            bannerView.removeFromSuperview()
          
            print("purchased")
            
        } else {
          
            bannerView.isHidden = false

        }
        
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//
//        addBannerViewToView(bannerView)
//
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        bannerView.delegate = self
        
        let modeBool = UserDefaults.standard.bool(forKey: "ModeBool")
        
        if modeBool == true {
            overrideUserInterfaceStyle = .light
            modeButton.selectedSegmentIndex = 0
        } else {
            overrideUserInterfaceStyle = .dark
            modeButton.selectedSegmentIndex = 1
        }
        
        writingButton.isHidden = true
        
        mainView.isUserInteractionEnabled = true
        
        mainView.clipsToBounds = true
        
        mainView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scalePiece(_:))))
        
        mainView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:))))
        
        mainView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPiece2(_:))))
        
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPiece(_:))))
        
        self.mainView.center.x = self.view.center.x
        self.mainView.center.y = self.view.center.y
        
        locationX = 0.0
        locationY = 0.0
        
        editingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        
        lookingButton.tintColor = UIColor.init(named: "FontColor")
        
        helpView.isHidden = true
        
        imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
        
        let allItems = selectedBoard?.items.count ?? 0
        
        if selectedBoard?.items.count != 0 {
            
            for n in 0...Int(allItems - 1) {
                let count = n
                
                
                if let photo = imageItems?[count] {
                    
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let documentsPath = paths[0]
                    let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(photo.imagePath!).path
                    
                    let newImage = UIImage(contentsOfFile: filePath)
                    
                    self.PhotoArray.append(newImage! as UIImage)
                    
                    let imageView = UIImageView(image: newImage)
                    
                    let x = photo.xValue.value
                    let y = photo.yValue.value
                    let width = Int(photo.imageWidth.value!)
                    let height = Int(photo.imageHeight.value!)
                    
                    let rotation = CGFloat(photo.imageRotation.value!)
                    
                    let radians = rotation / 180.0 * CGFloat.pi
                    
                    imageView.frame = CGRect(x: x!, y: y!, width: width, height: height)
                    
                    imageView.tag = photo.imageTag.value!
                    
                    mainView.addSubview(imageView)
                    
                    
                    let rotated = imageView.transform.rotated(by: radians)
                    
                    imageView.transform = rotated
                    
                    
                    self.imageViewArray.append(imageView as UIImageView)
                    
                    if lookingButton.tintColor == #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1) as UIColor? {
                        imageView.isUserInteractionEnabled = false
                    } else {
                        
                        imageView.isUserInteractionEnabled = true
                    }
                    
                    imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scalePiece2(_:))))
                    
                    
                    
                    if labelView.isHidden == false {
                        labelView.isHidden = true
                    }
                    
                    //imageView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(rotatePiece(_:))))
                    
                    imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPieceImage(_:))))
                    
                    imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(rec:))))
                    
                    
                }
                
            }
            
        }
        
        noteItems = selectedBoard?.notes.sorted(byKeyPath: "noteTag", ascending: true)
        
        let allNotes = selectedBoard?.notes.count ?? 0
        
        if selectedBoard?.notes.count != 0 {
            
            for n in 0...Int(allNotes - 1) {
                let count = n
                
                
                if let note = noteItems?[count] {
                    
                    let x = note.xValue.value
                    let y = note.yValue.value
                    
                    let textLabel = UILabel(frame: CGRect(x: x!, y: y!, width: 200, height: 21))
                    
                    textLabel.textAlignment = .center
                    
                    textLabel.text = note.noteText
                    
                    let font = 15
                    
                    textLabel.font = UIFont.systemFont(ofSize: CGFloat(font))
                    
                    textLabel.numberOfLines = 0
                    
                    textLabel.lineBreakMode = .byWordWrapping
                    
                    textLabel.sizeToFit()
                    
                    textLabel.tag = note.noteTag.value!
                    
                    textLabel.adjustsFontSizeToFitWidth = true
                    
                    textLabel.textColor = UIColor.init(named: "ViewFontColor")
                    
                    let scale = Float(note.noteFont.value!)
                    
                    textLabel.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
                    
                    self.noteArray.append(note.noteText!)
                    
                    self.mainView.addSubview(textLabel)
                    
                    self.labelArray.append(textLabel)
                    
                    if labelView.isHidden == false {
                        labelView.isHidden = true
                    }
                    
                    textLabel.isUserInteractionEnabled = true
                    
                    textLabel.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.scalePieceNote(_:))))
                    
                    
                    textLabel.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panPieceNote(_:))))
                    
                    textLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureNote(rec:))))
                    
                }
                
            }
            
        }
        
        self.view.layoutIfNeeded()
        
        backView.isUserInteractionEnabled = true
        
        let groupOfAllowedDevices: [Device] = [.iPadPro12Inch, .iPadPro12Inch2, .iPadPro12Inch3, .simulator(.iPadPro12Inch),.simulator(.iPadPro12Inch2),.simulator(.iPadPro12Inch3)]
        
        let device = Device.current
        
        if device.isOneOf(groupOfAllowedDevices) {
            
            helpButton.isHidden = false
            
        } else {
            helpButton.isHidden = true
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
//        if gestureRecognizer.view != self.mainView {
//           return false
//        }
//
        if gestureRecognizer.view != otherGestureRecognizer.view {
           return false
        }

        if gestureRecognizer is UILongPressGestureRecognizer ||
                 otherGestureRecognizer is UILongPressGestureRecognizer {
             return false
          }
        
          return true
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        guard let trait = SizeClasser(traitCollection: traitCollection ) else { return }
        
        if trait.contains([.iPadLandscape, .iPadSplitOneThird]) {
            
            print("landscape, 1/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            modeButton.isHidden = true
            editingButton.isHidden = true
            writingButton.isHidden = true
            lookingButton.isHidden = true
            deleteButton.isHidden = true
            
            lookingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
            
            editingButton.tintColor = UIColor.init(named: "FontColor")
            
            writingButton.tintColor = UIColor.init(named: "FontColor")
            
            imageViewArray.forEach { UIImageView in
                UIImageView.isUserInteractionEnabled = false
                //print(UIImageView)
            }
            
            labelArray.forEach { UILabel in
                UILabel.isUserInteractionEnabled = false
                //print(UIImageView)
            }
            
            
        } else if trait.contains([.iPadPortrait, .iPadSplitOneThird]) {
            
            print("portrait, 1/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            modeButton.isHidden = true
            editingButton.isHidden = true
            writingButton.isHidden = true
            lookingButton.isHidden = true
            deleteButton.isHidden = true
            
            lookingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
            
            editingButton.tintColor = UIColor.init(named: "FontColor")
            
            writingButton.tintColor = UIColor.init(named: "FontColor")
            
            imageViewArray.forEach { UIImageView in
                UIImageView.isUserInteractionEnabled = false
                
            }
            
            labelArray.forEach { UILabel in
                UILabel.isUserInteractionEnabled = false
                
            }
            
            
        } else if trait.contains([.iPadLandscape, .iPadSplitTwoThird]) {
            
            print("landscape, 2/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            writingButton.isHidden = true
            
            
        } else if trait.contains([.iPadPortrait, .iPadSplitTwoThird]) {
            
            print("portrait, 2/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            writingButton.isHidden = true
            
        } else if trait.contains([.iPadLandscape, .iPadSplitHalf]) {
            
            print("landscape, 1/2")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            writingButton.isHidden = true
            
        } else if trait.contains([.iPadLandscape]) {
            
            print("landscape, full, check")
            
            helpButton.isHidden = true
            writingButton.isHidden = true
            
        } else if trait.contains([.iPadPortrait]) {
            
            print("portrait, full")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            writingButton.isHidden = true
            
        }
        
        self.mainView.center.x = self.backView.center.x
        self.mainView.center.y = self.backView.center.y
        
        
        if locationX != 0.0 {
            self.mainView.center = CGPoint(x: CGFloat(locationX), y: CGFloat(locationY))
        }
        
        let groupOfAllowedDevices: [Device] = [.iPadPro12Inch, .iPadPro12Inch2, .iPadPro12Inch3, .simulator(.iPadPro12Inch),.simulator(.iPadPro12Inch2),.simulator(.iPadPro12Inch3)]
        
        let device = Device.current
        
        if device.isOneOf(groupOfAllowedDevices) {
            
            helpButton.isHidden = true
            
        } else {
            helpButton.isHidden = true
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    //MARK: - VIEW LOOKING MODE BUTTON
    
    
    @IBAction func lookingModeButton(_ sender: UIButton) {
        
        lookingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        
        editingButton.tintColor = UIColor.init(named: "FontColor")
        
        writingButton.tintColor = UIColor.init(named: "FontColor")
        
        imageViewArray.forEach { UIImageView in
            UIImageView.isUserInteractionEnabled = false
            
        }
        
        labelArray.forEach { UILabel in
            UILabel.isUserInteractionEnabled = false
            
        }
        
    }
    
    //MARK: - VIEW EDITING MODE BUTTON
    
    @IBAction func editingModeButton(_ sender: Any) {
        
        editingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        
        lookingButton.tintColor = UIColor.init(named: "FontColor")
        
        writingButton.tintColor = UIColor.init(named: "FontColor")
        
        imageViewArray.forEach { UIImageView in
            UIImageView.isUserInteractionEnabled = true
            
        }
        
        labelArray.forEach { UILabel in
            UILabel.isUserInteractionEnabled = true
            
        }
        
    }
    
    //MARK: - WRITING BUTTON
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func delayedAction() {
        writingButton.tintColor = UIColor.init(named: "FontColor")
        
        editingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        
        lookingButton.tintColor = UIColor.init(named: "FontColor")
    }
    
    @IBAction func writingButtonPressed(_ sender: UIButton) {
        
        writingButton.tintColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        
        editingButton.tintColor = UIColor.init(named: "FontColor")
        
        lookingButton.tintColor = UIColor.init(named: "FontColor")
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(delayedAction), userInfo: nil, repeats: false)
        
        
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Note", message: "", preferredStyle: .alert)
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Add Note", style: .default) { (action) in
            
            self.noteArray.append(textField.text!)
            
            let x = Int(self.mainView.center.x) + Int.random(in: 0...5) - Int.random(in: 0...10)
            let y = Int(self.mainView.center.y) + Int.random(in: 0...20) - Int.random(in: 0...40)
            let width = 200
            let height = 21
            
            let textLabel = UILabel(frame: CGRect(x: x, y: y, width: 200, height: 21))
            //textLabel.center = CGPoint(x: 160, y: 285)
            textLabel.textAlignment = .center
            
            textLabel.text = textField.text
            
            textLabel.font = UIFont.systemFont(ofSize: CGFloat(15))
            
            textLabel.numberOfLines = 0
            
            textLabel.lineBreakMode = .byWordWrapping
            
            textLabel.sizeToFit()
            
            textLabel.tag = Int(NSDate().timeIntervalSince1970)
            
            
            textLabel.textColor = UIColor.init(named: "ViewFontColor")
            
            self.mainView.addSubview(textLabel)
            
            self.labelArray.append(textLabel)
            
            if self.labelView.isHidden == false {
                self.labelView.isHidden = true
            }
            
            let newNote = Note()
            
            let xValue = x
            newNote.xValue.value = Int(xValue)
            
            let yValue = y
            newNote.yValue.value = Int(yValue)
            
            let noteWidth = width
            newNote.noteWidth.value = noteWidth
            
            let noteHeight = height
            newNote.noteHeight.value = noteHeight
            
            if let currentBoard = self.selectedBoard {
                do {
                    try self.realm.write {
                        let newNote = Note()
                        
                        self.noteItems = self.selectedBoard?.notes.sorted(byKeyPath: "noteTag", ascending: true)
                        
                        newNote.xValue.value = Int(x)
                        newNote.yValue.value = Int(y)
                        newNote.noteWidth.value = width
                        newNote.noteHeight.value = height
                        newNote.noteText = textLabel.text
                        newNote.noteTag.value = textLabel.tag
                        newNote.noteFont.value = 1
                        
                        currentBoard.notes.append(newNote)
                    }
                } catch {
                    print("Error saving new notes, \(error)")
                }
            }
            
            
            textLabel.isUserInteractionEnabled = true
            
            textLabel.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.scalePieceNote(_:))))
            
            
            textLabel.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panPieceNote(_:))))
            
            textLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureNote(rec:))))
            
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new note"
            textField = alertTextField
        }
        
        secondAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(secondAction)
        alert.addAction(action)
        
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
        
        
        imageViewArray.forEach { UIImageView in
            UIImageView.isUserInteractionEnabled = true
            
        }
        
        labelArray.forEach { UILabel in
            UILabel.isUserInteractionEnabled = true
            
        }
        
        
    }
    
    
    
    //MARK: - VIEW MOVING BACK FUNCTION
    
    @IBAction func tapPiece(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .ended {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                self.mainView.center.x = self.backView.center.x
                self.mainView.center.y = self.backView.center.y
                
                let coeff = self.backView.frame.size.height / self.mainView.frame.size.height
                
                self.mainView.transform = CGAffineTransform(scaleX: coeff, y: coeff)
                
            })
            animator.startAnimation()
        }}
    
    @IBAction func tapPieceRotation(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .ended {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                self.mainView.center.x = self.backView.center.x
                self.mainView.center.y = self.backView.center.y
                
                gestureRecognizer.numberOfTouchesRequired = 2
                
                self.imageItems = self.selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
                
                let allItems = self.selectedBoard?.items.count ?? 0
                
                if self.selectedBoard?.items.count != 0 {
                    
                    for n in 0...Int(allItems - 1) {
                        let count = n
                        
                        if let photo = self.imageItems?[count] {
                            
                            let locationOfEndTap = gestureRecognizer.location(in: self.mainView)
                            
                            let img = self.imageViewArray[count]
                            
                            if (self.imageViewArray[count].layer.hitTest(locationOfEndTap) != nil) {
                                
                                let rotation = CGFloat(360 - photo.imageRotation.value!)
                                
                                let radians = rotation / 180.0 * CGFloat.pi
                                
                                let rotated = img.transform.rotated(by: radians)
                                
                                img.transform = rotated
                                
                                
                            }
                        }
                        
                    }
                    
                }
                
            })
            animator.startAnimation()
        }}
    
    
    //MARK: - VIEW MOVING FUNCTION
    
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        gestureRecognizer.delegate = self
        
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
        }
        if gestureRecognizer.state != .cancelled {
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            piece.center = newCenter
            
            locationX = initialCenter.x + translation.x
            
            locationY = initialCenter.y + translation.y
            
            
        }
        else {
            piece.center = initialCenter
        }
        
    }
    
    @IBAction func panPiece2(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        gestureRecognizer.delegate = self
        
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        
        gestureRecognizer.minimumNumberOfTouches = 2
        
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
        }
        if gestureRecognizer.state != .cancelled {
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            piece.center = newCenter
            
            locationX = initialCenter.x + translation.x
            
            locationY = initialCenter.y + translation.y
            
        }
        else {
            piece.center = initialCenter
        }
        
    }
    
    
    @IBAction func panPieceImage(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        gestureRecognizer.delegate = self
        
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        
        
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
            
            
        }
        if gestureRecognizer.state != .cancelled {
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            piece.center = newCenter
            
            imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
            
            let allItems = selectedBoard?.items.count ?? 0
            
            if selectedBoard?.items.count != 0 {
                
                for n in 0...Int(allItems - 1) {
                    let count = n
                    
                    if let photo = imageItems?[count] {
                        
                        let locationOfEndTap = gestureRecognizer.location(in: mainView)
                        
                        
                        let frame = imageViewArray[count].frame
                        
                        if (imageViewArray[count].layer.hitTest(locationOfEndTap) != nil) {
                            
//                            if gestureRecognizer.location(in: mainView).x >= 1366 {
//
//                                imageViewArray[count].transform = CGAffineTransform(translationX: -((gestureRecognizer.location(in: mainView).x - 1366) + frame.width), y: 0)
//
//                                gestureRecognizer.state = .ended
//
//                            } else if gestureRecognizer.location(in: mainView).x <= 0 {
                                
//                                imageViewArray[count].transform = CGAffineTransform(translationX: -(gestureRecognizer.location(in: mainView).x) + frame.width, y: 0)
//
//                                gestureRecognizer.state = .ended
//
//                            } else if gestureRecognizer.location(in: mainView).y >= 1024 {
//
//                                imageViewArray[count].transform = CGAffineTransform(translationX: 0, y: -((gestureRecognizer.location(in: mainView).y - 1024) + frame.height))
//
//                                gestureRecognizer.state = .ended
//
//                            } else if gestureRecognizer.location(in: mainView).y <= 0 {
//
//                                imageViewArray[count].transform = CGAffineTransform(translationX: 0, y: -(gestureRecognizer.location(in: mainView).y) + frame.height)
//
//                                gestureRecognizer.state = .ended
//                            }
                            
                            
                            do {
                                let realm = try Realm()
                                try realm.write {
                                    
                                    let xValue = Int(frame.origin.x)
                                    photo.xValue.value = xValue
                                    
                                    let yValue = Int(frame.origin.y)
                                    photo.yValue.value = yValue
                                }
                                
                            } catch {
                                print("Error saving location, \(error)")
                            }
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
            
        } else {
            piece.center = initialCenter
        }
        
    }
    
    
    @IBAction func panPieceNote(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
            
        }
        if gestureRecognizer.state != .cancelled {
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            piece.center = newCenter
            
            noteItems = selectedBoard?.notes.sorted(byKeyPath: "noteTag", ascending: true)
            
            let allNotes = selectedBoard?.notes.count ?? 0
            
            if selectedBoard?.notes.count != 0 {
                
                for n in 0...Int(allNotes - 1) {
                    let count = n
                    
                    if let note = noteItems?[count] {
                        
                        let locationOfEndTap = gestureRecognizer.location(in: mainView)
                        
                        
                        let frame = labelArray[count].frame
                        
                        if (labelArray[count].layer.hitTest(locationOfEndTap) != nil) {
                            
                            //print(labelArray[count].frame.origin.x)
                            
                            do {
                                let realm = try Realm()
                                try realm.write {
                                    
                                    let xValue = Int(frame.origin.x)
                                    note.xValue.value = xValue
                                    
                                    let yValue = Int(frame.origin.y)
                                    note.yValue.value = yValue
                                }
                                
                            } catch {
                                print("Error saving location, \(error)")
                            }
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
            
            
        } else {
            piece.center = initialCenter
        }
        
    }
    
    //MARK: - VIEW ZOOMING FUNCTION
    
    @IBAction func scalePiece(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        gestureRecognizer.delegate = self
        
        
        if let view = gestureRecognizer.view {
            
            switch gestureRecognizer.state {
            case .changed:
                let pinchCenter = CGPoint(x: gestureRecognizer.location(in: view).x - view.bounds.midX,
                                          y: gestureRecognizer.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                gestureRecognizer.scale = 1
            case .ended: break
                
            default:
                return
            }
            
            
        }
        
    }
    
    @IBAction func scalePiece2(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        gestureRecognizer.delegate = self
        
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
            
            gestureRecognizer.scale = 1.0
            
            imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
            
            let allItems = selectedBoard?.items.count ?? 0
            
            if selectedBoard?.items.count != 0 {
                
                for n in 0...Int(allItems - 1) {
                    let count = n
                    
                    if let photo = imageItems?[count] {
                        
                        let locationOfEndTap = gestureRecognizer.location(in: mainView)
                        
                        let frame = imageViewArray[count].frame
                        
                        if (imageViewArray[count].layer.hitTest(locationOfEndTap) != nil) {
                            
                            
                            do {
                                let realm = try Realm()
                                try realm.write {
                                    
                                    let height = Int(frame.height)
                                    photo.imageHeight.value = height
                                    
                                    let width = Int(frame.width)
                                    photo.imageWidth.value = width
                                }
                                
                            } catch {
                                print("Error saving location, \(error)")
                            }
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    @IBAction func scalePieceNote(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
            
            gestureRecognizer.scale = 1.0
            
            noteItems = selectedBoard?.notes.sorted(byKeyPath: "noteTag", ascending: true)
            
            let allItems = selectedBoard?.notes.count ?? 0
            
            if selectedBoard?.notes.count != 0 {
                
                for n in 0...Int(allItems - 1) {
                    let count = n
                    
                    if let note = noteItems?[count] {
                        
                        let locationOfEndTap = gestureRecognizer.location(in: mainView)
                        
                        
                        let frame = labelArray[count].frame
                        
                        if (labelArray[count].layer.hitTest(locationOfEndTap) != nil) {
                            
                            if labelArray[count].frame.width >= 600 {
                                
                                labelArray[count].transform = CGAffineTransform(scaleX: 9, y: 9)
                                
                            } else if labelArray[count].frame.width <= 10 {
                                
                                labelArray[count].transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                            }
                            
                            do {
                                let realm = try Realm()
                                try realm.write {
                                    
                                    let font = 200 / frame.width
                                    
                                    if Int(frame.width) > 200 {
                                        
                                        let finalFont = font * 10
                                        note.noteFont.value = Double(finalFont)
                                        
                                    } else if Int(frame.width) < 200 {
                                        
                                        let finalFont = Double(font) * 0.01
                                        note.noteFont.value = finalFont
                                        
                                    }
                                    
                                }
                                
                            } catch {
                                print("Error saving location, \(error)")
                            }
                            
                            
                            
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    //MARK: - ROTATING FUNCTION
    
    @IBAction func rotatePiece(_ gestureRecognizer : UIRotationGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            gestureRecognizer.view?.transform = gestureRecognizer.view!.transform.rotated(by: gestureRecognizer.rotation)
            gestureRecognizer.rotation = 0
            
            let locationOfEndTap = gestureRecognizer.location(in: mainView)
            
            locationOfPinchTap = locationOfEndTap
            
            rotate(angle: getRotateAngle())
            
        }}
    
    func getRotateAngle() -> CGFloat {
        
        imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
        
        let allItems = selectedBoard?.items.count ?? 0
        
        if selectedBoard?.items.count != 0 {
            
            for n in 0...Int(allItems - 1) {
                let count = n
                
                if (imageViewArray[count].layer.hitTest(locationOfPinchTap) != nil) {
                    
                    let radians = atan2(imageViewArray[count].transform.b, imageViewArray[count].transform.a)
                    let degrees = radians * 180 / .pi
                    //
                    
                    realRotationDegrees = degrees
                    
                    
                    if let photo = imageItems?[count] {
                        
                        do {
                            let realm = try Realm()
                            try realm.write {
                                
                                photo.imageRotation.value = Float(degrees)
                                
                            }
                            
                        } catch {
                            print("Error saving location, \(error)")
                        }
                    }
                    
                }
            }
            
        }
        
        let realDegrees = realRotationDegrees
        
        print(realRotationDegrees)
        
        return realDegrees
        
    }
    
    func rotate(angle: CGFloat) {
        
        imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
        
        let allItems = selectedBoard?.items.count ?? 0
        
        if selectedBoard?.items.count != 0 {
            
            for n in 0...Int(allItems - 1) {
                let count = n
                
                if (imageViewArray[count].layer.hitTest(locationOfLongTap) != nil) {
                    
                    let radians = angle / 180.0 * CGFloat.pi
                    let rotation = imageViewArray[count].transform.rotated(by: radians);
                    imageViewArray[count].transform = rotation
                    
                }
                
            }
            
        }
        
    }
    
    
    
    //MARK: - IMAGE MENU
    
    @objc func flipContent(_ sender: Any) {
        
        imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
        
        let allItems = selectedBoard?.items.count ?? 0
        
        if selectedBoard?.items.count != 0 {
            
            for n in 0...Int(allItems - 1) {
                let count = n
                
                if let photo = imageItems?[count] {
                    
                    if (imageViewArray[count].layer.hitTest(locationOfLongTap) != nil) {
                        
                        
                        if photo.imageFlip.value == false {
                            
                        } else {
                            
                        }
                        
                        do {
                            let realm = try Realm()
                            try realm.write {
                                
                                if photo.imageFlip.value == false {
                                    photo.imageFlip.value = true
                                } else {
                                    photo.imageFlip.value = false
                                }
                                
                            }
                            
                        } catch {
                            print("Error saving location, \(error)")
                        }
                        
                        
                        
                    }
                }
                
            }
            
        }
        
    }
    
    
    @objc func backwardContent(_ sender: Any) {
        
        imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
        
        let allItems = selectedBoard?.items.count ?? 0
        
        if selectedBoard?.items.count != 0 {
            
            for n in 0...Int(allItems - 1) {
                let count = n
                
                if let photo = imageItems?[count] {
                    
                    if (imageViewArray[count].layer.hitTest(locationOfLongTap) != nil) {
                        
                        self.mainView.sendSubviewToBack(imageViewArray[count])
                        
                        do {
                            let realm = try Realm()
                            try realm.write {
                                
                                for c in 0...count {
                                let count2 = c
                                    
                                    if let photo2 = imageItems?[count2] {
                                        
                                        photo2.imageBackward.value! += 1
                                    }
                                    
                                }
                                
                                photo.imageBackward.value = 0
                                
                                
                            }
                            
                        } catch {
                            print("Error saving value, \(error)")
                        }
                        
                        
                        
                    }
                    
//                    if (imageViewArray[count].layer.hitTest(locationOfLongTap) == nil) {
//
//
//                        do {
//                            let realm = try Realm()
//                            try realm.write {
//
//                                let newValue = photo.imageBackward.value! + 1
//
//                                photo.imageBackward.value = newValue
//
//                            }
//
//                        } catch {
//                            print("Error saving value, \(error)")
//                        }
//
//
//
//                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    @objc func deleteContent(_ sender: Any) {
        
        imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
        
        let allItems = selectedBoard?.items.count ?? 0
        
        photoBool = false
        
        if (selectedBoard?.items.count)! > 2 {
            
            for n in 0...Int(allItems - 2) {
                let count = n
                
                if let photo = imageItems?[count] {
                    
                    if (imageViewArray[count].layer.hitTest(locationOfLongTap) != nil) {
                        
                        imageViewArray[count].removeFromSuperview()
                        
                        imageViewArray.remove(at: count)
                        
                        PhotoArray.remove(at: count)
                        
                        photoBool = true
                        
                        do {
                            let realm = try Realm()
                            
                            
                            try realm.write {
                                realm.delete(photo)
                            }
                            
                            
                        }catch {
                            print("there is error with delete Realm object ! : \(error)")
                        }
                        
                        
                    }
                }
                
                
                
            }
            
            if photoBool == false {
                
                if let photo = imageItems?[allItems - 1] {
                    
                    if (imageViewArray[allItems - 1].layer.hitTest(locationOfLongTap) != nil) {
                        
                        imageViewArray[allItems - 1].removeFromSuperview()
                        
                        imageViewArray.remove(at: allItems - 1)
                        
                        PhotoArray.remove(at: allItems - 1)
                        
                        
                        do {
                            let realm = try Realm()
                            
                            try realm.write {
                                realm.delete(photo)
                            }
                            
                            
                        }catch {
                            print("there is error with delete Realm object ! : \(error)")
                        }
                        
                        
                    }
                }
                
                photoBool = false
                
            }
            
        } else if (selectedBoard?.items.count)! == 2 {
            
            
            
            if (imageViewArray[1].layer.hitTest(locationOfLongTap) != nil) {
                
                let photo = imageItems?[1]
                
                imageViewArray[1].removeFromSuperview()
                
                imageViewArray.remove(at: 1)
                
                PhotoArray.remove(at: 1)
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(photo!)
                    }
                    
                    
                }catch {
                    print("there is error with delete Realm object ! : \(error)")
                }
                
                
            }
            
            if (imageViewArray[0].layer.hitTest(locationOfLongTap) != nil) {
                
                let photo = imageItems?[0]
                
                imageViewArray[0].removeFromSuperview()
                
                imageViewArray.remove(at: 0)
                
                PhotoArray.remove(at: 0)
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(photo!)
                    }
                    
                    
                }catch {
                    print("there is error with delete Realm object ! : \(error)")
                }
                
                
            }
            
            
        } else if (selectedBoard?.items.count)! == 1 {
            
            if (imageViewArray[0].layer.hitTest(locationOfLongTap) != nil) {
                
                let photo = imageItems?[0]
                
                imageViewArray[0].removeFromSuperview()
                
                imageViewArray.remove(at: 0)
                
                PhotoArray.remove(at: 0)
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(photo!)
                    }
                    
                    
                }catch {
                    print("there is error with delete Realm object ! : \(error)")
                }
                
                
            }
            
        }
        
        
        if selectedBoard?.items.count == 0 {
            if self.labelView.isHidden == true {
                self.labelView.isHidden = false
            }
        }
        
        
    }
    
    
    @objc func longPressGesture(rec: UIGestureRecognizer) {
        
        let locationOfEndTap = rec.location(in: mainView)
        
        locationOfLongTap = locationOfEndTap
        
        if let recView = rec.view, let superRecView = recView.superview {
            
            UIMenuController.shared.menuItems = [UIMenuItem(title: "Move Backwards", action: #selector(backwardContent)), UIMenuItem(title: "Delete", action: #selector(deleteContent))]
            
            UIMenuController.shared.showMenu(from: superRecView, rect: recView.frame)
            UIMenuController.shared.arrowDirection = .default
            
        }
    }
    
    @objc func longPressGestureNote(rec: UIGestureRecognizer) {
        
        let locationOfEndTap = rec.location(in: mainView)
        
        locationOfLongTap = locationOfEndTap
        
        if let recView = rec.view, let superRecView = recView.superview {
            
            
            UIMenuController.shared.menuItems = [UIMenuItem(title: "Delete", action: #selector(deleteContentNote))]
            
            UIMenuController.shared.showMenu(from: superRecView, rect: recView.frame)
            UIMenuController.shared.arrowDirection = .default
            
        }
    }
    
    @objc func deleteContentNote(_ sender: Any) {
        
        
        
        noteItems = selectedBoard?.notes.sorted(byKeyPath: "noteTag", ascending: true)
        
        let allItems = selectedBoard?.notes.count ?? 0
        
        photoBool = false
        
        if (selectedBoard?.notes.count)! > 2 {
            
            for n in 0...Int(allItems - 2) {
                let count = n
                
                if let note = noteItems?[count] {
                    
                    if (labelArray[count].layer.hitTest(locationOfLongTap) != nil) {
                        
                        labelArray[count].removeFromSuperview()
                        
                        labelArray.remove(at: count)
                        
                        noteArray.remove(at: count)
                        
                        photoBool = true
                        
                        do {
                            let realm = try Realm()
                            
                            
                            try realm.write {
                                realm.delete(note)
                            }
                            
                            
                        }catch {
                            print("there is error with delete Realm object ! : \(error)")
                        }
                        
                        
                    }
                }
                
                
                
            }
            
            if photoBool == false {
                
                if let note = noteItems?[allItems - 1] {
                    
                    if (labelArray[allItems - 1].layer.hitTest(locationOfLongTap) != nil) {
                        
                        labelArray[allItems - 1].removeFromSuperview()
                        
                        labelArray.remove(at: allItems - 1)
                        
                        noteArray.remove(at: allItems - 1)
                        
                        
                        do {
                            let realm = try Realm()
                            
                            try realm.write {
                                realm.delete(note)
                            }
                            
                            
                        }catch {
                            print("there is error with delete Realm object ! : \(error)")
                        }
                        
                        
                    }
                }
                
                photoBool = false
                
            }
            
        } else if (selectedBoard?.notes.count)! == 2 {
            
            
            
            if (labelArray[1].layer.hitTest(locationOfLongTap) != nil) {
                
                let note = noteItems?[1]
                
                labelArray[1].removeFromSuperview()
                
                labelArray.remove(at: 1)
                
                noteArray.remove(at: 1)
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(note!)
                    }
                    
                    
                }catch {
                    print("there is error with delete Realm object ! : \(error)")
                }
                
                
            }
            
            if (labelArray[0].layer.hitTest(locationOfLongTap) != nil) {
                
                let note = noteItems?[0]
                
                labelArray[0].removeFromSuperview()
                
                labelArray.remove(at: 0)
                
                noteArray.remove(at: 0)
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(note!)
                    }
                    
                    
                }catch {
                    print("there is error with delete Realm object ! : \(error)")
                }
                
                
            }
            
            
        } else if (selectedBoard?.notes.count)! == 1 {
            
            if (labelArray[0].layer.hitTest(locationOfLongTap) != nil) {
                
                let note = noteItems?[0]
                
                labelArray[0].removeFromSuperview()
                
                labelArray.remove(at: 0)
                
                noteArray.remove(at: 0)
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.delete(note!)
                    }
                    
                    
                }catch {
                    print("there is error with delete Realm object ! : \(error)")
                }
                
                
            }
            
        }
        
        print(labelArray.count)
        
        if selectedBoard?.notes.count == 0, selectedBoard?.items.count == 0 {
            if self.labelView.isHidden == true {
                self.labelView.isHidden = false
            }
        }
        
        
    }
    
    //MARK: - HIDE BAR BUTTON
    
    @IBAction func hideBarButtonPressed(_ sender: UIButton) {
        UIView.transition(with: upperBarView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.upperBarView.isHidden = true
        })
        
        
        
    }
    
    
    //MARK: - SHOW BAR BUTTON
    
    @IBAction func showBarButtonPressed(_ sender: UIButton) {
        
        UIView.transition(with: upperBarView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.upperBarView.isHidden = false
        })
        
    }
    
    
    //MARK: - HELP BUTTON
    
    @IBAction func helpTap (_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .ended {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                
                self.helpView.isHidden = true
                
            })
            animator.startAnimation()
        }}
    
    
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        
        helpView.isHidden = false
        
        helpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(helpTap(_:))))
        
    }
    
    
    //MARK: - DELETE BUTTON
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Clear the Board", message: "Are you sure that you want to remove all images (\(self.imageViewArray.count)) from the board?", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Remove", style: .default) { (firstAction) in
            
            self.imageViewArray.forEach { UIImageView in
                UIImageView.removeFromSuperview()
                
            }
            self.imageViewArray.removeAll()
            
            self.labelArray.forEach { UILabel in
                UILabel.removeFromSuperview()
                
            }
            
            self.labelArray.removeAll()
            
            self.noteArray.removeAll()
            
            self.PhotoArray.removeAll()
            
            
            do {
                let realm = try Realm()
                
                guard let attachmentObject =  self.selectedBoard?.items else {return print("cannot delete child")}
                
                try realm.write {
                    realm.delete(attachmentObject)
                }
                
                
            }catch {
                print("there is error with delete Realm object ! : \(error)")
            }
            
            do {
                let realm = try Realm()
                
                guard let attachmentObject =  self.selectedBoard?.notes else {return print("cannot delete child")}
                
                try realm.write {
                    realm.delete(attachmentObject)
                }
                
                
            }catch {
                print("there is error with delete Realm object ! : \(error)")
            }
            
            if self.labelView.isHidden == true {
                self.labelView.isHidden = false
            }
            
        }
        
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        firstAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        
        
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
        
        
    }
    
    
    //MARK: - MODE BUTTON
    
    @IBOutlet weak var modeButton: UISegmentedControl!
    
    @IBAction func modeButtonPressed(_ sender: UISegmentedControl) {
        
        var modeBool = true
        
        switch modeButton.selectedSegmentIndex
        {
        case 0:
            overrideUserInterfaceStyle = .light
            modeBool = true
        case 1:
            overrideUserInterfaceStyle = .dark
            modeBool = false
        default:
            break
        }
        
        if modeBool == true {
            UserDefaults.standard.set(true, forKey: "ModeBool")
        } else {
            UserDefaults.standard.set(false, forKey: "ModeBool")
        }
        
    }
    
    //MARK: - GALLERY BUTTON
    
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToFirstScreen", sender: self)
        
        galleryButton.showsTouchWhenHighlighted = true
    }
    
    //MARK: - ADD IMAGES BUTTON
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        
        let vc = BSImagePickerViewController()
        
        
        self.bs_presentImagePickerController(vc, animated: true,
                                             select: { (asset: PHAsset) -> Void in
                                                
        }, deselect: { (asset: PHAsset) -> Void in
            
            
        }, cancel: { (assets: [PHAsset]) -> Void in
            
        }, finish: { (assets: [PHAsset]) -> Void in
            
            
            for i in 0..<assets.count
            {
                self.SelectedAssets.append(assets[i])
                
            }
            
            self.convertAssetToImages()
            
        }, completion: nil)
        
        PhotoArray.removeAll()
        SelectedAssets.removeAll()
        
        
    }
    
    
    func convertAssetToImages() -> Void {
        
        if SelectedAssets.count != 0{
            
            
            for i in 0..<SelectedAssets.count{
                
                
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize (width: Int(thumbnail.size.width) / 10, height: Int(thumbnail.size.height) / 10), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                    
                })
                
                let imageData = thumbnail.jpegData(compressionQuality: 1.0)
                
                let newImage = UIImage(data: imageData!)
                
                let uuid = UUID().uuidString
                let fileName = "\(uuid).jpg"
                let folderName = "ImagesFolder"
                
                self.PhotoArray.append(newImage! as UIImage)
                
                let imageView = UIImageView(image: newImage)
                
                
                let firstIntX = Int(self.mainView.center.x - 150)
                let secondIntX = Int(self.mainView.center.x + 150)
                let firstIntY = Int(self.mainView.center.y - 150)
                let secondIntY = Int(self.mainView.center.y + 150)
                
                
                let x = Int.random(in: firstIntX...secondIntX)
                let y = Int.random(in: firstIntY...secondIntY)
                
                let width = Int(newImage!.size.width) / 20
                let height = Int(newImage!.size.height) / 20
                
                
                imageView.frame = CGRect(x: x, y: y, width: width, height: height)
                
                imageView.tag = Int(NSDate().timeIntervalSince1970)
                
                mainView.addSubview(imageView)
                self.imageViewArray.append(imageView as UIImageView)
                
                
                
                func saveImageToDirectory(imageData: Data, fileName: String, folderName: String) {
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                    let documentsDirectory = paths.object(at: 0) as! NSString
                    let path = documentsDirectory.appendingPathComponent(folderName) as NSString
                    if !FileManager.default.fileExists(atPath: path as String) {
                        do {
                            try FileManager.default.createDirectory(atPath: path as String, withIntermediateDirectories: true, attributes: nil)
                        } catch let error as NSError {
                            print(error.localizedDescription);
                        }
                    }
                    
                    let imagePath = path.appendingPathComponent(fileName)
                    
                    if !FileManager.default.fileExists(atPath: imagePath as String) {
                        try? imageData.write(to: URL(fileURLWithPath: imagePath))
                    }
                    
                    let newPhoto = Item()
                    
                    let xValue = x
                    newPhoto.xValue.value = xValue
                    
                    let yValue = y
                    newPhoto.yValue.value = yValue
                    
                    let photoWidth = width
                    newPhoto.imageWidth.value = photoWidth
                    
                    let photoHeight = height
                    newPhoto.imageHeight.value = photoHeight
                    
                    let photoRotation = 0
                    newPhoto.imageRotation.value = Float(photoRotation)
                    
                    imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
                    
                    let count = self.imageItems?.count
                    
                    if count == 0 {
                        newPhoto.imageBackward.value = 0
                    } else {
                        newPhoto.imageBackward.value = self.imageItems!.count
                    }
                    
                    let photoTag = imageView.tag
                    newPhoto.imageTag.value = photoTag
                    
                    let photoFlip = false
                    newPhoto.imageFlip.value = photoFlip
                    
                    let photoPath = "ImagesFolder/\(fileName)"
                    newPhoto.imagePath = photoPath
                    
                    RealmHelper.saveImage(image: newPhoto)
                    navigationController?.popViewController(animated: true)
                }
                
                
                saveImageToDirectory(imageData: imageData!, fileName: fileName, folderName: folderName)
                
                
                if let currentBoard = self.selectedBoard {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            
                            imageItems = selectedBoard?.items.sorted(byKeyPath: "imageBackward", ascending: true)
                            
                            let count = self.imageItems?.count
                            
                            newItem.xValue.value = x
                            newItem.yValue.value = y
                            newItem.imageWidth.value = width
                            newItem.imageHeight.value = height
                            newItem.imagePath = "ImagesFolder/\(fileName)"
                            newItem.imageRotation.value = 0
                            newItem.imageTag.value = imageView.tag
                            //newItem.imageBackward.value = false
                            if count == 0 {
                                newItem.imageBackward.value = 0
                            } else {
                                newItem.imageBackward.value = self.imageItems!.count
                            }
                            newItem.imageFlip.value = false
                            
                            currentBoard.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new items, \(error)")
                    }
                }
                
                if lookingButton.tintColor == #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1) as UIColor? {
                    imageView.isUserInteractionEnabled = false
                } else {
                    
                    imageView.isUserInteractionEnabled = true
                }
                
                imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scalePiece2(_:))))
                
                if labelView.isHidden == false {
                    labelView.isHidden = true
                }
                
                
                //imageView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(rotatePiece(_:))))
                
                imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPieceImage(_:))))
                
                imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(rec:))))
                
                //imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(tapPieceRotation(_:))))
                
                
            }
            
        }
        
        
    }
    
    func loadImages() {
        if let fetchedPhotos = RealmHelper.getAllImages() {
            imageItems = fetchedPhotos
        }
        
    }
    
    func deleteImageFromDocumentDir(localPathName: String) {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(localPathName)
        do {
            try filemanager.removeItem(atPath: destinationPath)
        } catch let error as NSError {
            print("Error Deleting Image from Documents Directory: \(error.localizedDescription)")
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if self.removeAdsIndex == 4 {
                self.loadBannerAd()
            } else {
                print("purchased")
            }
            
        
        
        
        guard let trait = SizeClasser(traitCollection: traitCollection ) else { return }
        
        if trait.contains([.iPadLandscape, .iPadSplitOneThird]) {
            
            print("landscape, 1/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            modeButton.isHidden = true
            editingButton.isHidden = true
            writingButton.isHidden = true
            lookingButton.isHidden = true
            deleteButton.isHidden = true
            
            
        } else if trait.contains([.iPadPortrait, .iPadSplitOneThird]) {
            
            print("portrait, 1/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            modeButton.isHidden = true
            editingButton.isHidden = true
            writingButton.isHidden = true
            lookingButton.isHidden = true
            deleteButton.isHidden = true
            
            
        } else if trait.contains([.iPadLandscape, .iPadSplitTwoThird]) {
            
            print("landscape, 2/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            writingButton.isHidden = true
            
            
        } else if trait.contains([.iPadPortrait, .iPadSplitTwoThird]) {
            
            print("portrait, 2/3")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            
            modeButton.isHidden = false
            editingButton.isHidden = false
            writingButton.isHidden = false
            lookingButton.isHidden = false
            deleteButton.isHidden = false
            
            
        } else if trait.contains([.iPadLandscape, .iPadSplitHalf]) {
            
            print("landscape, 1/2")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            writingButton.isHidden = true
            
        } else if trait.contains([.iPadLandscape]) {
            
            print("landscape, full")
            
            helpButton.isHidden = true
            writingButton.isHidden = true
            
        } else if trait.contains([.iPadPortrait]) {
            
            print("portrait, full")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            
            modeButton.isHidden = false
            editingButton.isHidden = false
            writingButton.isHidden = false
            lookingButton.isHidden = false
            deleteButton.isHidden = false
            
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let previousTrait = SizeClasser(traitCollection: previousTraitCollection!) else { return }
        
        
        if previousTrait.contains([.iPadLandscape, .iPadSplitOneThird]) {
            
            print("landscape, 2/3, from 1/3 ")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            modeButton.isHidden = false
            editingButton.isHidden = false
            writingButton.isHidden = false
            lookingButton.isHidden = false
            deleteButton.isHidden = false
            
        }
        
        if previousTrait.contains([.iPadPortrait, .iPadSplitOneThird]) {
            
            print("portrait, 2/3, from 1/3 ")
            
            helpView.isHidden = true
            helpButton.isHidden = true
            modeButton.isHidden = false
            editingButton.isHidden = false
            writingButton.isHidden = false
            lookingButton.isHidden = false
            deleteButton.isHidden = false
            
        }
        
        helpView.isHidden = true
        helpButton.isHidden = true
        modeButton.isHidden = false
        editingButton.isHidden = false
        writingButton.isHidden = false
        lookingButton.isHidden = false
        deleteButton.isHidden = false
        
        //}
    }
    
    
    
}

extension UIImage {
    func flipHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}





    



    
    
    


