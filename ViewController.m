//
//  ViewController.m
//  webview
//
//  Created by Weilong Song on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize w;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self openTaobao];
    [self it_is_up_to_xuchuan: @"12642909771"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

/*
 * 从拿到一个productID开始,拿到这个商品的mobile最终页
 *    1 这个最终页要去头去尾(通过添加ttid来实现)
 *    2 这个最终页要可以被我们的淘宝客账户统计到
 * @param : {NSString} 一个商品的id
 * @method: it_is_up_to_xuchuan
 */
- (void)it_is_up_to_xuchuan: (NSString *) productID // 我不知道这里用什么function名字好,川哥你来决定
{
    NSString *reqURL;
    NSString *reqURLHeader = @"http://gw.api.taobao.com/router/rest?";
    NSString *ts = [self getFormatedDate];
    NSString *params = [NSString stringWithFormat:@""
                        "app_key=12616557&"
                        "fields=click_url,num_iid,commission,commission_rate,commission_num,commission_volume&"
                        "format=json&"
                        "is_mobile=true&"
                        "method=taobao.taobaoke.items.convert&"
                        "num_iids=%@&"
                        "partner_id=top-apitools&"
                        "pid=31240926&"
                        "sign_method=md5&"
                        "timestamp=%@&"
                        "v=2.0"
                        , productID, ts];
    NSString *sign = [self createSign: params];
    NSLog(@"这时候我们要把生成好的sign拼接到parameters中，作为第一个参数（位置好像无所谓），即sign=%@&", sign);
    reqURL = [NSString stringWithFormat:@"%@sign=%@&%@", reqURLHeader, sign, params];
    NSLog(@"最终拼好的url为%@", reqURL);
    NSLog(@"开始向淘宝请求这个url, 期望返回一个json串,里面包含有我们想要的单品最终页url");
    /*
      todo: 下一步我们请求这个url，从返回的json串中可以取得到一个url，这个url即是单品的最终页url，用户如果从这个url产生了购买，我们的淘宝客里面会有统计
     */
    NSLog(@"获取到了单品最终页url,开始增加ttid,imei,imsi,sid这四个参数");
    /*
      todo: 再下一步给这个url增加ttid、imei、imsi、sid然后把这个url放给webview即可
            imei: iphone UDID 的前15位
                  imei=7B54917DB208464"
            imsi: iphone UDID 的后15位
                  imsi=7B54917DB208464"  
            sid:  为小写字母t + imei
                  sid=t7B54917DB208464"
            ttid: 是一个字符串，基本的组成为“渠道代码_AppKey@应用名称（首字母）_平台名称_版本号_特殊参数（可选）
                  这个是根据我们自己的应用已经拼好的ttid,不用再改了
                  ttid=ttid=400000_12629922@xmxcy_ios_5.0"
     
            ************************************************************************************
            **  上面提到了UDID,这个是获取的ios设备的唯一标识,但是由于最近apple对隐私的控制,将禁用这个UDID,   **
            **  并且会拒绝通过审核获取用户UDID的应用,所以必须使用一个替代方案来提供这个UDID,以下为一篇参考文章  **
            **  http://blog.csdn.net/xiaoguan2008/article/details/7457655                     **
            ************************************************************************************
     */
    NSLog(@"参数增加完毕,最终得到了单品最终页的url,开始扔给uiWebView");
    /*
     todo: 画一个uiWebView来加载这个url
     */
    NSLog(@"uiWebView画页面完毕");
    
    
}

/*
 * 获取当前日期并且格式化为字符串返回
 * @method: getFormatedDate
 * @return: {NSString} 返回一个日期的字符串,格式化规则自定
 */
- (NSString *)getFormatedDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSLog(@"取得的日期转换成为NSString结果为：%@", dateString);
    return dateString;
}

/*
 * 根据淘宝开放平台的规则,生成一个签名sign
 * @method: createSign
 * @param : {NSString} 请求url中所有的parameters
 * @return: {NSString} 返回一个sign,是对parameters进行格式化后又md5加密过
 * 参考:http://dev.open.taobao.com/dev/index.php/API%E7%AD%BE%E5%90%8D%E7%AE%97%E6%B3%95
 */
- (NSString *)createSign:(NSString *)params
{
    NSString *sign;
    // secretKey为志标生成的，基本是不变的，除非志标重新生成一个
    NSString *secretKey = @"a2d9bb9b0b76ef85a75b77c6f72b83e1";
    
    // 创建一个字符串来生成一个sign，要把所有的等号去掉，规则来源于淘宝网开放平台http://open.taobao.com/doc/detail.htm?id=111#s6
    params = [NSString stringWithFormat:@"%@%@%@", secretKey, params, secretKey];
    NSError *err = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"[=&]" options:NSRegularExpressionCaseInsensitive error:&err];
    NSString *paramsForCreatingSign = [reg stringByReplacingMatchesInString:params options:0 range:NSMakeRange(0, [params length]) withTemplate:@""];
    NSLog(@"已经创建好了用于加密计算sign的串：%@", paramsForCreatingSign);
    
    sign = [self md5:paramsForCreatingSign];
    
    NSLog(@"OK到这里，我们所需要的sign已经生成好了：%@", sign);
    return sign;
}

/*
 * 把传进来的str进行md5加密生成大写的32位md5串
 * @method: md5
 * @param : {NSString} 任何一个字符串
 * @return: {NSString} 返回这个字符串md5加密过的串
 */
-(NSString *)md5:(NSString *)str
{ 
    const char *cStr = [str UTF8String]; 
    // 淘宝开放平台要求这里一定要生成32位的串。如果想生成16位的，只需 result[16]即可
    unsigned char result[32]; 
    CC_MD5( cStr, strlen(cStr), result ); 
    return [NSString stringWithFormat: 
        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", 
        result[0], result[1], result[2], result[3], 
        result[4], result[5], result[6], result[7], 
        result[8], result[9], result[10], result[11], 
        result[12], result[13], result[14], result[15] 
        ]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
