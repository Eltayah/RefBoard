//
//  SubscribtionProducts.swift
//  RefBoard
//
//  Created by Elijah Altayer on 06.04.2020.
//  Copyright © 2020 Elijah Altayer. All rights reserved.
//

import Foundation

public struct SubscribtionProducts {
  public static let monthlySub = "AdRemoval_01"
  public static let monthly2Sub = "AdRemoval_02"
  public static let yearlySub = "AdRemoval_03"
  public static let store = IAPManager(productIDs: SubscribtionProducts.productIDs)
    private static let productIDs: Set<ProductID> = [SubscribtionProducts.monthlySub, SubscribtionProducts.monthly2Sub, SubscribtionProducts.yearlySub]
}

public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
