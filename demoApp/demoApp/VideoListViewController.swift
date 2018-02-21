//
//  ViewController.swift
//  demoApp
//
//  Created by nandini on 2/21/18.
//  Copyright © 2018 abc. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit
import youtube_ios_player_helper
import GoogleSignIn

class VideoListViewController: UIViewController,UISearchBarDelegate, UICollectionViewDataSource {
    
    private let reuseIdentifier = "Cell"
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    private var  searchList : [GTLRYouTube_SearchResult] = [];
    @IBOutlet weak var txtSearch: UISearchBar!
    
   
    private let service = GTLRYouTubeService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.delegate = self;
        
        // register the custom cell to the collection view
        self.searchCollectionView.register( UINib(nibName: "videoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier);
        self.searchCollectionView.dataSource = self
        self.service.authorizer =  GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        fetchChannelResource()
        self.navigationItem.hidesBackButton = true
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
            showAlert(title: "Error", message: error.localizedDescription, presenter: self)
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
            showAlert(title: "Error", message: error.localizedDescription , presenter: self)
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
