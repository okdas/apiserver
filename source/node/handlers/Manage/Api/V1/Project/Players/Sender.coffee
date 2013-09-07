express= require 'express'
request= require 'request'





###
Методы API для рассылки SMS и Email
###
app= module.exports= do express
app.on 'mount', (parent) ->
    cfg= parent.get 'config'



    smsId= cfg.sender.sms.id
    smsKey= cfg.sender.sms.key
    smsFrom= cfg.sender.sms.from

    emailAddress= cfg.sender.email.address
    emailPassword= cfg.sender.email.password



    app.post '/sms'
    ,   access
    ,   sendSms
    ,   (req, res) ->
            res.json 200



    app.post '/email'
    ,   access
    ,   sendEmail
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next



###
Отсылает сообщение на кучу номеров
###
sendSms= (req, res, next) ->
    return next 'there are no numbers' if req.body.to.length == 0
    return next 'text is empty' if not req.body.text

    smsArr= []

    req.body.to.map (val, i) ->
        smsArr.push
            to: val
            from: smsFrom
            text: req.body.text


    request
        url: "http://bytehand.com:3800/send_multi?id=#{smsId}&key=#{smsKey}"
        method: 'post'
        json: smsArr

    ,   (err, resp, body) ->
            return next err





sendEmail= (req, res, next) ->
    return next 'there are no numbers' if req.body.to.length == 0
    return next 'text is empty' if not req.body.text


    smtp= nodemailer.createTransport 'SMTP',
        service: 'Gmail'
        auth:
            user: emailAddress
            pass: emailPassword

    mail=
        bcc: req.body.to.join ','
        subject: req.body.subject
        text: req.body.text
        headers:
            precedence: 'bulk'


    smtp.sendMail mail, (err, resp) ->
        return next err
