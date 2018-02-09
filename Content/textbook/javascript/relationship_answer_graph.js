
//
// Corman Technologies, Inc.
//

//
// EPS,
// 09-22-11
// Javascript for presenting relationship graphs on answer pages.
// Redefines a bunch of functions from the dracula_graph and dracula_graffle js files,
// so be sure it gets loaded after those two.
//

var setClassForGraphLinks = function(className) {
   
    var svgs = document.getElementsByTagName("svg");
    for (var i = 0; i < svgs.length; i++) {
    
        var svg = svgs[i];
        var anchors = svg.getElementsByTagName("a");
        for (var j = 0; j < anchors.length; j++) {
            var a = anchors[j];
            a.setAttribute("class", className);
        }
    }
}

var loadJsFile = function(file) {
    var script = document.createElement('script');
    if (script != null) {
        script.setAttribute("type", "text/javascript");
        script.setAttribute("src", file);
        document.getElementsByTagName("head")[0].appendChild(script);
    }
}

var onAnswerPage = true;

// redefine Graph.Layout.Spring.layoutGraph for Answer Page cmaps
var layoutAnswerPageCmap = function() {
                 
             // Assume first node is root and recursively layout nodes.
             var root = this.graph.nodelist[0];
             this.graph.rootId = root.id;
                           
             this.buildRelationTree();
             //this.buildSuperclassBranch(root);

             var startX = 35;
             var startY = 5;
             this.layoutNode(root, startX, startY);
             //this.layoutSuperclasses(root);
             
             // note offset of root node
             // for use later in translation of points to canvas
             // should be called after layout since it's based on max node ht
             this.calcOffsets(startX, startY);

        };
        
//var descriptions = [];
var addDescriptions = function(g, id) {
    //document.writeln("in addDescriptions id is: " + id);
    var descripDiv = document.getElementById(id);
    if (descripDiv != null) {
        //for (i in descriptions) {
        for (i in g.descriptions) {
            //var descrip = descriptions[i];
            var descrip = g.descriptions[i];
            
            // create a p elt to measure then remove it, reset the top taking p's height into account and re-add it.
            var p = document.createElement("p");
            p.id = descrip.id;
            p.className = "answer-part-description";
            p.style.position = "absolute";
            p.style.top = descrip.yPos + g.yoffset + 'px'; // <-- translate yPos based on yoffset of graph
            p.style.left = '282px';
            p.innerHTML = descrip.description;
            descripDiv.appendChild(p);
            var pHt = $("#"+p.id).height();
            
            descripDiv.removeChild(p);
            
            p.style.top = descrip.yPos + g.yoffset - pHt/2 + 'px';
            descripDiv.appendChild(p);
        }
    }
}

var isMainNode = function(graph, node){
    return (node.id == graph.rootId || node.children == null || node.children.length < 1);
}


