
//
// Adapted for use by Corman Technologies, Inc.
//


/*
 *  Dracula Graph Layout and Drawing Framework 0.0.3alpha
 *  (c) 2010 Philipp Strathausen <strathausen@gmail.com>, http://strathausen.eu
 *
 *  based on the Graph JavaScript framework, version 0.0.1
 *  (c) 2006 Aslak Hellesoy <aslak.hellesoy@gmail.com>
 *  (c) 2006 Dave Hoover <dave.hoover@gmail.com>
 *
 *  Ported from Graph::Layouter::Spring in
 *    http://search.cpan.org/~pasky/Graph-Layderer-0.02/
 *  The algorithm is based on a spring-style layouter of a Java-based social
 *  network tracker PieSpy written by Paul Mutton E<lt>paul@jibble.orgE<gt>.
 *
 *  This code is freely distributable under the terms of an MIT-style license.
 *  For details, see the Graph web site: http://dev.buildpatternd.com/trac
 *
 *  Links:
 *
 *  Graph Dracula JavaScript Framework:
 *      http://graphdracula.net
 *
 *  Demo of the original applet:
 *      http://redsquirrel.com/dave/work/webdep/
 *
 *  Mirrored original source code at snipplr:
 *      http://snipplr.com/view/1950/graph-javascript-framework-version-001/
 *
 *  Original usage example:
 *      http://ajaxian.com/archives/new-javascriptcanvas-graph-library
 *
/*--------------------------------------------------------------------------*/



/*
 * Graph
 */
var Graph = function() {
    this.descriptions = [];
    this.nodes = [];
    this.nodelist = []; // nodes by index number, only used once TODO use only one node container
    this.edges = [];
    //this.snapshots = []; // previous graph states
    this.maxNodeHt = -Infinity;
    this.ttlHt = -Infinity;
    this.maxNodeWd = 140;       // width of root concept nodeS
};
Graph.prototype = {
    /* 
     * add a node
     * @id          the node's ID (string or number)
     * @content     (optional, dictionary) can contain any information that is
     *              being interpreted by the layout algorithm or the graph
     *              representation
     */
    addNode: function(id, content) {
    
        /* testing if node is already existing in the graph */
        if(this.nodes[id] == undefined) {
                this.nodes[id] = new Graph.Node(id, content || {"id" : id}); /* nodes indexed by node id */
                this.nodelist.push(this.nodes[id]); /* node list indexed by numbers */
        }
        return this.nodes[id];
        
    },

    addEdge: function(source, target, style) {
    
        var s = this.addNode(source);
        var t = this.addNode(target);
        var edge = { source: s, target: t, style: style, weight: style&&style.weight||1 }; // TODO tidy up here
        s.edges.push(edge);
        this.edges.push(edge);

    },
    
    /*
     * Preserve a copy of the graph state (nodes, positions, ...)
     * @comment     a comment describing the state
     * @about       a list with objects to be marked as significant in this state (TODO)
     */
    snapShot: function(comment, about) {
        // TODO get rid of the jQuery plugin dependence just for the deep copying
        var graph = new Graph();
        jQuery.extend(true, graph.nodes, this.nodes);
        jQuery.extend(true, graph.nodelist, this.nodelist);
        jQuery.extend(true, graph.edges, this.edges);
        graph.snapShot = null;
        this.snapshots.push({comment: comment, graph: graph});
    }
};

/*
 * Node
 */
Graph.Node = function(id, value){
    value.id = id;
    value.edges = [];
    return value;
};
Graph.Node.prototype = {
};

/*
 * Renderer base class
 */
Graph.Renderer = {};

/*
 * Renderer implementation using RaphaelJS
 */
