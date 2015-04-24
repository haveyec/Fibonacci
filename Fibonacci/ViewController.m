//
//  ViewController.m
//  Fibonacci
//
//  Created by Matsumoto Taichi on 4/7/15.
//  Copyright (c) 2015 iHeartMedia. All rights reserved.
//

/*
*   Modified by Marlon Henry.
*/

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblFibonacci;

@end

NSMutableArray *arrInfinity;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Initialize the infinity array, and proceed to reload data and acquire first chunk of 20
    arrInfinity = [[NSMutableArray alloc] initWithObjects:@"1",@"1", nil];
    [self.tblFibonacci reloadData];
    [self scrollViewDidScroll:self.tblFibonacci];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrInfinity.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = arrInfinity[indexPath.row];
    [cell sizeToFit];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Fibonacci # %ld", indexPath.row];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Get the string for the current indexpath, and determine necessary height via boundingRectWithSize method.
    NSString * a = [arrInfinity objectAtIndex:indexPath.row];
    CGRect r = [a boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]} context:nil];
    
    //Return the yielded rects height plus 40 to provided some white space between cells and also account for the detail text label.
    return r.size.height + 40;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Produce infinite scrolling by adding more and more cells whenever user is 3 tableView frame sizes away from the end.
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - (3*scrollView.frame.size.height) ){
        //Create the next 20 numbers in the Fibonacci sequence on a background thread to ensure lag free UI.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for( int i = 0; i < 20; i++){
                [arrInfinity addObject:[self addIntString:arrInfinity[arrInfinity.count-2] withString:arrInfinity[arrInfinity.count-1]]];
            }
            //Once the 20 numbers have been attained, reload the table on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblFibonacci reloadData];
            });
        });
    }
}

#pragma mark - Utility method
/*
 *  This method takes in two strings, comprised of just numbers, and performs basic addition on them
 *  character by character. The algorithm proceeds from the tail of both strings and adds the two chars all 
 *  while processing carryovers. The results are appended combined into a resulting string until the tail
 *  pointers reach the head of both op1. The method assumes that op1 is larger than op2.
 *
 *  @param  op1 = A string of digit characters (larger in length than op2)
 *  @param  op2 = A string of digit characters
 *
 *  @return NSString, a resulting string is created based on the
 *
 */
-(NSString*)addIntString:(NSString*)op1 withString:(NSString*)op2{
    
    //String for holding result of addition.
    NSString *result = @"";
    
    //References to the back of each string, as well as an integer to denote carryovers.
    NSInteger tailOne = op1.length-1;
    NSInteger tailTwo = op2.length-1;
    NSInteger carryOver = 0;
    
    //Go character by character and produce a string one character string to add to result.
    while ( tailOne >= 0 ) {
        //Create the range for the current character of interest, and get the number equivalent to it.
        NSRange range1 = {tailOne,1};
        NSRange range2 = {tailTwo,1};
        NSInteger num1 = [[op1 substringWithRange:range1] integerValue];
        NSInteger num2 = tailTwo >= 0 ? [[op2 substringWithRange:range2] integerValue] : 0;
        
        //Append the summation of the two single digits to the results string. Modulus is used to ensure just one character is added, and carryover is used to symbolize that the result of the addition yielded a two digit number.
        result = [NSString stringWithFormat:@"%ld%@", (num1+num2+carryOver)%10 ,result];
        carryOver = num1+num2 > 9 ? 1 : 0;
        
        //Decrement both of the tails, to proceed to the next character of interest on the next iteration.
        tailOne--;
        tailTwo--;
    }
    
    //Process a left over carry if needed, and then return.
    if( carryOver == 1){
        result = [NSString stringWithFormat:@"%d%@", 1 ,result];
    }
    
    return result;
}

@end
