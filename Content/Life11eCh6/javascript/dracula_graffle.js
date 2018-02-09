
//
// Adapted for use by Corman Technologies, Inc.
//

/**
 * Originally grabbed from the official RaphaelJS Documentation
 * http://raphaeljs.com/graffle.html
 * Adopted (arrows) and commented by Philipp Strathausen http://blog.ameisenbar.de
 * Licenced under the MIT licence.
 */

/**
 * Usage:
 * connect two shapes
 * parameters: 
 *      source node, 
 *      target node,
 *      style with { fg : linecolor, bg : background color, directed: boolean }
 * returns:
 *      connection { draw = function() }
 */
Raphael.fn.connection = function (src, tgt, style) {
    var selfRef = this;
    
    var obj1 = src.shape;
    var obj2 = tgt.shape;
    
    /* create and return new connection */
    var edge = {/*
        from : obj1,
        to : obj2,
        style : style,*/
        draw : function() {
        
            /* get bounding boxes of target and source */
            var bb1 = obj1.getBBox();
            var bb2 = obj2.getBBox();
            var off1 = 0;
            var off2 = 0;
            
            /* coordinates for connection from/to the objects */
            var p = [];
            
            if (tgt.isScNode) {
            
                if (tgt.isRelationNode) {       // edge from root to sc rel node
                
                     p = [
                        {x: bb1.x - off1, y: bb1.y + bb1.height / 2},             /* WEST  1 */
                        {x: bb2.x + bb2.width / 2, y: bb2.y - off2},              /* NORTH 2 */
                    ];
                }
                else {      // edges in the superclass branch
                
                    p = [
                    {x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height + off1}, /* SOUTH 1 */
                    {x: bb2.x - off2, y: bb2.y + bb2.height / 2}              /* WEST  2 */
                ];
                
                }
            
            }
            else {          // edges in the child concept tree
            
                p = [
                    {x: bb1.x + bb1.width + off1, y: bb1.y + Math.floor(bb1.height / 2)}, /* EAST  1 */
                    {x: bb2.x - off2, y: bb2.y + Math.floor(bb2.height / 2)}              /* WEST  2 */
                ];
            }
 
        
            /* assemble path and arrow */
            var path;
            var x1 = p[0].x,
                y1 = p[0].y,
                x2 = p[1].x,
                y2 = p[1].y;
            
            if (tgt.isScNode) {
                if (tgt.isRelationNode) {
                    path = ["M", x1, y1, "L", x2, y1, "L", x2, y2];
                }
                else {
                    path = ["M", x1, y1, "L", x1, y2, "L", x2, y2];
                }
            }
            else {
                //path = ["M", x1, y1, "L", x2, y2];   // straight diagonal line
                path = ["M", x1, y1, "L", x1 + 10, y1, "L", x1 + 10, y2, "L", x2, y2];  // rt-angle bent line
            }
             
             
            
            /* applying path(s) */
            edge.fg && edge.fg.attr({path:path}) 
                || (edge.fg = selfRef.path(path).attr({stroke: style && style.stroke || "#000", fill: "none"}).toBack());
            edge.bg && edge.bg.attr({path:path})
                || style && style.fill && (edge.bg = style.fill.split && selfRef.path(path).attr({stroke: style.fill.split("|")[0], fill: "none", "stroke-width": style.fill.split("|")[1] || 3}).toBack());
           
            /* setting label */
            style && style.label 
                && (edge.label && edge.label.attr({x:(x1+x2)/2, y:(y1+y2)/2}) 
                    || (edge.label = selfRef.text((x1+x2)/2, (y1+y2)/2, style.label).attr({fill: "#000", "font-size":"10px"})));

        }
    }
    edge.draw();
    return edge;
};