// redefine Graph.Layout.Spring.layoutNode for Answer Page cmaps
var layoutAnswerPageNode = function(node, x, y) {
                
                node.layoutPosX = x;
                node.layoutPosY = y;
                
                // adjust inverted relation nodes to the left
                if (node.isRelationNode && node.inverted) {
                
                    node.layoutPosX -= 100;
                }
                
                //var isMainNode = (node.id == this.graph.rootId || node.children == null || node.children.length < 1);
                var fontSize = isMainNode(this.graph, node) ? 17 : 12;
                
                // map node id to yPos/description pair
                if (node.description && node.description.length > 0) {
                   // document.writeln("description from node " + node.description);
                   //descriptions.push( { id: node.id, yPos: y, description: node.description } );
                    this.graph.descriptions.push( { id: node.id, yPos: y, description: node.description } );
                    
                }
                
                var ttlChildHt = getNodeHt(fontSize, node.label);// + (node.id == this.graph.rootId ? 0 : 20);  
                //document.writeln("node:ht " + node.label + ":" + ttlChildHt);
                for (var i = 0; i < node.children.length; i++)
                {
                    var child = node.children[i];
                                                                 
                    //document.write(node.label + "->" + child.label + " [y:" + y + ", nodeHt + 20:" + (getNodeHt(fontSize, node.label) + 20) + "]<br>");                   
                    var childFontSize = isMainNode(this.graph, child) ? 17 : 12;
                    ttlChildHt += this.layoutNode(child, x, y + ttlChildHt + Math.ceil(getNodeHt(childFontSize, child.label)/2));// + 20;
                    
                }
                
                // calc total node ht
                var ht = getNodeHt(fontSize, node.label);            
                var ttlNodeHt = ht;//Math.max(ht + 20, ttlChildHt);
                //document.write(node.label + "[ht:"+ht+"]  this.graph.ttlHt: "+this.graph.ttlHt+ ", ttlNodeHt: "+ttlNodeHt+"<BR>");
                    
                if (node.id == this.graph.rootId)
                    this.graph.topNodeHt = ht;//Math.max(this.graph.maxNodeHt, ht);  // track largest single node ht for translating pts to canvas
                this.graph.ttlHt = Math.max(this.graph.ttlHt, y + ttlNodeHt);
                //node.label = this.graph.ttlHt;
                //document.write("ttlHt:"+this.graph.ttlHt+"<BR>");
                
                // debug take this out
                //node.label = "(" + node.layoutPosX + ", " + node.layoutPosY + ") \nht:" + ht;
                
                return ttlNodeHt;
                
        };
        
// redefine Raphael.fn.connection for Answer Page cmaps
Raphael.fn.connection = (function () {

    var origConnectionFnx = Raphael.fn.connection;
    
    if (onAnswerPage) {
    
        return function(src, tgt, style) {
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
                    var off1 = 5;
                    var off2 = 5;
                    
                    /* coordinates for connection from/to the objects */
                    var p = [];
                    if (tgt.isRelationNode && tgt.inverted) {       
                    
                        p = [
                            {x: bb1.x, y: bb1.y + bb1.height / 2 + off1},             /* WEST  1 */
                            {x: bb2.x + bb2.width / 2, y: bb2.y},                     /* NORTH 2 */
                        ];
                    }
                    else if (src.isRelationNode && src.inverted) {
                        p = [
                            {x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height + off1}, /* SOUTH 1 */
                            {x: bb2.x, y: bb2.y + bb2.height / 2 - off2},             /* WEST  2 */
                        ];
                    }
                    else if (style && style.inverted) {
                        p = [            
                            {x: bb1.x, y: bb1.y + bb1.height / 2 + off1},             /* WEST  1 */
                            {x: bb2.x, y: bb2.y + bb2.height / 2 - off2},             /* WEST  2 */
                        ];
                    }
                    else {
                        p = [            
                            {x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height},        /* SOUTH 1 */
                            {x: bb2.x + bb2.width / 2, y: bb2.y}                      /* NORTH 2 */
                        ];
                    }
         
                    //
                    /* assemble path and arrow */
                    //
                    
                    // build path
                    var x1 = p[0].x,
                        y1 = p[0].y,
                        x2 = ((style && style.inverted) || (src.isRelationNode && src.inverted) || (tgt.isRelationNode && tgt.inverted)) ? p[1].x : x1, //  <-- just use same x here so we don't end up with crooked lines when the width division above truncates in one case and not the other
                        y2 = p[1].y;
                    
                    var path;
                    if (src.isRelationNode && src.inverted) {
                        path = ["M", x1, y1, "L", x1, y2, "L", x2, y2];  // rt-angle bent line  (down and right)
                    }
                    else if (tgt.isRelationNode && tgt.inverted) {
                        path = ["M", x1, y1, "L", x2, y1, "L", x2, y2];  // rt-angle bent line  (left and down)
                    }
                    else if (style && style.inverted) {
                        var xOffsetLeft = Math.max(x1-35, x2-35);
                        path = ["M", x1, y1, "L", xOffsetLeft, y1, "L", xOffsetLeft, y2, "L", x2, y2];  // left-down-right
                    }
                    else {
                        path = ["M", x1, y1, "L", x2, y2];   // straight line
                    }
                    
                    
                    
                    // add arrow to directed connections
                    if (style && style.directed) {
                        if (style.inverted) {
                            path.push("M", x1, y1, "L", x1-8, y1-6, "M", x1, y1, "L", x1-8, y1+6);
                        }
                        else {
                            path.push("M", x2, y2, "L", x2-6, y2-8, "M", x2, y2, "L", x2+6, y2-8);
                        }
                    }
    //                    path = ["M", x1, y1, "L", x1 + 10, y1, "L", x1 + 10, y2, "L", x2, y2];  // rt-angle bent line


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
        }
    }
    else {
    
        return origConnectionFnx;
    }
})();        


