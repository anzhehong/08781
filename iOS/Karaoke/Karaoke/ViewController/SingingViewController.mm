#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

#import "SingingViewController.h"
#import "MCAudioInputQueue.h"
#import "AVAudioPlayer+PCM.h"
#import <AVFoundation/AVAudioSession.h>

#import <netdb.h>

#import "SoundTouch.h"
#include "WaveHeader.h"


static const NSTimeInterval bufferDuration = 0.2;

@interface SingingViewController ()<MCAudioInputQueueDelegate, GCDAsyncUdpSocketDelegate, AVAudioPlayerDelegate>
{
@private
    AudioStreamBasicDescription _format;
    BOOL _inited;
    
    MCAudioInputQueue *_recorder;
    BOOL _started;
    
    BOOL _effectEnabled;
    
    NSMutableData *_data;
    AVAudioPlayer *_player;
    NSString *_host;
    int _port;
    
    GCDAsyncUdpSocket* _socket;
    
    soundtouch::SoundTouch mSoundTouch;
}
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneImageView;
@property (nonatomic,strong) IBOutlet UIButton *startOrStopButton;
@property (nonatomic,strong) IBOutlet UIButton *playButton;
@property (nonatomic,strong) IBOutlet UILabel  *durationLabel;
@end

@implementation SingingViewController

#pragma mark - init & dealloc
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self _commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _commonInit];
}

- (void)_commonInit
{
    if (_inited)
    {
        return;
    }
    
    _host = @"128.237.189.178";
    _port = 9099;
    
    _inited = YES;
    _effectEnabled = NO;
    
    _format.mFormatID = kAudioFormatLinearPCM;
    _format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    _format.mSampleRate = 44100.0f;
    _format.mBitsPerChannel = 16;
    _format.mChannelsPerFrame = 1;
    _format.mBytesPerPacket = _format.mBytesPerFrame = (_format.mBitsPerChannel / 8) * _format.mChannelsPerFrame;
    _format.mFramesPerPacket = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_interrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_interrupted:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)dealloc
{
    [_recorder stop];
    [_player stop];
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEffectEnabled:(BOOL) enabled {
    _effectEnabled = enabled;
}

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self connectToServe];
    [self makeBackground];
    [self _refreshUI];
    
    mSoundTouch.setSampleRate(44100);
    mSoundTouch.setChannels(1);
    mSoundTouch.setTempoChange(0.5);
    mSoundTouch.setPitchSemiTones(12);
    mSoundTouch.setRateChange(-0.7);
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 8);
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 8);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self disconnectServer];
}

#pragma mark - ui actions
- (IBAction)startOrStop:(id)sender
{
    if (_started)
    {
        [self _stopRecord];
    }
    else
    {
        [self _startRecord];
    }
}

- (IBAction)play:(id)sender
{
    [self _play];
}

