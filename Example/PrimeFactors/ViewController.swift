//
//  ViewController.swift
//  PFactors
//
//  Created by primetimer on 10/17/2017.
//  Copyright (c) 2017 primetimer. All rights reserved.
//

import UIKit
import BigInt
import PrimeFactors
import AudioToolbox


enum EnterMode : Int {	case Begin, Enter, Finished }

class ViewController: UIViewController, ProtShowResult {
	private var entermode = EnterMode.Begin
	private var _shiftmode : Bool = false
	private var shiftmode : Bool {
		set { _shiftmode = newValue; ShowButtons() }
		get { return _shiftmode }
	}
	
	private var rpnlist : [RPNCalc] = [RPNCalc()]
	private var rpn : RPNCalc {
		get { return rpnlist[0] }
	}
	private var p : BigUInt = 1
	private let rho = PrimeFaktorRho()
	private let shank = PrimeFactorShanks()
	private let lehman = PrimeFactorLehman()
	
	private var uistate = UILabel()
	private var uistack : [UILabel] = []
	private var uistackdesc : [UILabel] = []
	private var uiback = CalcButton(type: .Undefined)
	private var uiclx = CalcButton(type: .Undefined)
	private var uienter = CalcButton()
	private var uipreview = CalcButton()
	private var uiundo = CalcButton(type : .Undefined)
	private let uishift = CalcButton()
	private let uiesc = CalcButton(type : .Undefined)
	private let uiinfo = CalcButton(type : .Undefined)
	private var buttonarr : [CalcButton] = []
	private var uiinfotext = InfoView()
	
