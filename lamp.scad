//-----------------------------------------------
// Base Display Options
//-----------------------------------------------
// Fragments
$fn = 200;

// Render Type: "full" | "mid" | "low" | "cyl"
renderType = "mid";

//-----------------------------------------------
// Base Cylinder Settings
//-----------------------------------------------
cylinderRadius =  5;
cylinderHeight = 20;

cylinderHoleRadius = 3.5;
cylinderHoleHeight = 10;

rodRadius = cylinderHoleRadius;

//-----------------------------------------------
// Definition
//-----------------------------------------------
segments = 7;

// Upper
arcLinkUpper = 25;
rodLengthUpper = 600;

middleRadius = 300;
lowerRadius = 200;
lowerHeight = 100;

//-----------------------------------------------
// Some Calculation
//-----------------------------------------------
_innerArc = (180 - 360/segments)/2;
_rodOffset = cylinderHeight - cylinderHoleHeight;
//_rodOffset = 0;

_segLengthMiddle = 2*middleRadius*sin(360/segments/2);
_segLengthLower = 2*lowerRadius*sin(360/segments/2);


_rM = middleRadius - sqrt(pow(lowerRadius, 2) - pow(_segLengthLower/2, 2));
_a = sqrt(pow(lowerHeight, 2) + pow(_rM, 2));

_lengthLink = sqrt(pow(_a, 2) + pow(1/2*_segLengthLower, 2));

_arcLinkLower = 2*asin(_segLengthMiddle/(2*_lengthLink));
_arcLinkMiddle = 2*asin(_segLengthLower/(2*_lengthLink));

_arcLinkMiddleDia = acos(_rM/_a);

_rL = lowerRadius - sqrt(pow(middleRadius, 2) - pow(_segLengthMiddle/2, 2));
_x = sqrt(pow(_lengthLink, 2) - pow(_segLengthMiddle/2, 2));
_arcLinkLowerDia = acos(lowerHeight/_x) * sign(_rL);

// Rod Length
_rodLenghtMiddle = _segLengthMiddle - 2*_rodOffset;
_rodLenghtLower = _segLengthLower - 2*_rodOffset;
_rodLenghtLink = _lengthLink - 2*_rodOffset;

echo("Rod Length Middle Inner: ", _rodLenghtMiddle);
echo("Rod Length Lower Inner: ", _rodLenghtLower);
echo("Rod Length Link: ", _rodLenghtLink);

echo("Rod Length Link: ", sign(_rL));
echo("Rod Length Link: ", _arcLinkLowerDia);
//-----------------------------------------------

module baseCylinder() {
    difference() {
        cylinder(h = cylinderHeight, r = cylinderRadius);
        translate([0, 0, cylinderHeight - cylinderHoleHeight]) {
            cylinder(h = cylinderHoleHeight + 0.1, r = cylinderHoleRadius);
        }
    }
}

module plug(arcs) {
    sphere(cylinderRadius);   
    for(arc = arcs)
        rotate(a = arc) {
            baseCylinder();
        }
}

module rods(arcs, length) {
     for(i = [0 : len(arcs) - 1])
        rotate(a = arcs[i]) {
            translate([0, 0, _rodOffset]) {
                #cylinder(h = length[i], r = rodRadius);
            }
        }   
}


module middlePlug(showRods = false) {
    arcs = [
        [0, arcLinkUpper, 0], // UP
        [90, 0, 90 - _innerArc], // LEFT
        [-90, 0, - (90 - _innerArc)], // RIGHT 
        [180 - _arcLinkMiddle/2, _arcLinkMiddleDia - 90, 0], // DOWN 1
        [180 + _arcLinkMiddle/2, _arcLinkMiddleDia  - 90, 0] // DOWN 2
    ];

    plug(arcs);
    
    if (showRods)
        rods(
            arcs = [for (i = [0, 1, 3, 4]) arcs[i]], 
            length = [rodLengthUpper, _rodLenghtMiddle, _rodLenghtLink, _rodLenghtLink]
        );
}

module lowerPlug(showRods = false) {
    arcs = [
        [-_arcLinkLower/2, _arcLinkLowerDia, 0],
        [_arcLinkLower/2, _arcLinkLowerDia, 0], 
        [-90, 0, - (90 - _innerArc)], // LEFT
        [90, 0, 90 - _innerArc] // RIGHT
    ];

    plug(arcs);

    if (showRods)
        rods(
            arcs = [arcs[3]], 
            length = [_rodLenghtLower]
        );
}

module full(showRods = true) {
    // Translate it and replicate and rotate it
    for(i = [0 : segments - 1]) {
        // Mid
        rotate([0, 0, i*(360/segments)])
            translate([-middleRadius, 0, 0])
                middlePlug(showRods);

        // Lower
        rotate([0, 0, (i + 1/2)*(360/segments)])
            translate([-lowerRadius, 0, -lowerHeight])
                lowerPlug(showRods);
    }
}

if (renderType == "full") {
    full();
} else if (renderType == "mid") {
    middlePlug();
} else if (renderType == "low") {
    lowerPlug();
} else if (renderType == "cyl") {
    baseCylinder();
}
