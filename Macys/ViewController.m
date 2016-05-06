
#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ResponseRow.h"

static NSString * const BASE_URL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";



@interface ViewController (){
    
    NSMutableArray *tableSectionsAndItsRows;
    
}


- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *results;

@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) NSMutableArray * tableDataArray;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    tableSectionsAndItsRows = [[NSMutableArray alloc] initWithCapacity:1];
    self.searchTextField.delegate = self;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.resultsTableView.dataSource=self;
    self.resultsTableView.delegate=self;
    self.resultsTableView.hidden=false;
    self.resultsTableView.tableFooterView=[[UIView alloc ] init];
    // Dispose of any resources that can be recreated.
}

#pragma Mark tableView delegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return tableSectionsAndItsRows.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [(NSArray *)[(NSDictionary*)tableSectionsAndItsRows[section] valueForKey:@"rowsArray"] count];
    
    return rowCount;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSDictionary *sectionDictionary = (NSDictionary *)tableSectionsAndItsRows[section];
    return [sectionDictionary valueForKey:@"sectionHeader"];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellTobeReused = @"resultCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellTobeReused];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellTobeReused];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    NSDictionary *sectionDictionary = (NSDictionary *)tableSectionsAndItsRows[indexPath.section];
    NSArray *rowsArray = [sectionDictionary valueForKey:@"rowsArray"];
    ResponseRow *rowObject = rowsArray[indexPath.row];
    cell.textLabel.text = rowObject.mainString;
    cell.detailTextLabel.text = rowObject.subString;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (IBAction)search:(id)sender {
        if (self.searchTextField.text != nil && [self.searchTextField.text length] > 0) {
            [self.view endEditing:YES];
            //Using MBProgressHUD to show the progress
            [tableSectionsAndItsRows removeAllObjects];
            tableSectionsAndItsRows = [[NSMutableArray alloc] initWithCapacity:1];
            MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:true];
            progressHUD.labelText = @"Searching";
            progressHUD.userInteractionEnabled = NO;
            self.results.text = self.searchTextField.text;
            AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
            AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
            NSMutableSet *jsonAcceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
            [jsonAcceptableContentTypes addObject:@"text/plain"];
            jsonResponseSerializer.acceptableContentTypes = jsonAcceptableContentTypes;
            manager.responseSerializer = jsonResponseSerializer;
            [manager GET:BASE_URL parameters:@{@"sf": self.searchTextField.text} success:^(AFHTTPRequestOperation * operation, id responseObject) {
                
                NSArray *responseArray = (NSArray *)responseObject;
                if (responseArray.count > 0){
                    [self processResponseToBeShownInTheTable:responseObject];
                    [self.resultsTableView reloadData];
                }else{
                    
                    [self showFailureAlertWithMessage:[NSString stringWithFormat: @"Hey, sorry there is no full form in our data base for '%@'", self.searchTextField.text]];
                    
                }
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                [self.resultsTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
        }else{
            [self showFailureAlertWithMessage:@"Please dont leave the text field empty"];
        }
    }
    
    - (void) processResponseToBeShownInTheTable: (id) responseObject {
        NSArray * array = (NSArray *) responseObject;
        if (array.count > 0) {
            NSDictionary * dictionary = [array objectAtIndex:0];
            NSArray * insideArray = [dictionary objectForKey:@"lfs"];
            
            NSString *sectionHeader = @"";
            
            for (NSDictionary *sectionDictionary in insideArray) {
                sectionHeader = [sectionDictionary valueForKey:@"lf"];
                NSArray *varsArray = [sectionDictionary valueForKey:@"vars"];
                NSMutableArray *rowsArray = [[NSMutableArray alloc] initWithCapacity:1];
                for (NSDictionary *rowDictionary in varsArray) {
                    ResponseRow *row = [[ResponseRow alloc] init];
                    [row parseFromDictionary:rowDictionary];
                    [rowsArray addObject:row];
                }
                
                [tableSectionsAndItsRows addObject:@{@"sectionHeader": sectionHeader, @"rowsArray": rowsArray}];
            }
            
//            self.tableDataArray = [[NSMutableArray alloc] init];
//            TableCell * tableCell = nil;
//            if(insideArray != nil && insideArray.count > 0) {
//                for(NSDictionary * dic in insideArray) {
//                    tableCell = [[TableCell alloc] init];
//                    NSString * labelText = [dic objectForKey:@"lf"];
//                    NSString * detailLabelFirstPart = [dic objectForKey:@"freq"];
//                    NSString * detailLabelSecondPart = [dic objectForKey:@"since"];
//                    if(labelText != nil) {
//                        tableCell.labelText = labelText;
//                        NSString *joinString=[NSString stringWithFormat:@"%@ %@ | %@ %@",@"Freq",detailLabelFirstPart, @"Since", detailLabelSecondPart];
//                        tableCell.detailLabelText = joinString;
//                        [self.tableDataArray addObject:tableCell];
//                        //[self.tableDataArray addObject:value];
//                    }
//                }
//            }
        }
    }

-(void)showFailureAlertWithMessage:(NSString*)message{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Sorry" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"Let me try again" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.searchTextField.text = @"";
        self.results.text = @"";
    }];
    [alertC addAction: alertA];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

#pragma Mark
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self search:textField];
    
    return YES;
    
}


@end
