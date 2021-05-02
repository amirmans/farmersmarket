//
//  MarketListTableViewController.h
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
#import "MarketTableViewCell.h"

@class MBProgressHUD;

@interface MarketListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,GMSMapViewDelegate,CLLocationManagerDelegate> {

        MBProgressHUD *HUD;
}

@property (strong, atomic) NSMutableArray *ResponseDataArray;
@property (strong, atomic) NSMutableArray *marketListArray;
@property (strong, atomic) NSMutableArray *filteredMarketListArray;
//@property (strong, nonatomic) NSMutableDictionary *externalLocation;
@property (strong, nonatomic) SMCalloutView *calloutView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *listBusinessesActivityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *corpTableView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;


@end
