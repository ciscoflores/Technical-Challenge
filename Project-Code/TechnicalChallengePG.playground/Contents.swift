import UIKit
import MapKit
import PlaygroundSupport

// Basic struct
struct Movie {
    var title: String
    var date: Int
    var location: String
}

// API Endpoint call
func webService(completion: @escaping(_ movies: [Movie]?, _ error: Error?) -> Void){
  
    // By default returns 30 items & are sorted asc by title
    let url = URL(string: "https://data.sfgov.org/resource/wwmu-gmzc.json?$limit=30")!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if error == nil {
            do {
                var moviesArray = [Movie]()
                let movies = try JSONSerialization.jsonObject(with: data!, options: []) as! [AnyObject]
                for movie in movies {
                    moviesArray.append( Movie(title: movie["title"] as! String,
                                              date: Int(movie["release_year"] as?  String ?? "") ?? 0,
                                              location: String(movie["locations"] as? String ?? "") ))
                }
                completion(moviesArray, nil)
            } catch let error {
                completion(nil, error)
            }
        } else {
            completion(nil, error)
        }
    }
    task.resume()
}

// Movies list controller
class MoviesListViewController: UITableViewController {
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame(forAlignmentRect: .zero)
        
        webService {[unowned self] (movies, error) in
            self.movies = movies!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = "\(movies[indexPath.row].title) (\(movies[indexPath.row].date))"
        cell.detailTextLabel?.text = movies[indexPath.row].location
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationMapViewController = LocationMapViewController()
        locationMapViewController.movie = movies[indexPath.row]
        self.navigationController?.pushViewController(locationMapViewController, animated: true)
    }
}

// Local search thru MapKit
func SearchMapLocation(_ movie: Movie, _ mapView: MKMapView) {
    
    // Default values for error and no matches cases
    let secretCoordinate = CLLocationCoordinate2DMake(20.665826, -103.3748947)
    let movieError = Movie(title: movie.title, date: 0, location: "It's a good place to be.")
    
    let locationRequest = MKLocalSearchRequest()
    locationRequest.naturalLanguageQuery = movie.location
    locationRequest.region = mapView.region
    
    let locationSearch = MKLocalSearch(request: locationRequest)
    
    locationSearch.start { (response, error) in
        if error != nil  {
            SetMapViewLocation(movieError, secretCoordinate, mapView)
        } else if response?.mapItems.count == 0 {
            SetMapViewLocation(movieError, secretCoordinate, mapView)
        } else {
            let mapItem = response!.mapItems[0]
            SetMapViewLocation(movie, mapItem.placemark.coordinate, mapView)
        }
    }
}

// Set map location adding the proper annotation
func  SetMapViewLocation(_ movie: Movie, _ coordinate: CLLocationCoordinate2D, _ mapView: MKMapView) {
    
    var mapRegion = MKCoordinateRegion()
    
    let mapRegionSpan = 0.02
    mapRegion.center = coordinate
    mapRegion.span.latitudeDelta = mapRegionSpan
    mapRegion.span.longitudeDelta = mapRegionSpan
    
    mapView.setRegion(mapRegion, animated: true)
    
    let mapAnnotation = MKPointAnnotation()
    mapAnnotation.coordinate = coordinate
    mapAnnotation.title = "Location: \(movie.location)"
    mapAnnotation.subtitle = " From the movie: \(movie.title) (\(movie.date))"
    
    mapView.addAnnotation(mapAnnotation)
}

// Map location view controller, where location search is trigered
class LocationMapViewController: UIViewController {
    
    var movie = Movie(title: "", date: 0, location: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = MKMapView()
        self.view = mapView
        
        SearchMapLocation(movie, mapView)
    }
}

// Present the view controller in the Live View window
let tableView = MoviesListViewController()
let navigationController = UINavigationController(rootViewController: tableView)
PlaygroundPage.current.liveView = navigationController.view
