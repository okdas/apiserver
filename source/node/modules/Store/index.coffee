ItemFactory= require './services/ItemFactory'
PackageFactory= require './services/PackageFactory'

SqlQuery= require 'sql-query'

module.exports= class StoreModule

    constructor: (@db) ->

        q= new SqlQuery.Query 'mysql'

        @Item= new ItemFactory @db, q, 'store-item'
        @Package= new PackageFactory @db, q, 'store-package'