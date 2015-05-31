function [x,y] = shapeStrat4(w,h,b,l)
    
    hold on;
    width = w;
    height = h;
    base = b;
    angle=.9;
    numPoints=10;
    dampening=.0;
    
    switch l
        case 'u'
            xnoise = linspace(angle*width,width,numPoints)+dampening*(rand(1,numPoints)-.5);
            ynoise1 = ones(numPoints,1)'.*base+dampening*(rand(1,numPoints)-.5);
            ynoise2 = ones(numPoints,1)'.*(base+height)+dampening*(rand(1,numPoints)-.5);
            x= [linspace(0,angle*width,numPoints) xnoise linspace(width,0,numPoints) ones(numPoints,1)'*0];
            y= [ynoise1 linspace(base,(base+height),numPoints) ynoise2 linspace((base+height),base,numPoints)];

        case 'd'
            xnoise = linspace(width,angle*width,numPoints)+dampening*(rand(1,numPoints)-.5);
            ynoise1 = ones(numPoints,1)'.*base+dampening*(rand(1,numPoints)-.5);
            ynoise2 = ones(numPoints,1)'.*(base+height)+dampening*(rand(1,numPoints)-.5);
            x= [linspace(0,width,numPoints) xnoise linspace(angle*width,0,numPoints) ones(numPoints,1)'*0];
            y= [ynoise1 linspace(base,(base+height),numPoints) ynoise2 linspace((base+height),base,numPoints)];
            
        otherwise
            angle=1;
            xnoise = linspace(angle*width,width,numPoints)+dampening*(rand(1,numPoints)-.5);
            ynoise1 = ones(numPoints,1)'.*base+dampening*(rand(1,numPoints)-.5);
            ynoise2 = ones(numPoints,1)'.*(base+height)+dampening*(rand(1,numPoints)-.5);
            x= [linspace(0,angle*width,numPoints) xnoise linspace(width,0,numPoints) ones(numPoints,1)'*0];
            y= [ynoise1 linspace(base,(base+height),numPoints) ynoise2 linspace((base+height),base,numPoints)];
    end
end
