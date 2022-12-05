

#pragma mark - 调用文件
#import "Drawst.h"
#import "Drawzb.h"
#import "Floating/JFCommon.h"
#import "Utils/Color.h"

#import "imgui/imgui/imgui.h"
#import "imgui/imgui/imgui_internal.h"
#import "imgui/ImGuiWrapper.h"
#import "imgui/ImGuiStyleWrapper.h"
#import "imgui/GuiRenderer.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import "CoreText/CTFont.h"
#import "UTFMaster/utf.c"
#include <string>
#include <vector>
#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
using namespace std;
std::string string_format(const std::string &fmt, ...) {
    std::vector<char> str(100,'\0');
    va_list ap;
    while (1) {
        va_start(ap, fmt);
        auto n = vsnprintf(str.data(), str.size(), fmt.c_str(), ap);
        va_end(ap);
        if ((n > -1) && (size_t(n) < str.size())) {
            return str.data();
        }
        if (n > -1)
            str.resize( n + 1 );
        else
            str.resize( str.size() * 2);
    }
    return str.data();
}

UIView* view;
UITextField *field = [[UITextField alloc] init];
static bool StreamerMode = false;


@interface JFOverlayView () <GuiRendererDelegate> {
    ImFont *_espFont;
}

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) GuiRenderer *renderer;

@end

@implementation JFOverlayView

#pragma mark - 菜单开关字符串
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.isShowMenu = false;

        [self setupUI];
    }
    return self;
}

#pragma mark
- (void)setupUI
{
    /*
    Sets up the base layer which is being hidden from recordings,
    any other views displayed ontop will be unable to be directly touched
    on the screen, which is addressed later
    */
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setUserInteractionEnabled:YES];
    field.secureTextEntry = true;
    [view addSubview:field];
    view = field.layer.sublayers.firstObject.delegate;
    [[UIApplication sharedApplication].keyWindow addSubview:view];


    /*
    Adds ImGui Window ontop of the no record view
    */
    self.mtkView = [[MTKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mtkView.backgroundColor = [UIColor clearColor];
    [view addSubview:self.mtkView]; 
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    if (!self.mtkView.device) {
        return;
    }
    self.renderer = [[GuiRenderer alloc] initWithView:self.mtkView];
    self.renderer.delegate = self;
    self.mtkView.delegate = self.renderer;
    [self.renderer initializePlatform];
}

#pragma mark -
- (void)setup
{
    ImGuiIO & io = ImGui::GetIO();
    ImFontConfig config;
    config.FontDataOwnedByAtlas = false;
    /*
        Adds a font different than the ImGui Default Font, and sets the character range to chinese and english glyphs
    */
    NSString *fontPath = @"/System/Library/Fonts/LanguageSupport/PingFang.ttc";
    _espFont = io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 20.f, &config, io.Fonts->GetGlyphRangesChineseFull());
    

}

- (void)draw
{
    [self drawOverlay];
    [self CheckStreamerMode];
    [self drawMenu];
}

#pragma mark QQ654153159

- (void)drawMenu
{
    self.userInteractionEnabled = self.isShowMenu;
    self.mtkView.userInteractionEnabled = self.isShowMenu;
    if (!_isShowMenu) return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = SCREEN_WIDTH * 0.4;
        CGFloat height = SCREEN_HEIGHT * 0.5;
        if (SCREEN_WIDTH > SCREEN_HEIGHT) {

            height = SCREEN_HEIGHT * 0.4;
        } else {
            // 竖屏
            width = SCREEN_WIDTH * 0.4;
        }
        ImGuiIO & io = ImGui::GetIO();
        io.DisplaySize = ImVec2(width, height);
        ImGui::SetNextWindowPos(ImVec2((SCREEN_WIDTH - width) * 0.5, (SCREEN_HEIGHT - height) * 0.5), 0, ImVec2(0, 0));
        ImGui::SetNextWindowSize(ImVec2(io.DisplaySize.x, io.DisplaySize.y));
        io.FontGlobalScale = 0.5f;
    });
    
    
    ImGui::Begin("Template", &_isShowMenu, ImGuiWindowFlags_NoCollapse);
    if (ImGui::BeginTabBar("Template", ImGuiTabBarFlags_NoTooltip))
    {
        {
               ImGui::Checkbox("Streamer Mode", &StreamerMode); 
         }
 
        ImGui::EndTabBar();
    }
    
    ImGui::End();



}
/*
controls wether to enable or disable hiding the menu from recordings
*/
- (void)CheckStreamerMode{
    if(StreamerMode){
        [IFuckYou getNoRecView].secureTextEntry = true;
        field.secureTextEntry = true;
    }
    else{
        [IFuckYou getNoRecView].secureTextEntry = false;
        field.secureTextEntry = false;
    }
    return;
}
- (void)drawOverlay
{
    /*
    Add Drawing Functions Here
    */
    return;   
}
#pragma mark
- (void)drawAimRangeWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments thicknes:(float)thicknes
{
    ImGui::GetOverlayDrawList()->AddCircle(center, radius, [self getImU32:color], numSegments, thicknes);
}

- (void)drawLineWithStartPoint:(ImVec2)startPoint endPoint:(ImVec2)endPoint color:(Color)color thicknes:(float)thicknes
{
    ImGui::GetBackgroundDrawList()->AddLine(startPoint, endPoint, [self getImU32:color], thicknes);
}

- (void)drawCircleWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments thicknes:(float)thicknes
{
    ImGui::GetBackgroundDrawList()->AddCircle(center, radius, [self getImU32:color], numSegments, thicknes);
}

- (void)drawCircleFilledWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments
{
    ImGui::GetBackgroundDrawList()->AddCircleFilled(center, radius, [self getImU32:color], numSegments);
}

- (void)drawTextWithText:(string)text pos:(ImVec2)pos isCentered:(bool)isCentered color:(Color)color outline:(bool)outline fontSize:(float)fontSize
{
    const char *str = text.c_str();
    ImVec2 vec2 = pos;
    if (isCentered) {
        ImVec2 textSize = _espFont->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = [self getImU32:Color::Black];//
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    ImGui::GetBackgroundDrawList()->AddText(_espFont, fontSize, vec2, [self getImU32:color], str);
}

- (ImU32)getImU32:(Color)color
{
    return ((color.a & 0xff) << 24) + ((color.b & 0xff) << 16) + ((color.g & 0xff) << 8) + (color.r & 0xff);
}

/* passes touches from the top view to the imgui view
*/
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

@end
