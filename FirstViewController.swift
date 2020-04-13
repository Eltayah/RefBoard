//
//  ViewController.swift
//  RefBoard.
//
//  Created by Elijah Altayer on 14.02.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import StoreKit
import SizeClasser

class FirstViewController: UIViewController, GADBannerViewDelegate {
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    var bannerView: GADBannerView!
    
    var boards: Results<Board>?
    
    var dataArray = [""]
    
    var estimateWidth = 230.0
    var cellMarginSize = 23.0
    var removeAdsIndex = 4
    
    var indexPath : IndexPath? = [0, 0]
    
    var locationOfTap = CGPoint()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var adRemovalButton: UIButton!
    @IBOutlet weak var removeAdsView: UIView!
    @IBOutlet weak var subscribe1: UIButton!
    @IBOutlet weak var subscribe2: UIButton!
    @IBOutlet weak var subscribe3: UIButton!
    
     var products: [SKProduct] = []
    
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    
    @IBAction func subscribeButton3(_ sender: UIButton) {
        
        guard !products.isEmpty else {
          print("Cannot purchase subscription because products is empty!")
          return
        }

            self.purchaseItemIndex(index: 2)

    }
    
    
    @IBAction func subscribeButton2(_ sender: UIButton) {
        
        guard !products.isEmpty else {
          print("Cannot purchase subscription because products is empty!")
          return
        }

            self.purchaseItemIndex(index: 1)
    }
    
    
    @IBAction func subscribeButton1(_ sender: UIButton) {
        
        guard !products.isEmpty else {
          print("Cannot purchase subscription because products is empty!")
          return
        }

            self.purchaseItemIndex(index: 0)
    }
    
    private func purchaseItemIndex(index: Int) {
      SubscribtionProducts.store.buyProduct(products[index]) { [weak self] success, productId in
        guard let self = self else { return }
        guard success else {
          let alertController = UIAlertController(title: "Failed to purchase product",
                                                  message: "Check logs for details",
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alertController, animated: true, completion: nil)
          return
        }
        self.adRemovalButton.setTitleColor(.gray, for: .normal)
        self.removeAdsView.isHidden = true
        
        if self.bannerView.isHidden == true {
            
            print("repurchased")
            
        } else {
        self.bannerView.removeFromSuperview()
        }
        
        if self.subscribe1.backgroundColor == #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1) {
            self.subscribe1.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        }
        
        if self.subscribe2.backgroundColor == #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1) {
            self.subscribe2.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        }
        
