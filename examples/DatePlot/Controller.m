#import "Controller.h"
#import <CorePlot/CorePlot.h>

@implementation Controller

-(void)dealloc
{
    [plotData release];
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate       = [NSDate dateWithNaturalLanguageString:@"12:00 Oct 29, 2009"];
    NSTimeInterval oneDay = 24 * 60 * 60;

    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    hostView.hostedGraph = graph;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 5.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(3.0)];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromFloat(oneDay);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";

    CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Add some data
    NSMutableArray *newData = [NSMutableArray array];
    for ( NSUInteger i = 0; i < 5; i++ ) {
        NSTimeInterval x = oneDay * i;
        NSNumber *y      = @(1.2 * rand() / (double)RAND_MAX + 1.2);
        [newData addObject:
         @{ @(CPTScatterPlotFieldX): @(x),
            @(CPTScatterPlotFieldY): y }
        ];
    }
    plotData = newData;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return plotData[index][@(fieldEnum)];
}

@end
