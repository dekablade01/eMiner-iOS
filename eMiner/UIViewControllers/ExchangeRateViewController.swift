//
//  ExchangeRateViewController.swift
//  eMiner
//
//  Created by Issarapong Poesua on 6/14/2560 BE.
//  Copyright © 2560 Issarapong Poesua. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

class ExchangeRateViewController: BlueNavigationBarViewController {

    @IBOutlet weak var fromContainerView: UIView!
    @IBOutlet weak var toContainerView: UIView!
    @IBOutlet weak var fromCurrencySymbolContainerView: UIView!
    private var didPerformedFirstSegueFromStoryboard = false
    
    var openFromCurrencySegue: String { return "openFromCurrencySegue"}
    var openToCurrencySegue:String { return "openToCurrencySegue" }
    
    @IBOutlet weak var toCurrencySymbolContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var amountNumberTextField: UITextField!
    var disposeBag = DisposeBag()
    var amount: Double {
        get { return Double(amountNumberTextField.text!) ?? 0.0 }
        set { amountNumberTextField.text = "\(newValue)"}
    }
    @IBOutlet weak var resultTextLabel: UILabel!
    
    var result: Double {
        get { return Double(resultTextLabel.text!) ?? 0.0 }
        set { resultTextLabel.text = "\(newValue)" }
    }
    
    @IBOutlet weak var fromCurrencyLabel: UILabel!
    @IBOutlet weak var toCurrencyLabel: UILabel!
    var currencies: [CurrencyModel] { return RemoteFactory.remoteFactory.remoteCurrencies.currencies } 

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setContainerColor()
        result = SingletonExchangeRate.sharedInstance.price
        amountNumberTextField.delegate = self
        amountNumberTextField.becomeFirstResponder()
        
        SingletonExchangeRate.sharedInstance.fromCurrencyDidChangeHandler = {
            self.updateFromTextField(fromSymbol: $0)
        }
        SingletonExchangeRate.sharedInstance.toCurrencyDidChangeHandler = {
            
            self.updateToTextField(toSymbol: $0)
            
        }
        let fromSymbol = "BTC"
        let toSymbol = "USD"
        RemoteFactory
            .remoteFactory
            .remoteCurrencyCalculator
            .convert(from: fromSymbol, to: toSymbol)
            .subscribe(onNext: { SingletonExchangeRate
                .sharedInstance.price = $0 } )
            .addDisposableTo(disposeBag)
        
        
        amountNumberTextField
            .addTarget(self,
                       action: #selector(ExchangeRateViewController.valueDidChange),
                       for: .editingChanged)
        
 
        
        updateFromTextField(fromSymbol: fromSymbol)
        updateToTextField(toSymbol: toSymbol)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?)
    {
    
        if (segue.identifier == openToCurrencySegue ||
            segue.identifier == openFromCurrencySegue)
        {
            let navigationController = segue.destination as? UINavigationController
            
            let viewController = navigationController?.viewControllers.first as? ExchangeRateCurrencyPickerViewController
            
            
            viewController?.didDismissViewControllerHandler = {
                self.calculate()
            }
            self.didPerformedFirstSegueFromStoryboard = false

        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (didPerformedFirstSegueFromStoryboard == false)
        {
            didPerformedFirstSegueFromStoryboard = true
            performSegue(withIdentifier: identifier, sender: self)
            return false
        }
        else { return true }
    }

    func valueDidChange(textField: UITextField)
    {
        calculate()
    }
    
    func calculate()
    {
        let price = SingletonExchangeRate.sharedInstance.price
                
        let result = price * amount
        
        self.result = result
        
    }
    
    @IBAction func pressedFromCurrency(_ sender: UIButton)
    {
        SingletonExchangeRate
            .sharedInstance
            .currencyExchangeRateCaller = .from
        
    }

    @IBAction func pressedToCurrency(_ sender: UIButton)
    {
        SingletonExchangeRate
            .sharedInstance
            .currencyExchangeRateCaller  = .to
    }
    func updateFromTextField(fromSymbol: String)
    {
        let fromIndex = RemoteFactory.remoteFactory.remoteCurrencies.isAtIndex(symbol: fromSymbol)
        
        fromCurrencyLabel.text = currencies[fromIndex].symbol + " ▼"
    }
    
    func updateToTextField(toSymbol: String)
    {
        
        let toIndex = RemoteFactory.remoteFactory.remoteCurrencies.isAtIndex(symbol: toSymbol)
        
        toCurrencyLabel.text = currencies[toIndex].symbol + " ▼"
    }
    
    func setContainerColor()
    {
        separatorView.backgroundColor = Color.blue.darken3
        
        fromContainerView.backgroundColor = Color.blue.darken1
        fromCurrencySymbolContainerView.backgroundColor = Color.blue.base
        
        toContainerView.backgroundColor = Color.blue.lighten2
        toCurrencySymbolContainerView.backgroundColor = Color.blue.lighten3
        
    }
}

extension ExchangeRateViewController : UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        view.endEditing(true)
    }
    
    
}