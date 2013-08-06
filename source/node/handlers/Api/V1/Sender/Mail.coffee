express= require 'express'
nodemailer= require 'nodemailer'


mail= 'bot@awesome39.com'
passwordMail= '+^mMz&S1c.J>'




app= module.exports= do express



###
Отсылает письмо братюням
###
app.post '/', (req, res, next) ->
#    return res.json 400, null if not req.body.to
#    return res.json 400, null if not req.body.text

    smtp= nodemailer.createTransport 'SMTP',
        service: 'Gmail'
        auth:
            user: mail
            pass: passwordMail


    mail=
        bcc: 'level.is03@gmail.com'
        subject: req.body.subject
        text: 'Test passed'
        headers:
            precedence: 'bulk'

    smtp.sendMail mail, (err, resp) ->
        return res.json 400, err if err
        return res.json resp


