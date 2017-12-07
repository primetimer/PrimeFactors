//
//  Extensions.swift
//  Numbers
//
//  Created by Stephan Jancar on 03.12.17.
//  Copyright © 2017 Stephan Jancar. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	internal var navh : CGFloat {
		get {
			if let nvc = self.navigationController {
				let nh = nvc.navigationBar.intrinsicContentSize.height
				let sh = UIApplication.shared.statusBarFrame.height
				return nh + sh
			}
			return 64.0
		}
	}
	internal var toolh : CGFloat {
		get {
			if let nvc = self.navigationController {
				return nvc.toolbar.frame.height + 32.0
			}
			return 40.0
		}
	}
}

extension UIView {
	var bottom : CGFloat {
		get {
			return self.frame.origin.y + self.frame.height
		}
		set {
			self.frame.size.height = newValue - self.frame.origin.y
		}
	}
	var right : CGFloat {
		get {
			return self.x + self.width
		}
		set {
			let dif = width - x
			self.frame.size.width = self.x + dif
		}
	}
	var width : CGFloat {
		get {
			return self.frame.width
		}
		set {
			self.frame.size.width = newValue
		}
	}
	var height : CGFloat {
		get {
			return self.frame.height
		}
		set {
			self.frame.size.height = newValue
		}
	}
	
	var x : CGFloat {
		get {
			return self.frame.origin.x
		}
		set {
			self.frame.origin.x = newValue
		}
	}
	var y : CGFloat {
		get {
			return self.frame.origin.y
		}
		set {
			self.frame.origin.y = newValue
		}
	}
}