        if self.subscribe3.backgroundColor == #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1) {
            self.subscribe3.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 1, alpha: 1)
        }
        
        if index == 0 {
            self.subscribe1.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe1.setTitle("Subscribed", for: .normal)
            self.removeAdsIndex = 1
            UserDefaults.standard.set(1, forKey: "removeAdsIndex")
        } else if index == 1 {
            self.subscribe2.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe2.setTitle("Subscribed", for: .normal)
            self.removeAdsIndex = 2
            UserDefaults.standard.set(2, forKey: "removeAdsIndex")
        } else if index == 2 {
            self.subscribe3.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe3.setTitle("Subscribed", for: .normal)
            self.removeAdsIndex = 3
            UserDefaults.standard.set(3, forKey: "removeAdsIndex")
        }
        
      }
    }
    
    
    @IBAction func restoreButton(_ sender: UIButton) {
        
        SubscribtionProducts.store.restorePurchases()
        print("restored")
        
            let alertController = UIAlertController(title: "Remove Ads Restoration",
                                                      message: "Please, remove the RefBoard app from your Recently Used Apps list and reopen it for subscribtion benefits to work. If ads are still not removed after these steps that means that you do not have any active RefBoard subscribtions associated with your Apple ID.",
                                                      preferredStyle: .alert)
              alertController.addAction(UIAlertAction(title: "Ok",
                                                      style: .default,
                                                      handler: { action in
        
              }))
            self.present(alertController, animated: true, completion: nil)

        }

    
    
    @IBAction func cancelRemoveAds(_ sender: UIButton) {
        
        removeAdsView.isHidden = true
        
    }
    
    @IBOutlet weak var refBoardLabel: UILabel!
    
    @IBAction func removeAdsButton(_ sender: UIButton) {
        
        if removeAdsView.isHidden == false {
            removeAdsView.isHidden = true
        } else {
        
        removeAdsView.isHidden = false
        }
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPiece(_:))))

        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var labelView: UIView!
    
    
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func AddNewBoardButtonPressed(_ sender: UIButton) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a New Board", message: "Write down a name of your Board.", preferredStyle: .alert)
        
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newBoard = Board()
            
            newBoard.name = textField.text!
            
           let count = self.boards?.count
            
            if count == 0 {
            newBoard.sortingIndex = 0
            } else {
                newBoard.sortingIndex = self.boards!.count
            }
            
            self.save(board: newBoard)
            
            self.dataArray.append("\(newBoard.sortingIndex)")
            
            if self.labelView.isHidden == false {
                self.labelView.isHidden = true
            }
        }
        
        secondAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(secondAction)
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Board Name"
            textField.text = "New Board"
        }
        
        present(alert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
        
        //performSegue(withIdentifier: "GoToSecondScreen", sender: self)
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToSecondScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SecondViewController
        collectionView.allowsMultipleSelection = false
        
        if let indexPathArray = collectionView.indexPathsForSelectedItems {
            
            let indexPath = indexPathArray[0]
            
            destinationVC.selectedBoard = boards?[indexPath.row]
        }
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
    
    //var requestInitialized = false

    func loadInterstitial() {
    let request = GADRequest()
        

    request.scene = view.window?.windowScene
    
    interstitial.load(request)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if !interstitial.isReady {
//
//            loadInterstitial()
//
//        }
        
        

        
   
//        if !requestInitialized == true {
//            loadInterstitial()
//            requestInitialized = true
//        }
    }
    
    func loadBannerAd() {
               let bannerWidth = view.frame.size.width
        
        //print(bannerWidth)

               bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)

               let request = GADRequest()
               request.scene = view.window?.windowScene
               bannerView.load(request)
           }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { context in
            
            if self.removeAdsIndex == 4 {
                self.loadBannerAd()
            } else {
                print("purchased")
            }
            
//            guard let trait = SizeClasser(traitCollection: self.traitCollection ) else { return }
//
//            if trait.contains([.iPadLandscape, .iPadSplitOneThird]) {
//
//                print("landscape, 1/3")
//
//                self.refBoardLabel.isHidden = true
//
//
//            } else if trait.contains([.iPadPortrait, .iPadSplitOneThird]) {
//
//                print("portrait, 1/3")
//
//                self.refBoardLabel.isHidden = true
//            }
            
        }
    }

       func adViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("Received Ad")
        }

        func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
            print(error)
        }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-2344003946089796/5241689717"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        let removeAdsIndex = UserDefaults.standard.integer(forKey: "removeAdsIndex")
        
        if removeAdsIndex == 1 {
            self.removeAdsIndex = 1
        } else if removeAdsIndex == 2 {
            self.removeAdsIndex = 2
        } else if removeAdsIndex == 3 {
            self.removeAdsIndex = 3
        }
        
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
        
        if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.monthlySub) {
            self.removeAdsIndex = 1
            UserDefaults.standard.set(1, forKey: "removeAdsIndex")
        }
        
        if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.monthly2Sub) {
            self.removeAdsIndex = 2
            UserDefaults.standard.set(2, forKey: "removeAdsIndex")
        }
        
        if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.yearlySub) {
            self.removeAdsIndex = 3
            UserDefaults.standard.set(3, forKey: "removeAdsIndex")
        }
        
        if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.monthlySub) {
            
            bannerView.removeFromSuperview()
          
            adRemovalButton.setTitleColor(.gray, for: .normal)
            
            if self.removeAdsIndex == 1 {
            self.subscribe1.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe1.setTitle("Subscribed", for: .normal)
            } else if self.removeAdsIndex == 2 {
            self.subscribe2.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe2.setTitle("Subscribed", for: .normal)
            } else if self.removeAdsIndex == 3 {
            self.subscribe3.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe3.setTitle("Subscribed", for: .normal)
            }
            
            
        } else if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.monthly2Sub) {
            
            bannerView.removeFromSuperview()
          
            adRemovalButton.setTitleColor(.gray, for: .normal)
            
            if self.removeAdsIndex == 1 {
            self.subscribe1.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe1.setTitle("Subscribed", for: .normal)
            } else if self.removeAdsIndex == 2 {
            self.subscribe2.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe2.setTitle("Subscribed", for: .normal)
            } else if self.removeAdsIndex == 3 {
            self.subscribe3.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe3.setTitle("Subscribed", for: .normal)
            }
            
            
        } else if SubscribtionProducts.store.isProductPurchased(SubscribtionProducts.yearlySub) {
            
            bannerView.removeFromSuperview()
          
            adRemovalButton.setTitleColor(.gray, for: .normal)
            
            if self.removeAdsIndex == 1 {
            self.subscribe1.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe1.setTitle("Subscribed", for: .normal)
            } else if self.removeAdsIndex == 2 {
            self.subscribe2.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe2.setTitle("Subscribed", for: .normal)
            } else if self.removeAdsIndex == 3 {
            self.subscribe3.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            self.subscribe3.setTitle("Subscribed", for: .normal)
            }
            
            
        } else {
          
            bannerView.isHidden = false

        }
        
        
        