	//Create Button for Calc Action
	func CreateCalcButton(str: String, type : CalcType) {
		let b = CalcButton(type: type)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.addTarget(self, action: #selector(CalcAction), for: .touchUpInside)
	}
	
	//Create Button when shift is activated
	private func CreateCalcButtonShift(str: String, type : CalcType, unshift: CalcButton) {
		let b = CalcButton(type: type)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.setTitleColor(.yellow, for: .normal)
		b.addTarget(self, action: #selector(CalcAction), for: .touchUpInside)
		b.titleLabel?.font = b.titleLabel?.font.withSize(14)
		unshift.shiftbutton = b
		b.isHidden = true
	}
	private func CreateCalcButtonShift(str: String, type : CalcType, unshift: CalcType) {
		if let prevb = GetButtonByType(type: unshift) {
			CreateCalcButtonShift(str: str, type: type, unshift: prevb)
		}
	}
	
	//Find a button by Calculation Type
	private func GetButtonByType(type: CalcType) -> CalcButton? {
		for b in buttonarr {
			if b.type == type {
				return b
			}
		}
		return nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		ShowStack()
		ShowButtons()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.black
		
		//The Number Pad
		for i in 0...9 {
			let button = CalcButton()
			ui_num.append(button)
			button.setTitle(String(i), for: .normal)
			view.addSubview(button)
			button.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
			buttonarr.append(ui_num[i])
		}
		
		view.addSubview(uistate)	//State of calculation
		
		//UI for the RPN-Registers
		for _ in 0...3 {
			let stacklabel = UILabel()
			let stackdesc = UILabel()
			uistack.append(stacklabel)
			uistackdesc.append(stackdesc)
			view.addSubview(stacklabel)
			view.addSubview(stackdesc)
		}
		
		//UI for input and utilities
		view.addSubview(uiback)
		uiback.setTitle("⌫", for: .normal)
		uiback.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uiback.shiftbutton = uiclx
		view.addSubview(uiclx)
		uiclx.setTitle("CLR", for: .normal)
		uiclx.addTarget(self, action: #selector(ClearAction), for: .touchUpInside)
		uiclx.isHidden = true
		
		view.addSubview(uipreview)
		view.addSubview(uienter)
		view.addSubview(uishift)
		view.addSubview(uiesc)
		view.addSubview(uiundo)
		view.addSubview(uiinfo)
		view.addSubview(uiinfotext)
		uiinfotext.isHidden = true
		
		uiundo.setTitle("Undo", for: .normal)
		uiundo.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uienter.setTitle("Enter", for: .normal)
		uienter.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uipreview.setTitle("View #", for: .normal)
		uipreview.addTarget(self, action: #selector(PreviewAction), for: .touchUpInside)
		uishift.setTitle(("⇧"), for: .normal)
		uishift.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uiesc.setTitle(("ESC"), for: .normal)
		uiesc.addTarget(self, action: #selector(EscapeAction), for: .touchUpInside)
		uiinfo.setTitle("ℹ︎", for: .normal)
		uiinfo.addTarget(self, action: #selector(InfoAction), for: .touchUpInside)
		
		buttonarr.append(uienter)
		
		//UI for Functions
		CreateCalcButton(str: "LastX", type: .LastX)
		CreateCalcButton(str: "+", type: .Plus)
		CreateCalcButton(str: "-", type: .Minus)
		CreateCalcButton(str: "*", type: .Prod)
		CreateCalcButton(str: "/", type: .Divide)
		CreateCalcButton(str: "→π", type: .PNext)
		CreateCalcButtonShift(str: "→ππ", type: .Twin,unshift : .PNext)
		CreateCalcButton(str: "π←", type: .PPrev)
		CreateCalcButtonShift(str: "→2π+1", type: .SoG,unshift : .PPrev)
		CreateCalcButton(str: "x*()", type: .Factor)
		CreateCalcButtonShift(str: "p*q", type: .Factors,unshift : .Factor)
		CreateCalcButton(str: "squfof", type: .Squfof)
		CreateCalcButton(str: "→p", type: .Sto1)
		CreateCalcButtonShift(str: "←p", type: .Rcl1,unshift : .Sto1)
		CreateCalcButton(str: "→q", type: .Sto2)
		CreateCalcButtonShift(str: "←q", type: .Rcl2,unshift : .Sto2)
		CreateCalcButton(str: "→r", type: .Sto3)
		CreateCalcButtonShift(str: "←r", type: .Rcl3,unshift : .Sto3)
		CreateCalcButton(str: "ρ", type: .Rho)
		CreateCalcButton(str: "a²-b²", type: .Lehman)
		CreateCalcButton(str: "x<>y", type: .Swap)
		CreateCalcButton(str: "↓", type: .Pop)
		CreateCalcButton(str: "%", type: .Mod)
		CreateCalcButton(str: "gcd", type: .gcd)
		CreateCalcButton(str: "y^x", type: .Pow)
		CreateCalcButtonShift(str: "z^y%x", type: .PowMod, unshift: .Pow)
		CreateCalcButton(str: "#", type : .Hash)
		CreateCalcButtonShift(str: "Rnd #", type: .Rnd, unshift: .Hash)
		CreateCalcButton(str: "√", type: .sqrt)
		CreateCalcButtonShift(str: "∛", type: .crt, unshift: .sqrt)
		CreateCalcButton(str: "⌘C", type: .CmdC)
		CreateCalcButtonShift(str: "⌘V", type: .CmdV, unshift : .CmdC)
		CreateCalcButton(str: "Sexy", type: .Sexy)
		CreateCalcButton(str: "Cousin", type: .Cousin)
		CreateCalcButton(str: "10^x", type: .TenPow)
		CreateCalcButton(str: "x^2", type: .Square)
		CreateCalcButton(str: "x^3", type: .Cube)
		CreateCalcButton(str: "M(x)", type: .Mersenne)
		uienter.shiftbutton = GetButtonByType(type: .LastX)
		ui_num[0].shiftbutton = GetButtonByType(type: .TenPow)
		ui_num[1].shiftbutton = GetButtonByType(type: .Mersenne)
		ui_num[2].shiftbutton = GetButtonByType(type: .Square)
		ui_num[3].shiftbutton = GetButtonByType(type: .Cube)
		ui_num[4].shiftbutton = GetButtonByType(type: .Cousin)
		ui_num[5].shiftbutton = uipreview
		ui_num[6].shiftbutton = GetButtonByType(type: .Sexy)
		Layout()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	//Digit Buttons
	private var ui_num : [CalcButton] = []
	
	//Size of the Stackview depending on landscape or portrait mode and device type
	private func StackWidth() -> CGFloat {
		let wphone = landscape ? view.frame.width / 2 : view.frame.width
		let wpad = landscape ? view.frame.width * 3 / 5 : view.frame.width
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			return wpad
		case .phone:
			return wphone
		default:
			return wpad
		}
	}
	
	//Size of the Number and Action depending on landscape or portrait mode and device type
	private func GetNumpadFrameWidth() -> CGFloat
	{
		if !landscape { return StackWidth() }
		return self.view.frame.width - StackWidth()
	}
	
	private func LayoutButtonRaster(row : Int, col : Int, button: CalcButton, numcols : Int = 1) {
		let w = GetNumpadFrameWidth()
		let h = view.frame.height
		let x0 = landscape ? StackWidth() + 20 : 20
		let row0 = landscape ? 4 : 0
		let parts = landscape ? 6 : 10
		let wpart = (w-40) / 6
		let hpart = (h-40) / CGFloat(parts)
		let x = x0 + CGFloat(col) * wpart
		let y = 20 + CGFloat(row-row0) * hpart
		let rect = CGRect(x: x, y: y, width: wpart*CGFloat(numcols), height: hpart)
		button.frame = rect
	}
	
	private var landscape : Bool {
		get { return UIDevice.current.orientation.isLandscape }
	}
	
	private func StackHeight() -> CGFloat {
		return CGFloat(visiblestackelems) * RegisterHeight()
	}
	private func RegisterHeight() -> CGFloat {
		let viewh = view.frame.height - 40
		let parts = landscape ? 4.0 : 10.0
		let regh = viewh / CGFloat(parts) * 4 / CGFloat(visiblestackelems)
		return regh
	}
	private func LayoutStack(stackpos: Int, label : UILabel, desc: UILabel) {
		let w = StackWidth()
		let wpart = (w-40) / 6
		let x = CGFloat(20)
		let y = 20 + CGFloat(visiblestackelems - stackpos - 1) * RegisterHeight()
		let descrect = CGRect(x: x, y: y, width: wpart, height : RegisterHeight())
		desc.textAlignment = .center
		desc.frame = descrect
		desc.backgroundColor = UIColor.white.withAlphaComponent(0.2)
		desc.textColor = .white
		let rect = CGRect(x: x+wpart, y: y, width: wpart*5, height: RegisterHeight())
		label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
		label.textAlignment = .right;
		label.numberOfLines = 0;
		label.frame = rect
		label.textColor = .green
		label.isHidden = (stackpos >= visiblestackelems)
		desc.isHidden = (stackpos >= visiblestackelems)
	}
	
	private var visiblestackelems = 4
	private func LayoutStack() {
		let frame = CGRect(x: 20, y: 20, width:StackWidth() - 40.0 , height: StackHeight())
		uiinfotext.frame = frame
		for i in 0..<4 {
			LayoutStack(stackpos : i, label: uistack[i], desc: uistackdesc[i])
		}
	}
	
	//All UI-Elements are manual layouted, not via storyboard
	private func Layout() {
		LayoutStack()
		do {
			let frame0 = uistack[0].frame
			let frame1 = CGRect(x: 20, y:frame0.origin.y + frame0.height, width: frame0.width,height: 20.0)
			uistate.frame = frame1
			uistate.textColor = .red
		}
		for i in 1...9 {
			let col = 1 + (i-1) % 3
			let row = 3 - (i-1) / 3 + uistack.count
			LayoutButtonRaster(row:row, col: col, button: ui_num[i])
		}
		
		LayoutButtonRaster(row:4, col: 0, button: GetButtonByType(type: .Rho)!)
		LayoutButtonRaster(row:4, col: 1, button: GetButtonByType(type: .Lehman)!)
		LayoutButtonRaster(row:4, col: 2, button: GetButtonByType(type: .Squfof)!)
		LayoutButtonRaster(row:4, col: 3, button: GetButtonByType(type: .Hash)!)
		LayoutButtonRaster(row:7, col: 5, button: GetButtonByType(type: .PPrev)!)
		LayoutButtonRaster(row:8, col: 5, button: GetButtonByType(type: .PNext)!)
		LayoutButtonRaster(row:4, col: 4, button: GetButtonByType(type: .Pow)!)
		LayoutButtonRaster(row:7, col: 0, button: GetButtonByType(type: .Swap)!)
		LayoutButtonRaster(row:6, col: 0, button: GetButtonByType(type: .Pop)!)
		LayoutButtonRaster(row:6, col: 5, button: GetButtonByType(type: .Mod)!)
		LayoutButtonRaster(row:5, col: 5, button: GetButtonByType(type: .gcd)!)
		LayoutButtonRaster(row:5, col: 0, button: GetButtonByType(type: .sqrt)!)
		LayoutButtonRaster(row:8, col: 1, button: ui_num[0])
		LayoutButtonRaster(row:8, col: 0, button: uiback)
		LayoutButtonRaster(row:8, col: 0, button: uiclx)
		LayoutButtonRaster(row:9, col: 1, button: GetButtonByType(type: .Sto1)!)
		LayoutButtonRaster(row:9, col: 2, button: GetButtonByType(type: .Sto2)!)
		LayoutButtonRaster(row:9, col: 3, button: GetButtonByType(type: .Sto3)!)
		LayoutButtonRaster(row:8, col: 2, button: uienter,numcols: 2)
		LayoutButtonRaster(row:9, col: 0, button: uishift)
		LayoutButtonRaster(row:4, col: 5, button: uiesc)
		LayoutButtonRaster(row:4, col: 5, button: uiundo)
		LayoutButtonRaster(row:8, col: 4, button: GetButtonByType(type: .Plus)!)
		LayoutButtonRaster(row:7, col: 4, button: GetButtonByType(type: .Minus)!)
		LayoutButtonRaster(row:6, col: 4, button: GetButtonByType(type: .Prod)!)
		LayoutButtonRaster(row:5, col: 4, button: GetButtonByType(type: .Divide)!)
		LayoutButtonRaster(row:9, col: 4, button: GetButtonByType(type: .CmdC)!)
		LayoutButtonRaster(row:9, col: 5, button: uiinfo)
	}
	
	//This timer is used for a blinking busy signal
	private var timer : Timer? = nil
	private var timertoggle : Bool = false
	@objc func TimerUpdate() {
		uistate.textColor = timertoggle ? .red : .gray
		timertoggle = !timertoggle
	}
	
	private func StackName(index : Int) -> String {
		let len = String(rpn[index]).count
		var str = String(index)
		switch index {
		case 0:		str = "X"
		case 1:		str = "Y"
		case 2:		str = "Z"
		case 3:		str = "T"
		default:	break
		}
		if len >= 12 {
			str = str + String(len)
		}
		return str
	}
	
	//Shows some infomration about the state of the registers (uistate) is uirelated
	private func ShowStackState() {
		uiesc.isHidden = asynccalc == nil ? true : false
		uiundo.isHidden = asynccalc == nil ? false : true
		timer?.invalidate()
		uistate.textColor = .red
		switch rpn.stackstate {
		case .stored:		uistate.text = "stored"
		case .cancelled:	uistate.text = "cancelled"
		case .factorized:	uistate.text = "factorized"
		case .valid:		uistate.text = ""
		case .busy:			uistate.text = "busy"
			timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.TimerUpdate), userInfo: nil, repeats: true)
		case .error:		uistate.text = "error"
		case .overflow:		uistate.text = "overflow"
		case .prime:		uistate.text = "prime"
		case .unimplemented:uistate.text = "not implemented"
		case .copied: 		uistate.text = "copied"
		}
	}
	
	private func ShowStack() {
		ShowStackState()
		
		//Calculates the maximal len of the registers
		var (registerrows,registerlen) = (1,1)
		let maxrows = 4 * 2 / visiblestackelems
		for i in 0..<visiblestackelems {
			let val = rpn[i]
			let (valstr,rows) = val.FormatStr(maxrows: maxrows, rowlen: 18)
			let isprime = PrimeCache.shared.IsPrime(p: val)
			uistackdesc[i].textColor = isprime ? .white : .lightGray
			uistackdesc[i].text = StackName(index: i)
			uistack[i].text = valstr
			registerrows = max(registerrows,rows)
			registerlen = max(registerlen,valstr.count)
		}
		
		//Changes font according to the maximal number of rows per register
		var fonth = landscape ? RegisterHeight() * 0.45 - 4 : RegisterHeight() * 0.7 - 4
		fonth = fonth / CGFloat(maxrows)
		if registerrows == 1 && registerlen <= 12 { fonth = fonth * 2 }
		for i in 0..<uistack.count {
			if let font = UIFont(name: "digital-7mono", size: fonth) {
				uistack[i].font = font
				uistackdesc[i].font = font
			}
		}
	}
	
	//UI Related Display of the Action-Pad
	private func ShowButtons(clear : Bool = false) {
		if clear {
			shiftmode = false
			asynccalc?.cancel()
			asynccalc = nil
		}
		if shiftmode {
			uishift.setTitleColor(.yellow, for: .normal)
			uiback.isHidden = true
			uiclx.isHidden = false
		} else {
			uishift.setTitleColor(.white, for: .normal)
			uiback.isHidden = false
			uiclx.isHidden = true
		}
		for b in buttonarr {
			if let shift = b.shiftbutton {
				if shiftmode {
					b.isHidden = true
					shift.isHidden = false
					shift.frame = b.frame
				} else {
					b.isHidden = false
					shift.isHidden = true
				}
			}
		}
	}
	
	//When the Calculation ist started this variable is not nil
	var asynccalc : AsyncCalc? = nil
	
	//Executing all Calculation triggered by Buttons
	@objc func CalcAction(sender: CalcButton!)
	{
		if isInfo {
			uiinfotext.ShowText(type: sender.type)
			return
		}
		//Create Copy of Stack for undo action
		rpnlist.insert(rpn.Copy(), at: 1)
		while rpnlist.count > 10 { rpnlist.remove(at: 10)}
		asynccalc?.cancel()		//Try to cancels previous action s
		rpn.stackstate = .busy	//Blinks in Stackview as long as the calculation needs
		ShowStackState()
		
		//Calculation runs asynchrous (as best as i can)
		let queue = OperationQueue()
		asynccalc = AsyncCalc(rpn: rpn, type: sender.type)
		ShowStackState()
		asynccalc?.resultdelegate = self
		queue.addOperation(asynccalc!)
	}
	
	//Called by asynchronous Calculation on main thread
	internal func ShowCalcResult() {
		asynccalc = nil
		self.entermode = .Finished
		self.ShowStack()
		self.ShowButtons(clear : true)
	}
	
	//Try to stop all pending Calculations. Rely on cooperative design of calculation
	@objc func EscapeAction(sender: CalcButton!) {
		if isInfo {
			uiinfotext.ShowEscapeInfo()
			return
		}
		asynccalc?.cancel()
		asynccalc = nil
		rpn.stackstate = .cancelled
		ShowButtons()
		ShowStackState()
		ShowStack()
	}
	
	//Some useless information about the buttons in the ui
	private var isInfo : Bool = false
	@objc func InfoAction(sender: CalcButton!) {
		if sender == uiinfo {
			isInfo = !isInfo
			if isInfo {
				uiinfo.setTitleColor(.red, for: .normal)
				uiinfotext.isHidden = false
				uiinfotext.ShowGeneral()
			} else {
				uiinfo.setTitleColor(.white, for: .normal)
				uiinfotext.isHidden = true
			}
			return
		}
		if sender == uishift {
			uiinfotext.ShiftInfo()
			return
		}
		if sender.type != .Undefined {
			uiinfotext.ShowText(type: sender.type)
			return
		}
		if ui_num.contains(sender) {
			uiinfotext.ShowNumInfo()
		}
		if sender == uiundo {
			uiinfotext.ShowEscapeInfo()
		}
	}
	
	//Actions for Number Input and related Actions
	@objc func NumberAction(sender: CalcButton!) {
		if isInfo {
			if sender == uiundo { InfoAction(sender: sender); return }
			if sender != uishift { InfoAction(sender: sender); return }
			InfoAction(sender: sender) //Info with uishift and switching keyboard
		}
		if isInfo { InfoAction(sender: sender)}
		if sender == uiback {
			if rpn.stackstate != .valid { rpn.stackstate = .valid }
			else { rpn.x = rpn.x / 10 }
			entermode = .Enter
		}
		rpn.stackstate = .valid
		for i in 0...9 {
			if sender == ui_num[i] {
				switch entermode {
				case .Finished:
					rpn.push()
					rpn.x = BigUInt(i)
					entermode = .Enter
				case .Begin:
					rpn.x = BigUInt(i)
					entermode = .Enter
				case .Enter:
					rpn.x = rpn.x * 10 + BigUInt(i)
				}
			}
		}
		if sender == uienter {
			rpn.push()
			entermode = .Begin
		}
		if sender == uishift {
			shiftmode = !shiftmode
			ShowButtons()
			return
		}
		if sender == uiundo {
			if rpnlist.count > 1 {	rpnlist.remove(at: 0) }
		}
		ShowStackState()
		ShowStack()
		ShowButtons(clear: true)
	}
	
	//Deletes Stack completelye
	@objc func ClearAction() {
		if isInfo { uiinfotext.ShowClearInfo(); return }
		rpn.Clear()
		while rpnlist.count > 1 {	rpnlist.remove(at: 1) }
		ShowStack()
		ShowButtons(clear: true)
	}
	
	@objc func PreviewAction() {
		UIView.animate(withDuration: 2.0, animations: {
			self.visiblestackelems = 5 - self.visiblestackelems	//Toggles between 4 and 1
			self.LayoutStack()
			self.ShowStack()
		})
	}
	
	//Switch Layout when Switching beetween Landscape and Portrail Modud
	override func viewWillLayoutSubviews() {
		Layout()
	}
}