- (IBAction)unlockButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)_refreshUI
{
    if (_started)
    {
        [self.startOrStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else
    {
        [self.startOrStopButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    self.playButton.enabled = !_started && _data.length > 0;
}

- (void)makeBackground {
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"album2"]]];
    UIView *blurView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:blurView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [blurView addSubview:blurEffectView];
    
    [self.view bringSubviewToFront:self.microphoneImageView];
    [self.view bringSubviewToFront:self.lockButton];
    [self.view bringSubviewToFront:self.startOrStopButton];
    
    // disable play button before playing recordings is ready
    [self.playButton setHidden:YES];
    [self.playButton setTintColor:[UIColor redColor]];
    [self.view bringSubviewToFront:self.playButton];
    
    [self.microphoneImageView setTintColor:[UIColor lightGrayColor]];
    [self.lockButton setTintColor:[UIColor blueColor]];
}

#pragma mark - play
- (void)_play
{
    [_player stop];
    _player = [[AVAudioPlayer alloc] initWithPcmData:_data pcmFormat:_format error:nil];
    [_player play];
    
//    [self playWave];
}

#pragma mark - record
- (void)_startRecord
{
    if (_started)
    {
        return;
    }
    
    [_player stop];
    _started = YES;
    
    _data = [NSMutableData data];
    _recorder = [MCAudioInputQueue inputQueueWithFormat:_format bufferDuration:bufferDuration delegate:self];
    _recorder.meteringEnabled = YES;
    [_recorder start];
    
    [self _refreshUI];
}

- (void)_stopRecord
{
    if (!_started)
    {
        return;
    }
    
    _started = NO;
    
    [_recorder stop];
    _recorder = nil;
    
    [self saveRecording];
    
    [self _refreshUI];
}

- (void) connectToServe
{
       // init socket
    _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    // connect
    NSError* error = nil;
    [_socket bindToPort:_port error:&error];
    [_socket setMaxSendBufferSize:16];
    if (error) {
        NSLog(@"%@", error);
    }
    [_socket beginReceiving:nil];
}

- (void) disconnectServer
{
    [_socket close];
    [self _stopRecord];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag");
}

#pragma mark - interrupt
- (void)_interrupted:(NSNotification *)notification
{
    [self _stopRecord];
    [_player stop];
}

#pragma mark - inputqueue delegate
- (void)inputQueue:(MCAudioInputQueue *)inputQueue inputData:(NSData *)data numberOfPackets:(UInt32)numberOfPackets
{
    if (data)
    {
        [_data appendData:data];
    }
    
    NSData* finalData;
    if (_effectEnabled) {
        NSMutableData *soundTouchDatas = [[NSMutableData alloc] init];
        char *pcmData = (char *)data.bytes;
        
        int pcmSize = data.length;
        
        int nSamples = pcmSize / 2;
        mSoundTouch.putSamples((short *)pcmData, nSamples);
        
        short *samples = new short[pcmSize];
        int numSamples = 0;
        do {
            
            memset(samples, 0, pcmSize);
            //short samples[nSamples];
            numSamples = mSoundTouch.receiveSamples(samples, pcmSize);
            [soundTouchDatas appendBytes:samples length:numSamples*2];
            
        } while (numSamples > 0);
        finalData = soundTouchDatas;
    } else finalData = data;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // todo: test
        [_socket sendData:finalData
                      toHost:_host
                        port:_port
                 withTimeout:-1
                         tag:110];
        
    });
    
    [inputQueue updateMeters];
    
    double duration = _data.length / _recorder.bufferSize * _recorder.bufferDuration;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *durationString = [NSString stringWithFormat:@"duration = %.1lfs",duration];
        self.durationLabel.text = durationString;
    }); 
}

- (void)saveRecording
{
//    NSMutableData *wavDatas = [[NSMutableData alloc] init];
//
//    int fileLength = _data.length;
//    void *header = createWaveHeader(fileLength, 1, 16000, 16);
//    [wavDatas appendBytes:header length:44];
//
//    [wavDatas appendData:_data];
//
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filePath = [path stringByAppendingPathComponent:@"soundtouch.wav"];
//    [wavDatas writeToFile:filePath atomically:YES];
}

- (void)playWave
{
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filePath = [path stringByAppendingPathComponent:@"soundtouch.wav"];
//    AVAudioPlayer *audioPalyer;
////    if (audioPalyer) {
////        [audioPalyer release];
////        audioPalyer = nil;
////    }
//
//    NSError *error;
//    NSURL *url = [NSURL URLWithString:filePath];
//    NSData *audioData = [NSData dataWithContentsOfFile:filePath];
////    audioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    audioPalyer = [[AVAudioPlayer alloc] initWithData:audioData fileTypeHint:AVFileTypeMPEGLayer3
//                                  error:&error];
//    if (error) {
//        NSLog(@"%@", error);
//    }
//    audioPalyer.delegate = self;
//    [audioPalyer prepareToPlay];
//    [audioPalyer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
    NSLog(@"%@", error);
}

- (void)inputQueue:(MCAudioInputQueue *)inputQueue errorOccur:(NSError *)error
{
    [self _stopRecord];
}
@end
