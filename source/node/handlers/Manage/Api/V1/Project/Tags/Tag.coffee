express= require 'express'




###
Методы API для платежей
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createTag(maria.Tag)
    ,   createTagTags(maria.TagTags)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.tag

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getTags(maria.Tag)
    ,   getTagsTags(maria.TagTags)
    ,   (req, res) ->
            res.json 200, req.tags

    app.get '/:tagId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getTag(maria.Tag)
    ,   getTagTags(maria.TagTags)
    ,   (req, res) ->
            res.json 200, req.tag

    app.put '/:tagId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateTag(maria.Tag)
    ,   updateTagTags(maria.TagTags)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.tag

    app.delete '/:tagId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteTag(maria.Tag)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err



createTag= (Tag) -> (req, res, next) ->
    console.log 'req', req.body
    newTag= new Tag req.body
    Tag.create newTag, req.maria, (err, tag) ->
        req.tag= tag or null
        return next err

createTagTags= (TagTags) -> (req, res, next) ->
    newTagTags= new TagTags req.body.parentTags
    TagTags.create req.tag.id, newTagTags, req.maria, (err, tags) ->
        req.tag.parenTags= tags or null
        return next err



getTags= (Tag) -> (req, res, next) ->
    Tag.query req.maria, (err, tags) ->
        req.tags= tags or null
        return next err

getTagsTags= (TagTags) -> (req, res, next) ->
    TagTags.query req.maria, (err, tags) ->
        req.tags.map (tag, i) ->
            req.tags[i].parentTags= []

            tags.map (row) ->
                if tag.id == row.childId
                    req.tags[i].parentTags.push
                        id: row.id
                        name: row.name
        return next err



getTag= (Tag) -> (req, res, next) ->
    Tag.get req.params.tagId, req.maria, (err, tag) ->
        req.tag= tag or null
        return next err

getTagTags= (TagTags) -> (req, res, next) ->
    TagTags.get req.params.tagId, req.maria, (err, tags) ->
        req.tag.parentTags= tags or null
        return next err



updateTag= (Tag) -> (req, res, next) ->
    newTag= new Tag req.body
    Tag.update req.params.tagId, newTag, req.maria, (err, tag) ->
        req.tag= tag or null
        return next err

updateTagTags= (TagTags) -> (req, res, next) ->
    newTagTags= new TagTags req.body.parentTags
    TagTags.create req.params.tagId, newTagTags, req.maria, (err, tags) ->
        req.tag.parenTags= tags or null
        return next err



deleteTag= (Tag) -> (req, res, next) ->
    Tag.delete req.params.tagId, req.maria, (err) ->
        return next err
