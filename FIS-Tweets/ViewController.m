//
//  ViewController.m
//  FIS-Tweets
//
//  Created by James Campagno on 11/2/15.
//  Copyright © 2015 James Campagno. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"

@interface ViewController ()

@property (nonatomic, assign)NSUInteger sum;
@property (nonatomic ,assign)NSUInteger finRating;
@property (nonatomic ,assign)NSUInteger endR;

@property (nonatomic, copy) NSUInteger (^endNumber)(NSUInteger);


@property (weak, nonatomic) IBOutlet UILabel *Counting;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.Counting.text = [NSString stringWithFormat:@"%@",self.endNumber];
    
    [self flatironSchoolTweetRates];

}

-(void)flatironSchoolTweetRates{
    
    
    NSString * consumerkey = @"A6iwLtIErt9akhR0WQWuA9buU";
    NSString * consumerSecret = @"l51ZdmvFJwgQLgfGxhQyEuoX6a2RzrlcCfH7yh6YcgVij6K57o";
    
    
    
    
    //NSString * requestString = [NSString stringWithFormat:@"http://www.sentiment140.com/api/classify?text=%@&query=%@&callback=myJsFunction&appid=bha.guang@gmail.com",escapedString,@"FlatironSchool"];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:consumerkey
                                                            consumerSecret:consumerSecret];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        //        - (NSObject<STTwitterRequestProtocol> *)getSearchTweetsWithQuery:(NSString *)q
        //    successBlock:(void(^)(NSDictionary *searchMetadata, NSArray *statuses))successBlock
        //    errorBlock:(void(^)(NSError *error))errorBlock;
        
        
        
        [twitter getSearchTweetsWithQuery:@"FlatironSchool" successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
            // ...
            
            NSLog(@"statues array %@", statuses);
            for (NSDictionary * eachTweet in statuses) {
                NSString * tweet = eachTweet[@"text"];
                NSString * encodedTweet = [self ecodeText:tweet];    //:@"hello"];   //eachTweet[0]];
                NSString * requestString = [NSString stringWithFormat:@"http://www.sentiment140.com/api/classify?text=%@&query=%@&appid=bha.guang@gmail.com",encodedTweet,@"FlatironSchool"];
                // another API request
                [self sentimentAPIrequest:requestString withBlock:^(NSUInteger polarity) {
                    
                    // collect ratings, average them
                    self.sum = self.sum + polarity;
                    self.sum = self.sum + polarity;
                    self.finRating = self.sum/statuses.count;
                    
                    self.endNumber(self.finRating);
                    
//                    NSUInteger (^lastRating)(NSUInteger);
//                    lastRating(self.finRating);

                    //self.Counting.text = [ NSString stringWithFormat:@"%lu",self.finRating];
                    NSLog(@"all the ratings are index %lu, %lu",(unsigned long)self.sum,self.finRating);
                }];
            }
            NSLog(@" ---------------- fin number is %lu", self.sum/statuses.count);
        } errorBlock:^(NSError *error) {
        }];
    } errorBlock:^(NSError *error) {
    }];
}

-(NSString *)ecodeText:(NSString *)tweet
{
    NSString * escapedString = [tweet stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    return escapedString;
}

-(void)sentimentAPIrequest:(NSString *)urlString  withBlock:(void(^)(NSUInteger polarity))completionBlock {
    
    NSURL *fltweetURL = [NSURL URLWithString:urlString];
    NSURLRequest * requestedurl = [NSURLRequest requestWithURL:fltweetURL];
    NSURLSession * tweetSession = [NSURLSession sharedSession];
    
    NSURLSessionTask * tweetTask = [tweetSession dataTaskWithRequest:requestedurl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"hi, im back from space");
        
        NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:nil];
        
        NSNumber * polarityNU = resultsDictionary[@"results"][@"polarity"];
        NSLog(@"Hey, did this dictinary do something: xxxxxxxxxxxxxxxxxx-- %ld ", (long)polarityNU.integerValue);
        completionBlock(polarityNU.integerValue);
    }];
    
    NSLog(@"task is set up");
    [tweetTask resume];
    NSLog(@"task is started");
    
}


@end


/*
NOTE : too many debug pasues internet, therfore there data from the block might be nil, because it keeps pausing.
 
*/