//
// Raphael Layout for answer pages
//
function AnswerPageRenderer(element, graph, width) {
        
    this.width = width;  
    this.height = graph.ttlHt + graph.yoffset;
    var selfRef = this;
    this.r = Raphael(element, this.width, this.height);

    this.graph = graph;
    this.mouse_in = false;
    
    this.nodeDown = false;
    
    /* TODO default node rendering function */
    if(!this.graph.render) {
        this.graph.render = function() {
            return;
        }
    }
}

var answerPageDrawNode = function(node) {
        var point = this.translate([node.layoutPosX, node.layoutPosY]);
        node.point = point;
        
        /* if node has already been drawn, move the nodes */
        if(node.shape) {
            var oBBox = node.shape.getBBox();
            var opoint = [ oBBox.x + Math.round(oBBox.width / 2) , oBBox.y + Math.round(oBBox.height / 2) ];
            node.shape.translate(point[0]-opoint[0], point[1]-opoint[1]);
            this.r.safari();
            return;
        }/* else, draw new nodes */
        var shape;
        /* if a node renderer function is provided by the user, then use it */
        if(node.render) {
            shape = node.render(this.r, node);
        /* or check for an ajax representation of the nodes */
        } else if(node.shape) {
            // TODO ajax representation
        /* the default node drawing */
        } else {
            var color = Raphael.getColor();
            shape = this.r.set().
                push(this.r.ellipse(point[0], point[1], 30, 20).attr({fill: color, stroke: color, "stroke-width": 2})).
                push(this.r.text(point[0], point[1] + 30, node.label || node.id));
        }
        
        if (node.url)
            shape.attr({"href": node.url});
            
        //shape.attr({"fill-opacity": 1});

        node.shape = shape;
    };
    
AnswerPageRenderer.prototype = Graph.Renderer.Raphael.prototype;
AnswerPageRenderer.prototype.constructor = AnswerPageRenderer;
AnswerPageRenderer.prototype.drawNode = answerPageDrawNode;



//
// redefine Graph.Renderer.Raphael for answer pages
//
Graph.Renderer.Raphael = (function () {

    var origRaphConstructor = Graph.Renderer.Raphael;
    
    if (onAnswerPage) {
    
        return AnswerPageRenderer;
    }
    else {
        
        return origRaphConstructor;
    }
})();





//
// generate node renderer
//
//Concept nodes with links:
//fill: 270-#e7e8ea-#b7bbc2
//stroke: #babfc6
//stroke-width: 1