Graph.Renderer.Raphael = function(element, graph) {

    this.width = 620;  
    this.height = graph.ttlHt + graph.yoffset;
    var selfRef = this;
    this.r = Raphael(element, this.width, this.height);

    this.graph = graph;
    this.mouse_in = false;
    
    this.nodeDown = false;
    

    //document.write("checking for renderer<br>");
    /* TODO default node rendering function */
    if(!this.graph.render) {
        this.graph.render = function() {
            return;
        }
    }
    
   
};
Graph.Renderer.Raphael.prototype = {

    translate: function(point) {

        return[ point[0] + this.graph.xoffset, point[1] + this.graph.yoffset];

    },

    rotate: function(point, length, angle) {
        var dx = length * Math.cos(angle);
        var dy = length * Math.sin(angle);
        return [point[0]+dx, point[1]+dy];
    },

    draw: function() {

        for (i in this.graph.nodes) {
            this.drawNode(this.graph.nodes[i]);
        }
        for (var i = 0; i < this.graph.edges.length; i++) {
            this.drawEdge(this.graph.edges[i]);
        }
    },

    drawNode: function(node) {
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
        {
            shape.attr({"href": node.url});
            shape.attr({"class":"keywords"});
        }
            
        shape.attr({"fill-opacity": .6});

        node.shape = shape;
    },
    drawEdge: function(edge) {
        /* if this edge already exists the other way around and is undirected */
        if(edge.backedge)
            return;
        /* if edge already has been drawn, only refresh the edge */
        edge.connection && edge.connection.draw();
        if(!edge.connection) {
            edge.style && edge.style.callback && edge.style.callback(edge);//TODO move this somewhere else
            edge.connection = this.r.connection(edge.source, edge.target, edge.style);
        }
    }
};
Graph.Layout = {};
Graph.Layout.Spring = function(graph) {
                this.graph = graph;
        };
