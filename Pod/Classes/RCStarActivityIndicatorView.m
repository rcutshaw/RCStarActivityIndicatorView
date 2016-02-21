//
//  RCStarActivityIndicatorView.m
//  Pods
//
//  Created by David Cutshaw on 2/21/16.
//
//

#import "RCStarActivityIndicatorView.h"
#import "RCStarActivityIndicatorStarView.h"

static NSString * const kStarCurveAnimationKey = @"kStarCurveAnimationKey";
static NSString * const kStarScaleAnimationKey = @"kStarScaleAnimationKey";

@interface RCStarActivityIndicatorStarView ()

@property (nonatomic, strong) UIColor *color;

@end

@interface RCStarActivityIndicatorView ()

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation RCStarActivityIndicatorView

- (instancetype)init
{
    if(self = [super init]) {
        [self _commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
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
    self.numberOfStars = 5;
    self.animationDuration = 1.5f;
    self.starSize = CGSizeMake(CGRectGetWidth(self.bounds) / 10.0f, CGRectGetHeight(self.bounds) / 10.0f);
    self.starColor = [UIColor whiteColor];
}

#pragma mark - SCSkypeActivityIndicatorViewProtocol

- (void)startAnimating
{
    if(self.isAnimating) {
        return;
    }
    
    self.isAnimating = YES;
    
    
    for(NSUInteger i=0; i<self.numberOfStars; i++) {
        CGFloat x = i * (1.0f / self.numberOfStars);
        RCStarActivityIndicatorStarView *starView = [self starWithTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5f :(0.1f + x) :0.25f :1.0f]
                                                                           initialScale:1.0f - x
                                                                             finalScale:0.2f + x];
        [starView setAlpha:0.0f];
        [self addSubview:starView];
        
        [UIView animateWithDuration:0.25f animations:^{
            [starView setAlpha:1.0f];
        }];
    }
}

- (void)stopAnimating
{
    if(!self.isAnimating) {
        return;
    }
    
    for(UIView *star in self.subviews) {
        [UIView animateWithDuration:0.25f animations:^{
            
            [star setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [star.layer removeAllAnimations];
            [star removeFromSuperview];
        }];
    }
    
    self.isAnimating = NO;
}

- (RCStarActivityIndicatorStarView *)starWithTimingFunction:(CAMediaTimingFunction *)timingFunction initialScale:(CGFloat)initialScale finalScale:(CGFloat)finalScale
{
    RCStarActivityIndicatorStarView *starView = [[RCStarActivityIndicatorStarView alloc] initWithFrame:CGRectMake(0, 0, self.starSize.width, self.starSize.height)];
    [starView setColor:self.starColor];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.duration = self.animationDuration;
    pathAnimation.repeatCount = CGFLOAT_MAX;
    pathAnimation.timingFunction = timingFunction;
    pathAnimation.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
                                                        radius:MIN(self.bounds.size.width - starView.bounds.size.width, self.bounds.size.height - starView.bounds.size.height)/2
                                                    startAngle:3 * M_PI / 2
                                                      endAngle:3 * M_PI / 2 + 2 * M_PI
                                                     clockwise:YES].CGPath;
    
    [starView.layer addAnimation:pathAnimation forKey:kStarCurveAnimationKey];
    
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = self.animationDuration;
    scaleAnimation.repeatCount = CGFLOAT_MAX;
    scaleAnimation.fromValue = @(initialScale);
    scaleAnimation.toValue = @(finalScale);
    
    if(initialScale > finalScale) {
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    } else {
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    
    [starView.layer addAnimation:scaleAnimation forKey:kStarScaleAnimationKey];
    
    return starView;
}

@end

@implementation RCStarActivityIndicatorStarView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

#define degreesToRadian(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) {x * 180 / M_PI;

- (NSMutableArray*)polygonPointArrayWithSides:(int)sides x:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius adjustment:(CGFloat)adjustment {
    CGFloat angle = degreesToRadian(360/(CGFloat)sides);
    CGFloat cx = x; // x origin
    CGFloat cy = y; // y origin
    CGFloat r = radius; // radius of circle
    int i = sides;
    NSMutableArray* points = [[NSMutableArray alloc] init];
    while (points.count <= sides) {
        CGFloat xpo = cx - r * cos(angle * (CGFloat)i + degreesToRadian(adjustment));
        CGFloat ypo = cy - r * sin(angle * (CGFloat)i + degreesToRadian(adjustment));
        CGPoint nextPoint = CGPointMake(xpo, ypo);
        NSValue *valueToAdd = [NSValue valueWithCGPoint:nextPoint];
        [points addObject:valueToAdd];
        i--;
    }
    return points;
}

- (CGPathRef)starPathWithX:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius sides:(int)sides pointyness:(CGFloat)pointyness {
    CGFloat adjustment = 360/sides/2;
    CGMutablePathRef path = CGPathCreateMutable();
    NSMutableArray* points = [self polygonPointArrayWithSides:sides x:x y:y radius:radius adjustment:0];
    CGPoint cpg = [points[0] CGPointValue];
    NSMutableArray* points2 = [self polygonPointArrayWithSides:sides x:x y:y radius:radius*pointyness adjustment:adjustment];
    int i = 0;
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y);
    for (NSValue *p in points) {
        CGPathAddLineToPoint(path, nil, [points2[i] CGPointValue].x, [points2[i] CGPointValue].y);
        CGPathAddLineToPoint(path, nil, [p CGPointValue].x, [p CGPointValue].y);
        i++;
    }
    CGPathCloseSubpath(path);
    return path;
}

- (UIBezierPath*)drawStarBezier:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius sides:(int)sides pointyness:(CGFloat)pointyness {
    CGPathRef path = [self starPathWithX:x y:y radius:radius sides:sides pointyness:pointyness];
    UIBezierPath *bez = [UIBezierPath bezierPathWithCGPath:path];
    return bez;
}

- (void)drawRect:(CGRect)rect {
    CGFloat radius = 4;
    UIBezierPath *bezPath = [self drawStarBezier:(10 + radius) y:10 radius:radius sides:5 pointyness:3];
    
    CGRect bounds = CGPathGetBoundingBox(bezPath.CGPath);
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGAffineTransform toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y);
    [bezPath applyTransform:toOrigin];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI / (-10.0));
    CGAffineTransform finalTransformWithTranslation = CGAffineTransformTranslate(rotation, -radius, 0.0);
    [bezPath applyTransform:finalTransformWithTranslation];
    
    CGAffineTransform fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y);
    [bezPath applyTransform:fromOrigin];
    
    [[UIColor whiteColor] setFill];
    
    [bezPath fill];
}
@end
