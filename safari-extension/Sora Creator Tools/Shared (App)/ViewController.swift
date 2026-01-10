//
//  ViewController.swift
//  Shared (App)
//
//  Created by Andrew Williamson on 12/4/25.
//

import WebKit
import SafariServices

#if os(iOS)
import UIKit
typealias PlatformViewController = UIViewController
#elseif os(macOS)
import Cocoa
typealias PlatformViewController = NSViewController
#endif

let extensionBundleIdentifier = "com.soracreator.tools.extension"

class ViewController: PlatformViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self
#if os(iOS)
        self.webView.scrollView.isScrollEnabled = false
#endif

        self.webView.configuration.userContentController.add(self, name: "controller")

        self.webView.loadFileURL(Bundle.main.url(forResource: "Main", withExtension: "html")!, allowingReadAccessTo: Bundle.main.resourceURL!)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
#if os(iOS)
        webView.evaluateJavaScript("show('ios')")
#elseif os(macOS)
        webView.evaluateJavaScript("show('mac')")

        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            guard let state = state, error == nil else {
                // Insert code to inform the user that something went wrong.
                return
            }

            DispatchQueue.main.async {
                if #available(macOS 13, *) {
                    webView.evaluateJavaScript("show('mac', \(state.isEnabled), true)")
                } else {
                    webView.evaluateJavaScript("show('mac', \(state.isEnabled), false)")
                }
            }
        }
#endif
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let command = message.body as? String else { return }
#if os(macOS)
        if command == "open-preferences" {
            SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
                guard error == nil else {
                    // Insert code to inform the user that something went wrong.
                    return
                }

                DispatchQueue.main.async {
                    NSApp.terminate(self)
                }
            }
        }
#elseif os(iOS)
        if command == "open-settings" {
            openSafariExtensionSettings()
        }
#endif
    }

#if os(iOS)
    private func openSafariExtensionSettings() {
        let safariExtensionsURL = URL(string: "App-Prefs:root=SAFARI&path=WEB_EXTENSIONS")
        let fallbackURL = URL(string: UIApplication.openSettingsURLString)
        let application = UIApplication.shared

        if let safariURL = safariExtensionsURL, application.canOpenURL(safariURL) {
            application.open(safariURL, options: [:], completionHandler: nil)
            return
        }

        if let fallbackURL = fallbackURL {
            application.open(fallbackURL, options: [:], completionHandler: nil)
        }
    }
#endif

}