Graph.Layout.Spring.prototype = {
        layout: function() {
        
                this.layoutPrepare();
                this.layoutGraph();
                               
        },
       
        layoutPrepare: function() {
            for (i in this.graph.nodes) {
                    var node = this.graph.nodes[i];
                        node.layoutPosX = 0;
                        node.layoutPosY = 0;
                        node.layoutForceX = 0;
                        node.layoutForceY = 0;
                }
                
        },
       

        layoutGraph: function() {
                 
             // Assume first node is root and recursively layout nodes.
             var root = this.graph.nodelist[0];
             this.graph.rootId = root.id;
                           
             this.buildRelationTree();
             this.buildSuperclassBranch(root);

             var startX = 25;
             var startY = 0;
             this.layoutNode(root, startX, startY);
             this.layoutSuperclasses(root);
             
             // note offset of root node
             // for use later in translation of points to canvas
             // should be called after layout since it's based on max node ht
             this.calcOffsets(startX, startY);

        },
        
        
        // build the superclass branch off root node
        buildSuperclassBranch: function(root){
            
            root.superclasses = [];
            for (var i = 0; i < this.graph.nodelist.length; i++) { //in this.graph.nodes) {
 
                var node = this.graph.nodelist[i]; //nodes[i];
                if (node.isScNode)       
                    root.superclasses.push(node);
                
             }
             
        },
        
        
        // build the child relation tree
        buildRelationTree: function(){
            
             for (var i = 0; i < this.graph.nodelist.length; i++) { //in this.graph.nodes) {
 
                var node = this.graph.nodelist[i]; //nodes[i];
                node.children = [];
                        
                if (!node.isScNode) {   // skip superclass nodes

                    for (var j = 0; j < this.graph.edges.length; j++) {
                        var edge = this.graph.edges[j];
                        
                        if (edge.source === node &&
                            !edge.target.isScNode)  // skip superclass targets
                        {
                           node.children.push(edge.target);
                       }              
                    }
                    
                }
                
             }
             
        },
        
        
        calcOffsets: function(x, y) {
                
                // assumes main concept width of 140px
                this.graph.xoffset = this.graph.maxNodeWd/2 + x;
                this.graph.yoffset = this.graph.maxNodeHt/2 + y;

                //document.write("node: "+ node.id + ", " +this.graph.xoffset + ", " + this.graph.yoffset);
        },
        
        
        getNodeHt: function(node) {
        
            var fontSize = node.id == this.graph.rootId ? 20 : 10;
            var numLines = node.numLines ? node.numLines : 1;
            var ht = Math.ceil((numLines +2) * (fontSize*1.1));
            return ht;
            
        },
        
        
        getChildOffsetX: function(node, child){
        
                var offset = 114;
                if (child.isRelationNode)
                {
                    // special handling for root node since it's wider
                    if (node.id == this.graph.rootId)       
                        offset = 115;
                    else
                        offset = 95;
                }
        
                return offset;
                
        },
        
               
        layoutNode: function(node, x, y) {
                
                //document.writeln("layout node " + node.id + " at [" + x +","+y+"]<br>");
                node.layoutPosX = x;
                node.layoutPosY = y;
                
                var ttlChildHt = 0;
                for (var i = 0; i < node.children.length; i++)
                {
                    var child = node.children[i];
                                                                 
                    //document.write(node.label + "->" + child.label + " [y:" + y + ", ttlChildHt:" + ttlChildHt + "]<br>");                   
                    ttlChildHt += this.layoutNode(child, x + this.getChildOffsetX(node, child), y + ttlChildHt) + 10;
                    
                }
                
                // calc total node ht
                var ht = this.getNodeHt(node);            
                var ttlNodeHt = Math.max(ht + 20, ttlChildHt);
                //document.write(node.label + "[ht:"+ht+"]  this.graph.ttlHt: "+this.graph.ttlHt+ ", ttlNodeHt: "+ttlNodeHt+"<BR>");
                    
                
                this.graph.maxNodeHt = Math.max(this.graph.maxNodeHt, ht);  // track largest single node ht for translating pts to canvas
                this.graph.ttlHt = Math.max(this.graph.ttlHt, y + ttlNodeHt);
                //node.label = this.graph.ttlHt;
                //document.write("ttlHt:"+this.graph.ttlHt+"<BR>");
                
                return ttlNodeHt;
                
        },
        
        // layout superclass branch off root node
        // assumes that root and child tree have already been through the layout process
        //
        layoutSuperclasses: function(root) {
                
                var lftRoot = root.layoutPosX;
                var btmRoot = root.layoutPosY + this.getNodeHt(root);
                var y = btmRoot;
                
                for (var i = 0; i < root.superclasses.length; i++) {
                
                    var node = root.superclasses[i];
                    
                    if (node.isRelationNode) {
                    
                        node.layoutPosX = lftRoot - 85;
                        node.layoutPosY = btmRoot - 10;
 
                    }
                    else {
                    
                        //document.writeln("layout node " + node.id + " at [" + x +","+y+"]<br>");
                        node.layoutPosX = lftRoot;
                        node.layoutPosY = y;
                    
                    }
                    
                    y += this.getNodeHt(node) + 30;
                    
                }
                
                // update graph total height as necessary
                this.graph.ttlHt = Math.max(this.graph.ttlHt, y);
                
        }
         
};



function log(a) {console.log&&console.log(a);}


/*
 * Raphael Tooltip Plugin
 * - attaches an element as a tooltip to another element
 *
 * Usage example, adding a rectangle as a tooltip to a circle:
 *
 *      paper.circle(100,100,10).tooltip(paper.rect(0,0,20,30));
 *
 * If you want to use more shapes, you'll have to put them into a set.
 *
 */
Raphael.el.tooltip = function (tp) {
    this.tp = tp;
    this.tp.o = {x: 0, y: 0};
    this.tp.hide();
    this.hover(
        function(event){ 
            this.mousemove(function(event){ 
                this.tp.translate(event.clientX - 
                    this.tp.o.x,event.clientY - this.tp.o.y);
                this.tp.o = {x: event.clientX, y: event.clientY};
            });
            this.tp.show().toFront();
        }, 
        function(event){
            this.tp.hide();
            this.unmousemove();
            });
    return this;
};