//Concept nodes w/out links:
//fill: #e6e7eb
//stroke: #babfc6
//stroke-width: 1
//
//All text should be #3d424f with opacity:1 (currently they use 0.6)
//
var makeNodeRenderer = function(h, w, cornerRad, fontSize, isLink) {
  
  var borderWidth = 2;//isLink ? 2 : 1;
  var borderColor = isLink ? "#babfc6" : "#babfc6";
  var fill        = isLink ? "270-#e7e8ea-#b7bbc2" : "#e6e7eb";

  
  return function(r, n) {
      /* the Raphael set is obligatory, containing all you want to display */
      var set = r.set().push(
                    /* custom objects go here */
                    r.rect(n.point[0]-(w/2), n.point[1]-(h/2), w, h).attr({ "fill":fill, "r":cornerRad, "stroke-width":borderWidth, "stroke-linejoin": "round", "stroke":borderColor })).push(
                    r.text(n.point[0], n.point[1] + 0, (n.label || n.id)).attr({ "fill":"#3d424f", "fill-opacity":1, "font-size":fontSize }));
      return set;
  };
}

var makeEventNodeRenderer = function(h, w, cornerRad, fontSize, isLink) {
  
  var borderWidth = 2;//isLink ? 2 : 1;
  var borderColor = isLink ? "#69a4c5" : "#69a4c5";
  var fill        = isLink ? "270-#ace2ff-#72b3d6" : "#d0edfe";

  
  return function(r, n) {
      /* the Raphael set is obligatory, containing all you want to display */
      var xLft = n.point[0]-(w/2);
      var yTop = n.point[1]-(h/2);
      var xRgt = xLft + w;
      var yBtm = yTop + h;
      
      var start = xLft + 5;
      
      var path = ["M", xLft + cornerRad, yTop, "L", xRgt - cornerRad, yTop, "L", xRgt, yTop + cornerRad, "L", xRgt, yBtm - cornerRad, "L", xRgt - cornerRad, yBtm, "L", xLft + cornerRad, yBtm, "L", xLft, yBtm - cornerRad, "L", xLft, yTop + cornerRad, "L", xLft + cornerRad, yTop, "z"];
      //var path = ["M", 10, 10, "L", xRgt - cornerRad, yTop, "L", xRgt, yTop + cornerRad, "L", xRgt, yBtm - cornerRad, "L", xRgt - cornerRad, yBtm, "L", xLft + cornerRad, yBtm, "L", xLft, yBtm - cornerRad, "L", xLft, yTop + cornerRad, "L", xLft + cornerRad, yTop, "z"];
      //var path = ["M",start,yTop,"L",10,20,"L",20,20,"z"];
      //var pathTest = ["M", n.point[0], n.point[1], "L", n.point[0] + 50, n.point[1]];
      //.push(r.path(pathTest).attr({ "fill":fill, "stroke-width":borderWidth, "stroke":"#ff0000" }))
      var set = r.set().push(
                    /* custom objects go here */
                    r.path(path).attr({ "fill":fill, "stroke-width":borderWidth, "stroke":borderColor })).push(
                    r.text(n.point[0], n.point[1] + 0, (n.label || n.id)).attr({ "fill":"#3d424f", "fill-opacity":1, "font-size":fontSize }));
      return set;
  };
}

//var stdRenderFn  = makeNodeRenderer(40, 100,  "4px", "12px", false);
//var mainRenderFn = makeNodeRenderer(57, 140, "10px", "17px", true);
var relationRenderFn = function(r, n) {
            /* the Raphael set is obligatory, containing all you want to display */
            var ht = getRelNodeHt(12, n.label);
            var set = r.set().push(
                /* custom objects go here */
                r.rect(n.point[0]-50, n.point[1]-(ht/2), 100, ht).attr({"fill": "#ffffff", "stroke": "#ffffff", "stroke-width" : "0px" })).push(
                r.text(n.point[0], n.point[1] + 0, (n.label || n.id)).attr({"fill": "#3D424F", "fill-opacity":1, "font-size":"12px"}));
            return set;
        };

var getNodeHt = function(fontSize, label){
var numLines = label.split("\n").length;
//document.writeln("get node ht:<br>");
//document.writeln("       label: " + label +"<br>");
//document.writeln("    numlines: " + numLines +"<br>");
//document.writeln("    fontsize: " + fontSize +"<br>");
//document.writeln("     node ht: " + (numLines + 2) * (fontSize*1.1) +"<br>");
    return (numLines + 2) * (fontSize*1.1);
};

