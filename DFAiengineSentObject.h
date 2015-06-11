//
//  DFAiengineSentObject.h
//  DFAiEngineTest
//
//  Created by Tiger on 15/5/12.
//  Copyright (c) 2015年 dfsc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * DFAiengineSentResultDetail类，测试结果中每个单词的评分纪录对象。
 * 多个句子中的多个单词，将组成数组，在DFAiengineSentResult对象中呈现。
 * 本类的成员中，会主要被用到的有：
 *  text: 当前的单词； score: 本单词的评分；fluency: 本单词的流利程度
 * 其它字段，参考厂家开发文档。
 */
@interface DFAiengineSentResultDetail : NSObject

@property (strong, nonatomic) NSString *text;
@property int score;
@property int start;
@property int end;
@property int dur;
@property int fluency;
@property int stressref;
@property int stressscore;
@property int toneref;
@property int tonescore;
@property int senseref;
@property int sensescore;

@end

/*
 * DFAiengineSentResult类，测试结果对象。每次测试都会生成这个结果。但是使用时要注意先检查errId字段。
 * 该对象在引擎运行一次测试结束的时候被实例化。并被作为参数，传入DFAiengineSentProtocol协议的方法。
 * 本类的成员中，会主要被用到的有：
     recordId: 本次录音记录字符串
     rank: 记分方式，例如4分制、10分制、还是100分制。默认100分制。
     pron: 本次发音评分
     overall: 本次的总分
     accuracy: 本次发音的精确程度评分
     integrity: 本次发音的完整度评分
     fluency: 总体的流利度评分
     details: 本次测试中每个单词的评分记录，以数组方式存储
     errId: 使用中，在协议方法的实现中，应先检查此字段是否为0（代表成功），否则代表本次评测失败。失败原因有多种，用不同数值表示。
 * 其它字段，参考厂家开发文档。
 */
@interface DFAiengineSentResult : NSObject

@property (strong, nonatomic) NSString *recordId;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *res;
@property unsigned long wavetime;
@property unsigned long systime;
@property unsigned long delaytime;
@property unsigned long pretime;
@property int textmode;
@property int useref;
@property int forceout;
@property int usehookw;
@property int rank;
@property int pron;
@property int overall;
@property int accuracy;
@property int integrity;
@property (strong, nonatomic) NSDictionary *fluency;
@property (strong, nonatomic) NSDictionary *rhythm;
@property (strong, nonatomic) NSMutableArray *details;
@property (strong, nonatomic) NSArray *statics;
@property (strong, nonatomic) NSDictionary *info;

@property int errId;

@end

/*
 自定义协议DFAiengineSentProtocol。使用本协议，来实现异步条件下语音引擎和主线程等其它线程之间的数据通讯。
 processAiengineSentResult:方法是一个协议方法。在开发者自己的使用语音引擎的控制器或其它类的实现中，应实现本接口的这个方法。方法的传入参数就是语音引擎当次识别结果的对象。
 注意，在本方法的实现代码中，应参考如下代码：
 
     -(void)processAiengineSentResult:(DFAiengineSentResult *)result
     {
     NSString *msg = [_engineObj getRichResultString:result.details];   // 从结果中获取需要的值
     [self performSelectorOnMainThread:@selector(showHtmlMsg:) withObject:msg waitUntilDone:NO];
     }

 使用performSelectorOnMainThread:withObject:waitUntilDone:方法而不是直接操作视图对象。
 */
@protocol DFAiengineSentProtocol <NSObject>

-(void)processAiengineSentResult:(DFAiengineSentResult *)result;

@end

/*
 DFAiengineSentObject语音识别引擎类：使用者只需要在自己的代码（通常在视图控制器代码）中，实例化并使用这个类的对象就可以了。
 使用的建议如下：
 1、为视图控制器增加一个DFAiengineSentObject对象
 2、在视图控制器的viewDidLoad方法中，实例化上述对象：
 
        _engineObj = [[DFAiengineSentObject alloc]initSentEngine:self withUser:@"Tiger.Yin"];
 
 实例化时传入的用户参数，应该是跟使用者具体应用相关的当前登录用户的用户名字符串。
 3、在合适的地方，使用待朗读的句子，启动引擎，例如开始按钮：
 
        if(_engineObj)
            [_engineObj startEngineFor:_inputView.text];
 
 4、在合适的地方，例如结束按钮，停止掉当前引擎。注意，只是停止，而不是销毁，因此还可以继续使用这个对象。
 
        if(_engineObj)
            [_engineObj stopEngine];

 5、销毁语音识别引擎对象。通常，在视图控制器被销毁之前，例如：
 
         -(void)viewDidDisappear:(BOOL)animated
         {
            [_engineObj stopEngine];
            _engineObj = nil;
         }
 
 6、获得富文本格式的彩色分析字符串。在协议方法中，得到结果后，使用如下方式得到已经转为富文本格式的句子：
 
        NSString *msg = [_engineObj getRichResultString:result.details];
 
    此后可以在UIWebView中，使用msg作为内容，显示彩色句子：
        
        [_colorView loadHTMLString:msg baseURL:nil];

 
 引擎的执行结果，将由协议方法以异步的方式交给前端界面处理。
 */
@interface DFAiengineSentObject : NSObject

@property (strong, nonatomic) NSString *srcSentence;

-(instancetype)initSentEngine:(id<DFAiengineSentProtocol>)obj withUser:(NSString *)userId;
- (void)startEngineFor:(NSString *)sentence;
- (void)stopEngine;
-(NSString *)getRichResultString:(NSArray *)words;

@end
