app= angular.module 'project.store'



### Фильтр чар в редакторе для предмета.
###
app.filter 'filterItemEnchantment', ->
    (enchantments, item) ->
        filtered= []
        angular.forEach enchantments, (enchantment) ->
            found= false
            angular.forEach item.enchantments, (e) ->
                found= true if e.id == enchantment.id

            filtered.push enchantment if not found
        filtered

