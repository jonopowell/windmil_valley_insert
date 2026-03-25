// Download both files into the same directory and make a copy of this template for each project. Adjust the variables and values as needed to override the defaults in this file as needed. In this way you can replace the `Ultimate_Box_Generator.scad` file with a new version without having to track and restore your changes.

// If you want to use any framework variables in calulations you must import them here. If you want to also change the variable you must use a second line below to do that.
//wall=wall;
//internal_wall=internal_wall;

// Include the framework. You can change the prefix to load from a shared path.
include    <Ultimate_Box_Generator.scad>;

// Compatibility shims for strict named-argument validation in newer OpenSCAD builds.
// These mirror generator behavior without modifying Ultimate_Box_Generator.scad.
function calc_size(repeat, comp_size, internal_wall=internal_wall, wall=wall) = repeat * (comp_size + internal_wall) - internal_wall + wall*2;
function calc_offset(repeat, comp_size, internal_wall=internal_wall, wall=wall) = repeat * (comp_size + internal_wall) + wall;

module make_box_internal(comp_size_x=comp_size_x, comp_size_y=comp_size_y, internal_size_deep=internal_size_deep, internal_type=internal_type, repeat_x=repeat_x, repeat_y=repeat_y, internal_fn=internal_fn, internal_rotate=internal_rotate, wall=wall, internal_wall=internal_wall) {
    internal_size_circle = internal_type == 1 ? internal_size_deep : internal_size_deep * 2 / sqrt(3);

    for ( ybox = [ 0 : repeat_y - 1])
    {
        for( xbox = [ 0 : repeat_x - 1])
        {
            offset_x=calc_offset(xbox, comp_size_x, internal_wall=internal_wall, wall=wall);
            offset_y=calc_offset(ybox, comp_size_y, internal_wall=internal_wall, wall=wall);
            render() {
                if(internal_type == 1 || internal_type == 2) {
                    translate([offset_x - (internal_rotate ? 0 : internal_wall), offset_y + (internal_rotate ? comp_size_y + internal_wall : 0), wall + internal_size_deep])
                    rotate([internal_rotate ? 90 : 0,90,0])
                    linear_extrude(internal_rotate ? comp_size_y + internal_wall*2: comp_size_x + internal_wall*2)
                    difference() {
                        square([internal_size_deep, internal_rotate ? comp_size_x: comp_size_y]);
                        hull() {
                            translate([0, internal_size_circle, 0])
                            rotate([0,0,90])

                            if(!internal_rotate && supress_walls_x[ybox-1][xbox] || internal_rotate && supress_walls_y[xbox-1][ybox])
                                square([internal_size_circle*2, internal_size_circle*2], center=true);
                            else
                                circle(r=internal_size_circle, $fn=internal_fn);

                            if((internal_rotate ? comp_size_x : comp_size_y) != internal_size_circle*2)
                                translate([0, (internal_rotate ? comp_size_x : comp_size_y) - internal_size_circle, 0])
                                rotate([0,0,90])
                            if(!internal_rotate && supress_walls_x[ybox][xbox] || internal_rotate && supress_walls_y[xbox][ybox])
                                square([internal_size_circle*2, internal_size_circle*2], center=true);
                             else
                                 circle(r=internal_size_circle, $fn=internal_fn);
                        }
                    }
                }
                if(internal_type == 3) {
                    internal_width = sqrt(internal_size_deep*internal_size_deep*2);
                    internal_items = ((internal_rotate ? comp_size_y : comp_size_x) - wall*2) / (internal_width*1.5);
                    internal_offset = (internal_items - floor(internal_items)) * internal_width;

                    rotate([0, 0, internal_rotate ? 90 : 0])
                    translate([offset_x, offset_y + (internal_rotate ? - comp_size_y - wall*2 : 0), internal_size_deep])
                    for(c=[0:internal_items]) {
                        translate([internal_offset + c * internal_width*1.5, 0, 0])
                        rotate([0,45,0])
                        cube([wall, comp_size_y + internal_wall, internal_size_deep]);
                    }
                }
            }
            if(internal_type == 4 || internal_type==5) {
                translate([offset_x, offset_y, wall])
                difference() {
                    cube([comp_size_x, comp_size_y, internal_size_deep]);

                    linear_extrude(internal_size_deep + .01)
                    translate([internal_size_circle/2 ,internal_size_circle/2 , internal_size_circle/2 ])
                    hull() {
                        circle(d=internal_size_circle, $fn=internal_fn);
                        if(comp_size_x-internal_size_circle > 0) {
                            translate([comp_size_x-internal_size_circle, 0])
                            circle(d=internal_size_circle, $fn=internal_fn);
                        }
                        if(comp_size_y-internal_size_circle > 0) {
                            translate([0, comp_size_y-internal_size_circle])
                            circle(d=internal_size_circle, $fn=internal_fn);
                        }
                        if(comp_size_x-internal_size_circle > 0 && comp_size_y-internal_size_circle > 0) {
                            translate([comp_size_x-internal_size_circle, comp_size_y-internal_size_circle])
                            circle(d=internal_size_circle, $fn=internal_fn);
                        }
                    }
                }
            }
            if(internal_corner_radius) {
                translate([offset_x + (supress_walls_y[xbox-1][ybox] ? internal_corner_radius : 0), offset_y + (supress_walls_x[ybox-1][xbox] ? internal_corner_radius : 0), wall])
                difference() {

                    cube([comp_size_x - (supress_walls_y[xbox][ybox] || supress_walls_y[xbox-1][ybox] ? internal_corner_radius : 0), comp_size_y - (supress_walls_x[ybox][xbox] || supress_walls_x[ybox-1][xbox] ? internal_corner_radius : 0), comp_size_deep]);

                    translate([min(comp_size_x/2, internal_corner_radius) - (supress_walls_y[xbox-1][ybox] ? internal_corner_radius : 0), min(comp_size_y/2, internal_corner_radius) - (supress_walls_x[ybox-1][xbox] ? internal_corner_radius : 0), internal_corner_radius])
                    minkowski() {
                        sphere(r=internal_corner_radius, $fn=corner_fn);
                        cube([max(.01, comp_size_x-internal_corner_radius*2), max(.01, comp_size_y-internal_corner_radius*2), max(.01, comp_size_deep*1.5 - internal_corner_radius*2)]);
                    }
                }
            }
        }
    }
}

