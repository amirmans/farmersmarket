//
//  BusinessListTableViewController.h
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import <UIKit/UIKit.h>
#import "ServerInteractionManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GooglePlacesConnection.h"
#import "KASlideShow.h"
#import "SMCalloutView.h"
#import "SMClassicCalloutView.h"
#import "RewardDetailsModel.h"

@class MBProgressHUD;

@interface BusinessListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,GMSMapViewDelegate,CLLocationManagerDelegate> {
    
        MBProgressHUD *HUD;
}

@property (strong, atomic) NSMutableArray *ResponseDataArray;
@property (strong, atomic) NSMutableArray *businessListArray;
@property (strong, atomic) NSMutableArray *filteredBusinessListArray;
@property ( strong, nonatomic) NSMutableArray *markerArray;
@property (strong, nonatomic) SMCalloutView *calloutView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *listBusinessesActivityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *bizTableView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end
