include    <Ultimate_Box_Generator.scad>;
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
box_corner_radius=1; // Add a rounding affect to the corners of the box. Anything over `wall` will cause structure and lid problems.
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
internal_type=1; // Internal structure, see above.
//internal_rotate=false; // On lid axis or rotate to opposite.
internal_size_deep=comp_size_deep/2; // How far into the box to start the internal structure. Should be `comp_size_deep/2` for type 1-2, `wall` for 3, or comp_size_deep for type 4-5.
internal_size_circle=internal_type==1 ? internal_size_deep : internal_size_deep * 2 / sqrt(3); // Use this calculation, or the shorter comp_size for type 4-5.
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
comp_size_x = 188.2/2; // external size add 2*wall to this
comp_size_y = 64;    // external width add 2*wall to this
comp_size_deep = 28; // external height add 2*wall to thist

// internal_wall=0.8;
// make the external box with no internal curves
//internal_size_deep=comp_size_deep  ;
make_box(internal_type=1);
// internal_type=1;
// internal_size_deep=comp_size_deep  ;
// comp2=make_object( x=32.2, y=31.6, z=20, offset_x=90, offset_y=0, repeat_x=3, repeat_y=2, color="Blue");

// complex_box=[
//    comp2   
// ];
// // make the internal compartments
// make_complex_box();

// Some notes on complex prints:
/* OpenSCAD experience is required to do pretty much any type of customization or 
   complex opperations. This will essentialy just make the containers within one 
   larger object with a single lid. Alternatly multiple boxes could be created and 
   joined together with translations to make a larger object with multiple lids. 
   Due to how variables are passed in OpenSCAD it can be tricky to get the parameters 
   set on the parent box and child boxes as you want. It is best to use global variable
   assignmets to set the child box parameters, then pass overrides to the `make_box()` 
   call yourself. (You have to set `show_box=false;` if you do this.)
  */