// At this point you can start to adjust builtin varaibles and create your own. There are also some examples of more complex boxes at the end of the file.


// Parts to render. To do more complex opperations disable these and manually call make_box() and make_lid() instead.
show_box=false;	// Whether or not to render the box
show_lid=false;	// Whether or not to render the lid. To make open boxes with no lid set `show_lid=false` and `lid_type=5`.
lid_type=0; 

// General Settings
// comp_size_deep = 18; // Depth of compartments
// comp_size_x = 32;	 // Size of compartments, X
// comp_size_y = 24.6;	 // Size of compartments, Y
wall = 1.2;		    // Width of wall, see `internal_wall` below for alternate inner wall size.
internal_wall=0.8;
// repeat_x = 3;		// Number of compartments, X
// repeat_y = 2;		// Number of compartments, Y
//tolerance=.15;      // Tolerance around lid.  If it's too tight, increase this. If it's too loose, decrease it.

// Box Rounding
// box_corner_radius=1; // Add a rounding affect to the corners of the box. Anything over `wall` will cause structure and lid problems.
internal_corner_radius=.5; // Add a rounding affect to the inside.
//mesh_corner_radius=0; // Leave a radius around each corner of the mesh. May hep with bridges.
//corner_fn=30;

// Supress individual walls.
//supress_walls_x=[]; // These are the walls running along the X axis. It should be an array of size [repeat_y-1][repeat_x].
//supress_walls_y=[]; // These are the walls running along the Y axis. It should be an array of size [repeat_x-1][repeat_y].
// Example for repeat_x=4, repeat_y=3:
//supress_walls_x=[[1,1]];
//supress_walls_y=[[1,0,1],[0,1,1],[1,1,1]];
//supress_sides=false; // [X, Y, X, Y] Cutout/supress some sides. this may behave baddly with compartments or mesh.
//supress_sides_radius=wall; // Add a rounding to the cutout.
//supress_sides_offset=0; // 0, wall, [X, Y, Z] adjsut the coutout in all directions. + to grow, - so shrink
//supress_sides_fn=30;

//Internal Structure (You may need to turn off `mesh_do_sides` or `mesh_do_bottom` for good results.)
// You can also use `make_wall()` to manually add your own walls.
// 1: Rounded bottom frame.
// 2: Hexagon bottom frame. (To make this shape perfect set `comp_size_deep` to the width between to edges of the tile and set `comp_size_x` or `comp_size_y` to this this: `comp_size_deep / sqrt(3)*2`.
// 3: Rough bottom to make bits sit unevenly. (Partial)
// 4: Vertical rounding on corner. Set `internal_size_deep` to `comp_size_deep` and `internal_size_circle` to the shortest `comp_size` for a circle.
// 5: Vertical hexegon. Results may varry.
//internal_type=0; // Internal structure, see above.
//internal_rotate=false; // On lid axis or rotate to opposite.
//internal_size_deep=comp_size_deep/2; // How far into the box to start the internal structure. Should be `comp_size_deep/2` for type 1-2, `wall` for 3, or comp_size_deep for type 4-5.
//internal_size_circle=internal_type==1 ? internal_size_deep : internal_size_deep * 2 / sqrt(3); // Use this calculation, or the shorter comp_size for type 4-5.
//internal_fn=internal_type==1 || internal_type==4 ? 60 : 6; // Complexity of internal curves, may need to increase for larger or smoother curves.
//internal_wall=wall; // Custom size for internal walls.


// Complex Structure
//make_complex_box=false; // Use an array of objects from `complex_box` to create many smaller boxes within the larger box.
//internal_grow_down=true; // If set compartments will be extruded into the larger box from the top to make a flush surface. (May make a model that uses a lot of material.
//internal_empty_bottom=false; // If set the area blow each box will be empty. This will not be printable on a FDM printer unless supports are included internally but still may save material and print time.



