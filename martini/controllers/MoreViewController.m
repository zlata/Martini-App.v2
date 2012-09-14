//
//  MoreViewController.m
//  martini
//
//  Created by zlata samarskaya on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "SettingsViewController.h"
#import "InfoViewController.h"
#import "AboutDevelopersViewController.h"
#import "InstructionViewController.h"

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"дополнителыно";
    }
    return self;
}

- (void)didReceiveMemoryWarning  {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableData_ = [[NSArray alloc] initWithObjects:@"Настройки", @"Инструкция", @"Информация о MARTINI", @"О разработчиках", nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [tableData_ release];
    
    [super dealloc];
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"MoreCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]] autorelease];
    }
    cell.textLabel.font = [UIFont fontWithName:@"MartiniPro-Bold" size:15];
    cell.textLabel.text = [tableData_ objectAtIndex:indexPath.row];
   
    return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData_ count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    MNews *news = [tableData_ objectAtIndex:indexPath.row];
    BaseViewController *controller = nil;
    switch (indexPath.row) {
        case 0:
            controller = [[[SettingsViewController alloc] init] autorelease];
            break;
        case 1:
            controller = [[[InstructionViewController alloc] init] autorelease];
            break;
        case 2:
            controller = [[[InfoViewController alloc] init] autorelease];
            break;
        case 3:
            controller = [[[AboutDevelopersViewController alloc] init] autorelease];
            break;
            
        default:
            break;
    }
   // NewsViewController *
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
