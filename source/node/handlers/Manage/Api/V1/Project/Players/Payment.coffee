express= require 'express'





###
Методы API для платежей
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getPayments(maria.Payment)
    ,   (req, res) ->
            res.json 200, req.payments

    app.get '/:paymentId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getPayment(maria.Payment)
    ,   (req, res) ->
            res.json 200, req.payment

    app.put '/:paymentId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updatePayment(maria.Payment)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.payment

    app.delete '/:paymentId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deletePayment(maria.Payment)
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





getPayments= (Payment) -> (req, res, next) ->
    Payment.query req.maria, (err, payments) ->
        req.payments= payments or null
        return next err



getPayment= (Payment) -> (req, res, next) ->
    Payment.get req.params.paymentId, req.maria, (err, payment) ->
        req.payment= payment or null
        return next err



updatePayment= (Payment) -> (req, res, next) ->
    if req.body.status == 'pending'
        Payment.pending req.params.paymentId, req.maria, (err) ->
            return next err

    else if req.body.status == 'success'
        Payment.success req.params.paymentId, req.maria, (err) ->
            return next err

    else if req.body.status == 'failure'
        Payment.failure req.params.paymentId, req.maria, (err) ->
            return next err

    else
        return next 'update payment error, unknown status'



deletePayment= (Payment) -> (req, res, next) ->
    Payment.delete req.params.paymentId, req.maria, (err) ->
        return next err
