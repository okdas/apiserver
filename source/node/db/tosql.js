express= require('express')
async= require('async')
fs= require('fs')
yaml= require('js-yaml')

material= require('./materials.yaml')

ids= Object.keys(material.materials)


fs.writeFileSync('materials.sql', 'INSERT INTO `server_bukkit_material` (`id`, `titleRu`, `titleEn`, `imageUrl`, `enchantability`) VALUES\n')

ids.map(function(id, i) {
    m= material.materials[id]
    titleEn= m.title.en
    titleRu= m.title.ru
    imageUrl= m.image

    if (m.enchantability) {
        enchantability= m.enchantability
        enchantability= '"' + enchantability + '"'
    } else {
        enchantability= null
    }

    fs.appendFileSync('materials.sql', '  ("' + id + '", "' + titleRu + '", "' + titleEn + '", "' + imageUrl + '", ' + enchantability + '),\n')
})

fs.appendFileSync('materials.sql', ';')
