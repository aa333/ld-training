Phaser = require('./phaser-shim.coffee')

class MaterialManager
     init: () ->
        @slime = game.physics.p2.createMaterial('slime');
        @metal = game.physics.p2.createMaterial('metal');
        @floor = game.physics.p2.createMaterial('floor');
        @wood = game.physics.p2.createMaterial('wood');
        @setupContact(@slime, @floor, 0.8, 0.01, 1e7, 3, 1e7, 3, 0)
        @setupContact(@slime, @wood, 0.95, 0.01, 1e7, 3, 1e7, 3, 0)
        @setupContact(@wood, @floor, 0.9, 0.2, 1e7, 3, 1e7, 3, 0)
        
      setupContact: (mat1,mat2,fr,rest,stif,rel,fStif,fRel,sfv) =>
        contactMaterial = game.physics.p2.createContactMaterial(mat1, mat2) 
        contactMaterial.friction = fr;     # Friction to use in the contact of these two materials.
        contactMaterial.restitution = rest;  # Restitution (i.e. how bouncy it is!) to use in the contact of these two materials.
        contactMaterial.stiffness = stif;    # Stiffness of the resulting ContactEquation that this ContactMaterial generate.
        contactMaterial.relaxation = rel;     # Relaxation of the resulting ContactEquation that this ContactMaterial generate.
        contactMaterial.frictionStiffness = fStif;    # Stiffness of the resulting FrictionEquation that this ContactMaterial generate.
        contactMaterial.frictionRelaxation = fRel;     # Relaxation of the resulting FrictionEquation that this ContactMaterial generate.
        contactMaterial.surfaceVelocity = sfv;        
module.exports = new MaterialManager()
   
    