//
//  LKZQWebVC.swift
//  Linking
//
//  Created by HZQ on 2017/2/21.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit
import WebKit

class LKZQWebVC: ZQViewController,WKNavigationDelegate,WKUIDelegate,UIWebViewDelegate {

    public var  holderTitle:String = "" //default is document.title from webview.
    public var  showErrorInside:Bool = false  //default is No,show errer as alertview.
    public var  initralUrl:URL?
    public var  customCookies:[String:String] = [:]
   
    private let  cookieExp:Double = 31536000// 3600 * 24 * 365;//一年
    
    private var  commonJS:String = ""
    private var  hadFailOnce:Bool = false
//    private var  webView:WKWebView = WKWebView.init()   //注意：使用WKWebView会导致iOS9下莫名崩溃
    private var webView:UIWebView = UIWebView.init()
    
//    private var  progressView:UIProgressView = UIProgressView.init()

    override func loadView() {
//        self.customCookies.updateValue(RequestManager.shared.cookie__pvs(), forKey: "__pvs")// ["__pvs":RequestManager.shared.cookie__pvs()]
        
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorMainBg
        self.addbackButton()

        do{
            self.commonJS = try  String.init(contentsOfFile: Bundle.main.path(forResource: "myCommonJS", ofType: "js") ?? "")
        }catch {
            debugPrint("init commonJS error:\(error.localizedDescription)")
        }
        
        let dateExp:NSDate = NSDate.init(timeIntervalSinceNow: self.cookieExp)
        let dateExpString = String.init(format: "%@", dateExp)
        let domain = self.initralUrl?.host ?? "linking.im"
        let originalUrl = self.initralUrl?.absoluteString ?? "https://linking.im/"
        for obj in self.customCookies{
           self.commonJS = self.commonJS.appendingFormat("\n   setCookie('%@','%@',%d);", obj.key,obj.value,self.cookieExp)
            
            let cookieObj = HTTPCookie.init(properties: [.name:obj.key,
                                                         .value:obj.value,
                                                         .expires:dateExpString,
                                                         .domain:domain,
                                                         .path:"/",
                                                         .originURL:originalUrl])
            
//            debugPrint("set cookie: \(cookieObj)  \(obj.key)  \(obj.value)  \(domain)  \(originalUrl)  \(dateExpString)")
            if cookieObj != nil {
                HTTPCookieStorage.shared.setCookie(cookieObj!)
            }
        }
        
        
        
        let cookieScript = WKUserScript.init(source: self.commonJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)

        let userContentController = WKUserContentController.init()
        userContentController.addUserScript(cookieScript)
        
        let webViewConfig = WKWebViewConfiguration.init()
        webViewConfig.userContentController = userContentController
        
        self.webView = UIWebView.init()
        self.webView.frame = .init(x: 0, y: 0, width:SCREEN_WIDTH(), height: SCREEN_HEIGHT() - 64)
        self.webView.stringByEvaluatingJavaScript(from: self.commonJS)
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
//        self.webView = WKWebView.init(frame: .init(x: 0, y: 0, width:SCREEN_WIDTH(), height: SCREEN_HEIGHT() - 64), configuration: webViewConfig)
//        self.webView.navigationDelegate = self;
//        self.webView.uiDelegate = self;
//        self.webView.scrollView.delegate = self;
//        self.webView.contentScaleFactor = 1.0;
        
        self.view.addSubview(self.webView)
        
//        self.progressView.frame = .init(x: 0, y: 0, width: self.view.width, height: 1)
//        self.progressView.trackTintColor = UIColor.white
//        self.progressView.backgroundColor = UIColor.white
//        self.view.addSubview(self.progressView)
        
        //webview observer keypath: estimatedProgress、title、loading

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if self.holderTitle.length <= 0{
            self.title = "加载中..."
        }else{
            self.title = self.holderTitle
        }

        let urlRequest = URLRequest.init(url: self.initralUrl ?? URL.init(string: "linking://none")!)
//        self.webView.load(urlRequest)
        self.webView.loadRequest(urlRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK:UIWebview delgegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if self.holderTitle.length <= 0 && webView.stringByEvaluatingJavaScript(from: "document.title") != nil {
            self.title = webView.stringByEvaluatingJavaScript(from: "document.title")!
        }
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        //异步加载被取消时 返回 NSURLErrorCancelled，对于这种错误不做处理。
        if error.localizedDescription.contains("-999"){//error.code == NSURLErrorCancelled{
            return
        }
        
        if hadFailOnce {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if self.holderTitle.length <= 0 && webView.stringByEvaluatingJavaScript(from: "document.title") != nil {
                self.title = webView.stringByEvaluatingJavaScript(from: "document.title")!
            }
            
//            SVProgressHUD.showError(withStatus: error.localizedDescription)
            //只有载入初始url时才需要提示错误，否则问题不好处理。
            if webView.request?.url?.absoluteString == initralUrl?.absoluteString{
                if self.showErrorInside{
                    let htmlError = "<head> <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/> <title>Error</title> <head><body>\(error.localizedDescription)</body>"
                    webView.loadHTMLString(htmlError, baseURL: nil)
                }else{
                    UIAlertController.alert(sender: self, title: "Error", message: error.localizedDescription, buttons: ["OKT👌"], clickHandler: { (title , index ) in
                    })
                }
            }
        }else{
            self.hadFailOnce = true
            webView.reload()
        }
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlString = request.url?.absoluteString ?? ""
        
        debugPrint("webview request :", urlString)
        
//        if (urlString.lowercased().hasPrefix("linking://")){
//            if urlString.contains(InnerViewURL.closeWebView.completeAddress())
//            {
//                self.touchBackButton()
//            }else{
//                urlString.openInWebView()
//            }
//            return false
//        }
//        if (urlString.lowercased().contains("browser=1")){  //B1.3.6
//            urlString.openOutWebView()
//            return false
//        }
        
        return true
    }
    
    
    //MARK: WKWebview navigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if self.holderTitle.length <= 0 {
            self.holderTitle = webView.title ?? ""
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("WK did fail:\(error.localizedDescription)")
    
        if hadFailOnce {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if self.holderTitle.length <= 0 {
                self.holderTitle = webView.title ?? ""
            }
            
            if self.showErrorInside{
                let htmlError = "<head> <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/> <title>Error</title> <head><body>\(error.localizedDescription)</body>"
                webView.loadHTMLString(htmlError, baseURL: nil)
            
            }else{
                UIAlertController.alert(sender: self, title: "Error", message: error.localizedDescription, buttons: ["OK👌"], clickHandler: { (title , index ) in
                })
            }
            
        }else{
            self.hadFailOnce = true
            webView.reload()
        }
    }
    
    //MARK:是否允许跳转
    //当客户端收到服务器的响应头，根据response相关信息，可以决定这次跳转是否可以继续进行。
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    //根据webView、navigationAction相关信息决定这次跳转是否可以继续进行,这些信息包含HTTP发送请求，如头部包含User-Agent,Accept
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