////        func adViewDidReceiveAd(_ bannerView: GADBannerView) {
////
////            bannerView.alpha = 0
////             UIView.animate(withDuration: 1, animations: {
////               bannerView.alpha = 1
////             })
////
////          addBannerViewToView(bannerView)
////        }
//
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//
//        addBannerViewToView(bannerView)
//        //adViewDidReceiveAd(bannerView)
//
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        bannerView.delegate = self
        
        
        removeAdsView.isHidden = true
        
        
        let modeBool = UserDefaults.standard.bool(forKey: "ModeBool")
        
        if modeBool == true {
            overrideUserInterfaceStyle = .light
        } else {
            overrideUserInterfaceStyle = .dark
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.dragInteractionEnabled = true
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self
        
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        
        self.setupGridView()
        
        loadBoards()
        
        self.dataArray.remove(at: 0)
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        collectionView.isUserInteractionEnabled = true

        let gRL = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler2(_:)))

        gRL.direction = .left

        collectionView.addGestureRecognizer(gRL)

        let gRR = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler2(_:)))

        gRR.direction = .right

        collectionView.addGestureRecognizer(gRR)
        
        if collectionView.numberOfItems(inSection: 0) > 0 {
            labelView.isHidden = true

            
            let count = self.boards?.count ?? 0
                
                if self.boards?.count != 0 {
                    
                    for n in 0...Int(count - 1) {
                    let index = n
            
            let array = self.boards?[index].sortingIndex
            
                        self.dataArray.append("\(array ?? 0)")
            
            print(dataArray)
                    
                    }
                    
            }

            
        }
        
        if collectionView.numberOfItems(inSection: 0) == 0 {
            if labelView.isHidden == true {
                labelView.isHidden = false
            }
        }
        
    }
    
    @IBAction func tapPiece(_ gestureRecognizer : UITapGestureRecognizer ) {
    guard gestureRecognizer.view != nil else { return }
    
        let locationOfTap = gestureRecognizer.location(in: self.view)
        
        self.locationOfTap = locationOfTap
        
        if (removeAdsView.layer.hitTest(locationOfTap) == nil) {
            
            removeAdsView.isHidden = true


        }
        
        self.view.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPiece(_:))))
    
    }
    
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        
        if let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath {
            
//            collectionView.performBatchUpdates({
//                self.dataArray.remove(at: sourceIndexPath.item)
//                self.dataArray.insert(item.dragItem.localObject as! String, at: destinationIndexPath.item)
//
//                collectionView.deleteItems(at: [sourceIndexPath])
//                collectionView.insertItems(at: [destinationIndexPath])
//            }, completion: nil)
            
            guard let movedObject = boards?[sourceIndexPath.item] else { return }
            // Depending on your exact needs, you might want to update the `sortingIndex` property of your other rows as well, whose position in the table view was affected by the reordering

            try! realm.write {
                //movedObject.sortingIndex = destinationIndexPath.item
                
                let count = self.boards?.count ?? 0

                               if count != 0 {

                                   for n in 0...Int(count - 1) {
                                   let index = n


                                    let objects = boards?[index].sortingIndex
                                    
                                    if sourceIndexPath.item < destinationIndexPath.item {
                                        
                                        if objects != movedObject.sortingIndex {

                                    if objects! >= sourceIndexPath.item, objects! <= destinationIndexPath.item {

                                        let firstEdit = objects! - 1
                                        
                                        boards?[index].sortingIndex = firstEdit
                                        
                                        print(firstEdit)

                                    }
                                    }
                                        
                                    } else if sourceIndexPath.item > destinationIndexPath.item {
                                        
                                        if objects != movedObject.sortingIndex {
                                        
                                        if objects! <= sourceIndexPath.item, objects! >= destinationIndexPath.item {

                                        let secondEdit = objects! + 1
                                            
                                            if secondEdit != count {
                                            
                                        boards?[index].sortingIndex = secondEdit
                                            
                                            print(secondEdit)
                                            }

                                    }
                                    }
                                    }

                                }
                }
                movedObject.sortingIndex = destinationIndexPath.item
                
                
//                print(sourceIndexPath.item)
//                print(destinationIndexPath.item)
            }
            
            boards = realm.objects(Board.self).sorted(byKeyPath: "sortingIndex")
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
             loadBoards()
            collectionView.deselectItem(at: destinationIndexPath, animated: true)

        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        guard let trait = SizeClasser(traitCollection: self.traitCollection ) else { return }
//
//        if trait.contains([.iPadLandscape, .iPadSplitOneThird]) {
//
//            print("landscape, 1/3")
//
//            self.refBoardLabel.isHidden = true
//
//
//        } else if trait.contains([.iPadPortrait, .iPadSplitOneThird]) {
//
//            print("portrait, 1/3")
//
//            self.refBoardLabel.isHidden = true
//        }
        
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setupGridView() {
        
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
    }
    
//      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return boards?.count ?? 1
//    }
    
    @IBAction func swipeHandler2(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            
            gestureRecognizer.numberOfTouchesRequired = 1
            
             handleGesture2(gesture: gestureRecognizer)
            
        }
    }
    
    @objc func handleGesture2(gesture: UISwipeGestureRecognizer) -> Void {
    if gesture.direction == .right {
         print("Rename")
        
        //loadBoards()
        
        let loc = gesture.location(in: self.collectionView)
        
        print(loc)
            
            let swipedIP = self.collectionView.indexPathForItem(at: loc)
            
            indexPath = swipedIP
        
    }
    else if gesture.direction == .left {
         print("Delete")
        
        //loadBoards()
    
    let loc = gesture.location(in: self.collectionView)
        
        print(loc)
        
        let swipedIP = self.collectionView.indexPathForItem(at: loc)
        
        print("Index Path: \(swipedIP ?? [123, 123])")
        
        indexPath = swipedIP
        
        print(indexPath ?? [123, 123])
    
        }
    }
    
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            
            gestureRecognizer.numberOfTouchesRequired = 1
            
            handleGesture(gesture: gestureRecognizer)
            
            //handleGesture2(gesture: gestureRecognizer)
            
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
       if gesture.direction == .right {
            //print("Rename")
        
        let loc = gesture.location(in: self.collectionView)
        
        print(loc)
            
            let swipedIP = self.collectionView.indexPathForItem(at: loc)
            
            indexPath = swipedIP
        
                var textField = UITextField()
                let alert = UIAlertController(title: "Rename the Board", message: "Write down a new name of this Board.", preferredStyle: .alert)
                let firstAction = UIAlertAction(title: "Rename", style: .default) { (firstAction) in
       
                    
//                    if self.collectionView.numberOfItems(inSection: 0) == 1 {
//                    if self.labelView.isHidden == true {
//                        self.labelView.isHidden = false
//                    }
//                    }
                    
                    //self.collectionView.deleteItems(at: [self.indexPath!])
                    
                
                    do {
                                   let realm = try Realm()
                                   
                        guard let objectToDelete =  self.boards?[self.indexPath!.row] else {return print("cannot rename")}
                                   
                                   try realm.write {
                                       
                                    objectToDelete.name = textField.text!
                                    
                                   }
                        
                                   
                               }catch {
                                   print("there is error with rename Realm object ! : \(error)")
                               }

                        self.loadBoards()
                    }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath!) as! ItemCell

        cell.textLabel?.text = boards?[indexPath!.row].name ?? "No Boards added yet"
                   
                let secondAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                firstAction.setValue(UIColor.red, forKey: "titleTextColor")
                
                alert.addAction(firstAction)
                alert.addAction(secondAction)
                //present(alert, animated: true, completion: nil)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "New Board Name"
            textField.text = "\(self.boards?[self.indexPath!.row].name ?? "")"
            
        }
                
                self.present(alert, animated: true) {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                        alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                }
        
        
        
        
       }
       else if gesture.direction == .left {
        
        let loc = gesture.location(in: self.collectionView)
        
        print(loc)
        
        let swipedIP = self.collectionView.indexPathForItem(at: loc)
        
        print("Index Path: \(swipedIP ?? [123, 123])")
        
        indexPath = swipedIP
        
        print(indexPath ?? [123, 123])
        
            //print("Delete")
        
        let alert = UIAlertController(title: "Delete the Board", message: "Are you sure that you want to delete this Board?", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Delete", style: .default) { (firstAction) in
        
//            self.imageViewArray.forEach { UIImageView in
//            UIImageView.removeFromSuperview()
//
//        }
//
//            self.labelArray.forEach { UILabel in
//            UILabel.removeFromSuperview()
//
//        }
            
//            let loc = gesture.location(in: self.collectionView)
//
//            print(loc)
//
//            let swipedIP = self.collectionView.indexPathForItem(at: loc)
//
//            print(swipedIP)
//
//            if swipedIP != nil {
            
                //let swipedCell = self.collectionView.cellForItem(at: self.indexPath!)

            if self.collectionView.numberOfItems(inSection: 0) == 1 {
            if self.labelView.isHidden == true {
                self.labelView.isHidden = false
            }
            }
            
            self.loadBoards()
            
            if self.collectionView.numberOfItems(inSection: 0) > 0 {
            
            //self.collectionView.deleteItems(at: [self.indexPath!])
                
            //swipedCell?.delete(Any?.self)
        
            do {
                           let realm = try Realm()
                           
                guard let objectToDelete =  self.boards?[self.indexPath!.row] else {return print("cannot delete")}
                
                let count = self.boards?.count ?? 0
                
                let objectIndex = objectToDelete.sortingIndex + 1
                           
                           try realm.write {
                            
                            if objectToDelete.sortingIndex != count - 1,  self.collectionView.numberOfItems(inSection: 0) > 0 {

                                                for n in objectIndex...Int(count - 1) {
                                                let index = n
                                                    
                                                    if objectToDelete.sortingIndex < index {

                                                    let objects = self.boards?[index].sortingIndex
                                                                
                                                    let newIndex = objects! - 1
                                                               
                                                    self.boards?[index].sortingIndex = newIndex
                                }
                                            }
                }
                            self.collectionView.deleteItems(at: [self.indexPath!])
                            realm.delete(objectToDelete)
                        
                           }
                
                           
                       }catch {
                           print("there is error with delete Realm object ! : \(error)")
                       }
                
            }
                
            }
        
        //handleGesture2(gesture: gesture)
           
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        firstAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        //present(alert, animated: true, completion: nil)
        
        self.present(alert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
            
       }
       
    }
    
    
}
    
