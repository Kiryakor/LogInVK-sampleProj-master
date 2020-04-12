import UIKit
import SwiftyVK

class ViewController: UIViewController, SwiftyVKDelegate {
    
    var window: UIWindow?
    let appID = "7292437"
    let scopes: Scopes = [.offline]
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return scopes
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        self.present(viewController, animated: true)
    }
    
    @objc func authorize() {
        VK.setUp(appId: appID, delegate: self)
        
        VK.sessions.default.logIn(onSuccess: { info in
            DispatchQueue.main.async {
                let vc = SecondViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        },
        onError: { error in
            print("SwiftyVK: authorize failed with", error)
        })
    }

    let LogInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("Войти через VK", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(authorize), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        view.addSubview(LogInButton)
        firstLayerLogIn()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func firstLayerLogIn() {
        //Constraints for log in button
        LogInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        LogInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        LogInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        LogInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}

