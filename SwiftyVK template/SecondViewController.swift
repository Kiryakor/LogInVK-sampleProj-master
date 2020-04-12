import UIKit
import SwiftyVK
import SwiftyJSON

class SecondViewController: UIViewController {
    var window: UIWindow?
    
    let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    let userPicture: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .systemGray3
        image.layer.cornerRadius = 75
        image.clipsToBounds = true
        return image
    }()
    
    let userName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let userDomain: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let userLocation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    let logOut: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitle("Выйти", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(logOutFunc), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func logOutFunc() {
        VK.sessions.default.logOut()
        
        DispatchQueue.main.async {
            self.view.window?.rootViewController = ViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        view.addSubview(logOut)
        view.addSubview(cardView)
        cardView.addSubview(userDomain)
        cardView.addSubview(userPicture)
        cardView.addSubview(userName)
        cardView.addSubview(userLocation)
        
        requestToAPI()
        firstLayer() //constraints
        secondLayerOnCard() //constraints
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func firstLayer() {
        //card view constraints
        cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cardView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        cardView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        //log out button constraints
        logOut.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logOut.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 10).isActive = true
        logOut.widthAnchor.constraint(equalTo: cardView.widthAnchor).isActive = true

    }
    
    private func secondLayerOnCard() {
        //user picture constraints
        userPicture.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        userPicture.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20).isActive = true
        userPicture.widthAnchor.constraint(equalToConstant: 150).isActive = true
        userPicture.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //user name constraints
        userName.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        userName.topAnchor.constraint(equalTo: userPicture.bottomAnchor, constant: 10).isActive = true
        //domain constraints
        userDomain.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        userDomain.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 2).isActive = true
        //location constraints
        userLocation.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        userLocation.topAnchor.constraint(equalTo: userDomain.bottomAnchor, constant: 15).isActive = true
    }
    
    private func requestToAPI() {
        VK.sessions.default.config.language = .ru
        VK.API.Users.get([.fields: "domain, bdate, photo_200, city, activity,"])
            .onSuccess {
                let response = try JSONSerialization.jsonObject(with: $0)
                let json = JSON(response)
                
                print(json)
                
                let url = URL(string: json[0]["photo_200"].stringValue)
                let data = try? Data(contentsOf: url!)
            
                DispatchQueue.main.async {
                    self.userDomain.text = "@" + json[0]["domain"].stringValue
                    self.userName.text = json[0]["first_name"].stringValue + " " + json[0]["last_name"].stringValue
                    self.userLocation.text = "📍" + json[0]["city"]["title"].stringValue
                    
                    if let imageData = data {
                        self.userPicture.image = UIImage(data: imageData)
                    }
                    if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url!)) {
                        self.userPicture.image = UIImage(data: cachedResponse.data)
                        return
                    }
                }
            }
        .onError {_ in
            print("Request failed with error: ($0)")
        }
        .send()
    }
}
