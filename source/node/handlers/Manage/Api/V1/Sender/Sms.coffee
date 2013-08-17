express= require 'express'
request= require 'request'



id= 'id'
key= 'key'
from= 'from'



###
Методы API для рассылки SMS
###
app= module.exports= do express



###
Отсылает сообщение на кучу номеров
###
app.post '/', (req, res, next) ->
    console.log req.body
    return res.json 400, null if req.body.to.length == 0
    return res.json 400, null if not req.body.text

    smsArr= []
    req.body.to.map (val, i) ->
        smsArr.push
            to: val
            from: from
            text: req.body.text


    request
        url: "http://bytehand.com:3800/send_multi?id=#{id}&key=#{key}"
        method: 'post'
        json: smsArr
    , (e, r, body) ->
        return res.json 400, e if e
        return res.json body
