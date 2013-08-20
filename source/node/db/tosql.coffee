express= require('express')
async= require('async')
fs= require('fs')
yaml= require('js-yaml')

material= require('./materials.yaml')

ids= Object.keys(material.materials)


fs.writeFileSync('materials.sql', 'INSERT INTO `material` (`id`, `name`, `materialId`, `title`, `enchantability`) VALUES\n')

ids.map(function(materialId, i) {
    m= material.materials[materialId]
    name= m.title.en.replace(/ /g, '-').toLowerCase()
    title= m.title.ru
    if (m.enchantability) {
        enchantability= m.enchantability
        enchantability= "'" + enchantability + "'"
    } else {
        enchantability= null
    }

    fs.appendFileSync('materials.sql', "  (" + ++i + ", '" + name + "', '" + materialId + "', '" + title + "', " + enchantability + "),\n")
})

fs.appendFileSync('materials.sql', ';')

