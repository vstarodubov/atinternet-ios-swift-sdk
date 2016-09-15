/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  Cart.swift
//  Tracker
//

import UIKit

public class Cart: BusinessObject {
    
    /// Cart identifier
    public var cartId: String = ""
    
    /// Cart products
    public lazy var products: Products = Products(cart: self)
    
    /// Product list
    lazy var productList: [String: Product] = [String: Product]()
    
    /**
    Set a cart
    - parameter cartId: the cart identifier
    - returns: the cart
    */
    public func set(_ cartId: String) -> Cart {
        if(cartId != self.cartId) {
            products.removeAll()
        }
        
        self.cartId = cartId
        self.tracker.businessObjects[self.id] = self

        return self
    }
    
    /**
    Unset the cart
    */
    public func unset() {
        self.cartId = ""
        self.products.removeAll()
        
        self.tracker.businessObjects.removeValue(forKey: self.id)
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        _ = tracker.setParam("idcart", value: cartId)
                
        var i = 1
        let encodingOption = ParamOption()
        encodingOption.encode = true
        for(_, product) in productList {
            _ = tracker.setParam("pdt" + String(i), value: product.buildProductName(), options:encodingOption)
            
            if let optQuantity = product.quantity {
                _ = tracker.setParam("qte" + String(i), value: optQuantity)
            }
            
            if let optUnitPriceTaxFree = product.unitPriceTaxFree {
                _ = tracker.setParam("mtht" + String(i), value: optUnitPriceTaxFree)
            }
            
            if let optUnitPriceTaxIncluded = product.unitPriceTaxIncluded {
                _ = tracker.setParam("mt" + String(i), value: optUnitPriceTaxIncluded)
            }
            
            if let optDiscountTaxFree = product.discountTaxFree {
                _ = tracker.setParam("dscht" + String(i), value: optDiscountTaxFree)
            }
            
            if let optDiscountTaxIncluded = product.discountTaxIncluded {
                _ = tracker.setParam("dsc" + String(i), value: optDiscountTaxIncluded)
            }
            
            if let optPromotionalCode = product.promotionalCode {
                _ = tracker.setParam("pcode" + String(i), value: optPromotionalCode, options:encodingOption)
            }
            
            i += 1
        }
    }
}
