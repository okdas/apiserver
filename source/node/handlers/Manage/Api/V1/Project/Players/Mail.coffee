express= require 'express'
nodemailer= require 'nodemailer'


mail= 'admin@google.com'
passwordMail= 'password123'




app= module.exports= do express



###
Отсылает письмо братюням
###
app.post '/', (req, res, next) ->
    return res.json 400, null if req.body.to.length == 0
    return res.json 400, null if not req.body.text


    smtp= nodemailer.createTransport 'SMTP',
        service: 'Gmail'
        auth:
            user: mail
            pass: passwordMail

    mail=
        bcc: req.body.to.join ','
        subject: req.body.subject
        text: req.body.text
        headers:
            precedence: 'bulk'


    smtp.sendMail mail, (err, resp) ->
        return res.json 400, err if err
        return res.json resp
