import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import youtube_ios_player_helper

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate,UISearchBarDelegate, UICollectionViewDataSource {
    
    private let reuseIdentifier = "Cell"
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    private var  searchList : [GTLRYouTube_SearchResult] = [];
    @IBOutlet weak var txtSearch: UISearchBar!
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    
    private let service = GTLRYouTubeService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
       // view.addSubview(output);
        
        // set search text deleagte
        txtSearch.delegate = self;
        
        // register the custom cell to the collection view
        self.searchCollectionView.register( UINib(nibName: "videoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier);
        self.searchCollectionView.dataSource = self
        //self.searchCollectionView.delegate = self
    }
    
    //MARK : google signin implementation
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchChannelResource()
        }
    }
    
    
    // List up to 10 files in Drive
    func fetchChannelResource() {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet,statistics")
        query.identifier = "UC_x5XG1OV2P6uZZ5FSM9Ttw"
        
      
    
        // To retrieve data for the current user's channel, comment out the previous
        // line (query.identifier ...) and uncomment the next line (query.mine ...)
        // query.mine = true
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_ChannelListResponse,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var outputText = ""
        if let channels = response.items, !channels.isEmpty {
            let channel = response.items![0]
            let title = channel.snippet!.title
            let description = channel.snippet?.descriptionProperty
            let viewCount = channel.statistics?.viewCount
            outputText += "title: \(title!)\n"
            outputText += "description: \(description!)\n"
            outputText += "view count: \(viewCount!)\n"
        }
        output.text = outputText
    }
    

    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK : Search implementation
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        resignFirstResponder()
        view.endEditing(true)
        let service = GTLRYouTubeService()
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
      let searchQuery = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        searchQuery.q = self.txtSearch.text
        searchQuery.type = "video"
        searchQuery.maxResults = 10
        service.executeQuery(searchQuery, delegate: self, didFinish: #selector(searchResultWithTicket(ticket:finishedWithObject:error:)))
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.txtSearch.text = ""
        view.endEditing(true)
    }
    
    // Handle the query request result
    @objc func searchResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_SearchListResponse,
        error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if let channels = response.items, !channels.isEmpty {
            // get the GTLRYouTube_SearchResult reponse object array
          self.searchList  = response.items!
            // reload the collection view
            self.searchCollectionView.reloadData()
        }
    }

    
    //MARK: collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchList.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: videoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! videoCollectionViewCell
        // get the instance of the result object
        let result = self.searchList[indexPath.row] ;
        // get the video ID
        let videID = result.identifier?.value(forKey: "videoId") as? String
        // load the player with video id
        cell.videoPlayer.load(withVideoId:videID!);
      
        return cell
    }
}
