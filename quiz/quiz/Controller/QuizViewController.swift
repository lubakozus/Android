//
//  ViewController.swift
//  Quiz
//
//  Created by ILLIA HARKAVY on 19.11.20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleMobileAds

class QuizViewController: UIViewController {

    @IBOutlet weak var topScoreLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var interstitial: GADInterstitial!
    var currentUserListenerRegistration: ListenerRegistration?
    var currentUser: User? {
        didSet {
            if let currentUser = currentUser {
                topScoreLabel.text = "\(currentUser.score)"
                nameTextField.text = currentUser.name
            } else {
                topScoreLabel.text = nil
                nameTextField.text = nil
            }
        }
    }
    var topUsers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
        
        Auth.auth().addStateDidChangeListener { [unowned self] _, _ in
            currentUserListenerRegistration?.remove()
            guard let user = Auth.auth().currentUser else {
                currentUser = nil
                requestAuth()
                return
            }
            currentUserListenerRegistration = Firestore.firestore().collection("users").document(user.uid).addSnapshotListener { [unowned self] snapshot, error in
                if let data = snapshot?.data() {
                    currentUser = try? Firestore.Decoder().decode(User.self, from: data)
                } else {
                    let data = try! Firestore.Encoder().encode(User(name: "Player", score: 0))
                    Firestore.firestore().collection("users").document(user.uid).setData(data)
                    currentUser = nil
                }
            }
        }
        
        Firestore.firestore().collection("users").order(by: "score", descending: true).limit(to: 100).addSnapshotListener { [unowned self] snapshot, error in
            if let snapshot = snapshot {
                topUsers = snapshot.documents.compactMap({ try? Firestore.Decoder().decode(User.self, from: $0.data()) })
            } else if let error = error {
                let alert = UIAlertController(title: "Error loading top players", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true)
            }
        }
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            if let data = try? Data(contentsOf: URL(string: "https://opentdb.com/api.php?amount=10")!), let response = try? JSONDecoder().decode(TriviaResponse.self, from: data) {
                DispatchQueue.main.async {
                    let gameViewController = GameViewController.instantiate()
                    gameViewController.isModalInPresentation = true
                    gameViewController.questions = response.results
                    gameViewController.delegate = self
                    let navigationController = UINavigationController(rootViewController: gameViewController)
                    navigationController.navigationBar.barStyle = .black
                    present(navigationController, animated: true)
                }
            }
        }
    }
    
    @IBAction func nameTextFieldEditingDidEnd(_ sender: UITextField) {
        guard let name = nameTextField.text, let userId = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("users").document(userId).updateData([ "name": name ])
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        requestAuth()
    }
    
    func requestAuth() {
        let alert = UIAlertController(title: "Welcome to Quiz", message: nil, preferredStyle: .alert)
        let signIn = UIAlertAction(title: "Sign In", style: .default) { [unowned self] _ in
            requestSignIn()
        }
        let signUp = UIAlertAction(title: "Sign Up", style: .default) { [unowned self] _ in
            requestSignUp()
        }
        alert.addAction(signIn)
        alert.addAction(signUp)
        present(alert, animated: true, completion: nil)
    }
    
    func requestSignIn() {
        let alert = UIAlertController(title: "Sing In", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "E-mail"
            textField.keyboardType = .emailAddress
        }
        alert.addTextField { textField in
            textField.placeholder = "Pasword"
            textField.isSecureTextEntry = true
        }
        let signIn = UIAlertAction(title: "Sign In", style: .default) { [unowned self] _ in
            
            let email = alert.textFields?[0].text ?? ""
            let password = alert.textFields?[1].text ?? ""
            
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if Auth.auth().currentUser == nil {
                    let alert = UIAlertController(title: "Error signing in", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel) { _ in
                        requestSignIn()
                    }
                    alert.addAction(ok)
                    present(alert, animated: true)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
            requestAuth()
        }
        alert.addAction(signIn)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func requestSignUp() {
        let alert = UIAlertController(title: "Sing Up", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "E-mail"
            textField.keyboardType = .emailAddress
        }
        alert.addTextField { textField in
            textField.placeholder = "Pasword"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { textField in
            textField.placeholder = "Confirm Pasword"
            textField.isSecureTextEntry = true
        }
        let signIn = UIAlertAction(title: "Sign In", style: .default) { [unowned self] _ in
            
            let email = alert.textFields?[0].text ?? ""
            let password = alert.textFields?[1].text ?? ""
            let confirmation = alert.textFields?[2].text ?? ""
            
            guard password == confirmation else {
                let alert = UIAlertController(title: "Passwords do not match", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel) { _ in
                    requestSignUp()
                }
                alert.addAction(ok)
                present(alert, animated: true)
                return
            }
            Auth.auth().createUser(withEmail: email, password: password) { _, error in
                if let error = error {
                    let alert = UIAlertController(title: "Error signing up", message: error.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel) { _ in
                        requestSignUp()
                    }
                    alert.addAction(ok)
                    present(alert, animated: true)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
            requestAuth()
        }
        alert.addAction(signIn)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension QuizViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "score", for: indexPath)
        let user = topUsers[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = "\(user.score)"
        return cell
    }
}

extension QuizViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension QuizViewController: GameViewControllerDelegate {
    
    func gameViewController(_ gameViewController: GameViewController, didFinishWithScore score: Int) {
        guard let currentUser = currentUser, let userId = Auth.auth().currentUser?.uid else {
            return
        }
        if currentUser.score < score {
            Firestore.firestore().collection("users").document(userId).updateData([ "score": score ])
        }
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
}
