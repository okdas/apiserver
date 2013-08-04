app= angular.module 'project.store'

app.config ($routeProvider) ->
    # Магазин

    $routeProvider.when '/store',
        templateUrl: 'project/store/', controller: 'StoreViewCtrl'



    # Магазин. Предметы

    $routeProvider.when '/store/items/list',
        templateUrl: 'project/store/items/', controller: 'StoreItemsListCtrl'

    $routeProvider.when '/store/items/item/create',
        templateUrl: 'project/store/items/item/forms/create/', controller: 'StoreItemsFormCtrl'

    $routeProvider.when '/store/items/item/update/:itemId',
        templateUrl: 'project/store/items/item/forms/update/', controller: 'StoreItemsFormCtrl'



    # Магазин. Чары

    $routeProvider.when '/store/enchantments/list',
        templateUrl: 'project/store/enchantments/', controller: 'StoreEnchantmentsCtrl'

    $routeProvider.when '/store/enchantments/create',
        templateUrl: 'project/store/enchantments/enchantment/forms/create', controller: 'StoreEnchantmentsFormCtrl'

    $routeProvider.when '/store/enchantments/:enchantmentId',
        templateUrl:'project/store/enchantments/enchantment/forms/update', controller:'StoreEnchantmentsFormCtrl'