// In addition you can set `show_box=false;` and then call `make_box()` manually to join and remove more structure to it like in this example.
/*show_box=false;
difference() {
    make_box();
    translate([0, comp_size_y/2 + wall, 0])
    rotate([0, 90, 0])
    cylinder(comp_size_x +wall*2, 10, 10);
}*/

// You can also use calls to `make_internal_box` to create more complex boxes within a larger box that share a single lid.
/*show_box=false;
make_box();
intersection() {     
    faction_x=10; faction_y=comp_size_y; faction_z=5; faction_repeat_x=3; faction_repeat_y=1;
    faction_size_x=calc_size(faction_repeat_x, faction_x, wall=internal_wall, internal_wall=internal_wall);
faction_size_y=calc_size(faction_repeat_y, faction_y, wall=internal_wall, internal_wall=internal_wall);
    
    translate([wall, wall, wall])
    cube([faction_size_x - wall, faction_size_y - wall*2, comp_size_deep]);
            
    translate([wall-internal_wall, wall-internal_wall, wall-internal_wall])
    union() {
        translate([0, 0, 0])
        make_internal_box(faction_x, faction_y, faction_z, wall=internal_wall, repeat_x=faction_repeat_x, repeat_y=faction_repeat_y);
    }
}*/

// This exmaple wil make a complex series of boxes in a larger container. The object's can be used to position other oebjects and create internal structure.
comp_size_x = 188.2; // external size add 2*wall to this
comp_size_y = 64;    // external width add 2*wall to this
comp_size_deep = 28; // external height add 2*wall to this

growdown_bottom_width = 15;
growdown_start_height = 20;
u_cut_size = 20;

module make_compartment_growdown(area, bottom_width, start_height) {
    top_width = area[0][1];
    side_growdown_width = (top_width - bottom_width) / 2;

    if (side_growdown_width > 0 && start_height > 0) {
        translate([wall + area[1][0], wall + area[1][1], wall])
        hull() {
            cube([area[0][0], side_growdown_width, .01]);
            translate([0, 0, start_height])
            cube([area[0][0], .01, .01]);
        }

        translate([wall + area[1][0], wall + area[1][1] + top_width - side_growdown_width, wall])
        hull() {
            cube([area[0][0], side_growdown_width, .01]);
            translate([0, side_growdown_width - .01, start_height])
            cube([area[0][0], .01, .01]);
        }
    }
}

module make_compartment_u_cut(area, cut_size) {
    translate([wall + area[1][0] - wall - .5, wall + area[1][1] + area[0][1] / 2, wall + comp_size_deep])
    rotate([0, 90, 0])
    cylinder(h=area[0][0] + wall * 2 + 1, d=cut_size, $fn=40);
}

// internal_wall=0.8;
// make the external box with no internal curves
//internal_size_deep=comp_size_deep  ;
internal_grow_down=true;
internal_type=0;
box_corner_radius=1;
boxWidth=42;
compartmentDepth=comp_size_deep;
offY=0;
box_corner_radius=0; // Add a rounding affect to the corners of the box. Anything over `wall` will cause structure and lid problems.
comp1=make_object( x=82    ,y=boxWidth ,z=compartmentDepth, offset_x=0    ,offset_y=offY, repeat_x=1, repeat_y=1, color="Blue");
comp2=make_object( x=52.3  ,y=boxWidth ,z=compartmentDepth, offset_x=82.8 ,offset_y=offY, repeat_x=1, repeat_y=1, color="green");
comp3=make_object( x=52.3  ,y=boxWidth ,z=compartmentDepth, offset_x=135.9,offset_y=offY, repeat_x=1, repeat_y=1, color="orange");
complex_box=[
   comp1,comp2,comp3
];
// make the internal compartments
internal_type=0; // Keep compartment walls straight (no curved internal profile).
//internal_rotate=false; // On lid axis or rotate to opposite.
internal_corner_radius=0; // Keep compartment corners straight for the grow-down section.
difference() {
    union() {
        make_box();
        make_complex_box();
        make_compartment_growdown(comp1, growdown_bottom_width, growdown_start_height);
        make_compartment_growdown(comp2, growdown_bottom_width, growdown_start_height);
        make_compartment_growdown(comp3, growdown_bottom_width, growdown_start_height);
    }

    make_compartment_u_cut(comp1, u_cut_size);
    make_compartment_u_cut(comp2, u_cut_size);
    make_compartment_u_cut(comp3, u_cut_size);
}

// Some notes on complex prints:
/* OpenSCAD experience is required to do pretty much any type of customization 
   or complex opperations. This will essentialy just make the containers within 
   one larger object with a single lid. Alternatly multiple boxes could be created 
   and joined together with translations to make a larger object with multiple lids. 
   Due to how variables are passed in OpenSCAD it can be tricky to get the parameters 
   set on the parent box and child boxes as you want. It is best to use global variable
   assignmets to set the child box parameters, then pass overrides to the `make_box()` 
   call yourself. (You have to set `show_box=false;` if you do this.)
  */
