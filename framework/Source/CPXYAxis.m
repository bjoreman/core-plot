
#import "CPXYAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPAxisLabel.h"

@interface CPXYAxis ()

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major; 

@end


@implementation CPXYAxis

@synthesize constantCoordinateValue;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if (self = [super init]) {
        self.constantCoordinateValue = [NSDecimalNumber zero];
	}
	return self;
}

-(void)dealloc 
{
    self.constantCoordinateValue = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimalNumber
{
    CPCoordinate orthogonalCoordinate = (self.coordinate == CPCoordinateX ? CPCoordinateY : CPCoordinateX);
    
    NSMutableArray *plotPoint = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
    [plotPoint replaceObjectAtIndex:self.coordinate withObject:coordinateDecimalNumber];
    [plotPoint replaceObjectAtIndex:orthogonalCoordinate withObject:self.constantCoordinateValue];
    
    CGPoint point = [self.plotSpace viewPointForPlotPoint:plotPoint];
    
    [plotPoint release];
	
    return point;
}

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major
{
	[(major ? self.majorTickLineStyle : self.minorTickLineStyle) setLineStyleInContext:theContext];

    for ( NSDecimalNumber *tickLocation in locations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:tickLocation];
        CGPoint terminalViewPoint = baseViewPoint;
        if ( self.coordinate == CPCoordinateX ) 
            terminalViewPoint.y += length * ( self.tickDirection == CPDirectionRight ? 1 : -1 );
        else
            terminalViewPoint.x += length * ( self.tickDirection == CPDirectionUp ? 1 : -1 );
        
        // Stroke line
        CGContextBeginPath(theContext);
        CGContextMoveToPoint(theContext, baseViewPoint.x, baseViewPoint.y);
        CGContextAddLineToPoint(theContext, terminalViewPoint.x, terminalViewPoint.y);
        CGContextStrokePath(theContext);
    }    
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext {
    // Ticks
    [self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength isMajor:YES];
    [self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength isMajor:NO];

    // Axis Line
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:range.end];
    [self.axisLineStyle setLineStyleInContext:theContext];
    CGContextBeginPath(theContext);
	CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
	CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
	CGContextStrokePath(theContext);
}

@end