var getRelNodeHt = function(fontSize, label){
var numLines = label.split("\n").length;
//document.writeln("get node ht:<br>");
//document.writeln("       label: " + label +"<br>");
//document.writeln("    numlines: " + numLines +"<br>");
//document.writeln("    fontsize: " + fontSize +"<br>");
//document.writeln("     node ht: " + (numLines + 2) * (fontSize*1.1) +"<br>");
    return (numLines + 1) * (fontSize*1.1);
};
        
var getMainNodeRenderer = function(label, isLink, isEvent) {
    var ht = getNodeHt(17, label);
    var width = 165;
    if (isEvent)
        return makeEventNodeRenderer(ht, width, 10, "17px", isLink);
    else
        return makeNodeRenderer(ht, width, 10, "17px", isLink);
};

var getStdNodeRenderer = function(label, isLink, isEvent) {
    var ht = getNodeHt(12, label);
    var width = 135;
    if (isEvent)
        return makeEventNodeRenderer(ht, width, 10, "12px", isLink);
    else    
        return makeNodeRenderer(ht, width, 4, "12px", isLink);
};


var addStdNode = function(g, id, label, description, info) { 
    var url = info && info.url != null ? info.url : "";
    var isEvent = info && info.isEvent;
    addNode(g, id, label, description, url, getStdNodeRenderer(label, url.length > 0, isEvent));
}

var addMainNode = function(g, id, label, description, info) { 
    var url = info && info.url != null ? info.url : "";
    var isEvent = info && info.isEvent;
    addNode(g, id, label, description, url, getMainNodeRenderer(label, url.length > 0, isEvent));
}

var addRelationNode = function(g, id, label, inverted) {
    g.addNode(id, { isRelationNode:true, inverted:inverted, label:label, description:"", url:"", render:relationRenderFn });
}

var addNode = function(g, id, label, description, url, renderFn) {
    g.addNode(id, { label:label, description:description, url:url, render:renderFn });
}

var addEdge = function(g, from, to, style) {
    var directed = (style && style.directed);
    var inverted = (directed && style.inverted);
    g.addEdge(from, to, { directed:directed, inverted:inverted, stroke:"#636569" });
}

var addRelation = function(g, label, relId, srcId, tgtId, style) {
    var directed = (style && style.directed);
    var inverted = (directed && style.inverted);
    var hideRelationNode = (style && style.hideRelationNode);
    
    if (hideRelationNode) {
        addEdge(g, srcId, tgtId, { directed:directed, inverted:inverted });
    }
    else {
        addRelationNode(g, relId, label, inverted);
        addEdge(g, srcId, relId, { directed:(directed && inverted), inverted:inverted });
        addEdge(g, relId, tgtId, { directed:(directed && !inverted), inverted:inverted }); 
    }
}

var renderGraph = function(g, id) {

    //document.writeln("in renderGraph id is: " + id);
    /* layout the graph using the Spring layout implementation */
    var layouter = new Graph.Layout.Spring(g);
    layouter.layoutGraph = layoutAnswerPageCmap;  // <-- switch to QA layout fnx
    layouter.layoutNode = layoutAnswerPageNode;   // <-- switch to QA layout fnx
    layouter.calcOffsets = function(x, y) {
                
                // assumes main concept width of 165px
                this.graph.xoffset = 165/2 + x;
                this.graph.yoffset = this.graph.topNodeHt/2 + y;

                //document.write("node: "+ node.id + ", " +this.graph.xoffset + ", " + this.graph.yoffset);
        };
    layouter.layout();
    /* draw the graph using the RaphaelJS draw implementation */
    var renderer = new Graph.Renderer.Raphael(id, g, 272);  
    renderer.draw();
};