extension FirstViewController: UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
//        cell.setData(text: self.dataArray[indexPath.row])
//
//        return cell
        
        //let cell = super.collectionView(collectionView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = boards?[indexPath.row].name ?? "No Boards added yet"
        
        cell.layer.borderColor = UIColor.init(named: "FontColor")?.cgColor
        cell.layer.borderWidth = 1
        
        cell.isUserInteractionEnabled = true
        
        let gRL = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
        
        gRL.direction = .left
        
        cell.addGestureRecognizer(gRL)
        
        let gRR = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
        
        gRR.direction = .right
        
        cell.addGestureRecognizer(gRR)
        
        
        return cell
        
    }
    
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            //return self.dataArray.count
            
            return boards?.count ?? 1
            
    }
    
    func save(board: Board) {
        do {
            try realm.write {
                realm.add(board)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        collectionView.reloadData()
    }
    
    func loadBoards() {
        
        boards = realm.objects(Board.self).sorted(byKeyPath: "sortingIndex")
        collectionView.reloadData()
    }
    
    func updateModel(at indexPath: IndexPath) {
        if let boardForDeletion = self.boards?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(boardForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
        
}

extension FirstViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //let width = self.calculateWith()

        return CGSize(width: 230, height: 170)

    }

    func calculateWith() -> CGFloat {

        let estimatedWidth = CGFloat(estimateWidth)

        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))

        let margin = CGFloat(cellMarginSize * 2)

        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount

        return width

    }

}

extension FirstViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.dataArray[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }


}

extension FirstViewController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {

        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }

        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }

        loadBoards()


    }


}





