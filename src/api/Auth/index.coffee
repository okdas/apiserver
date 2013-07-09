exports.config = ->
    passport = require 'passport'
    GoogleStrategy = require('passport-google-oauth').OAuth2Strategy



    strategyOptions =
        clientID: process.env.npm_package_config_auth_google_id
        clientSecret: process.env.npm_package_config_auth_google_secret
        callbackURL: process.env.npm_package_config_url + process.env.npm_package_config_auth_google_callback

    
    passport.serializeUser (user, done) ->
        done null, user.id

    
    passport.deserializeUser (obj, done) ->
        console.log 'DESER ', obj
        done null, obj

    
    # возвращаем стартегию и применяем в init функции модуля
    strategyGoogleOAuth = new GoogleStrategy strategyOptions, (token, tokenSecret, profile, done) ->
        console.log 'Google ', token, profile
        done null, profile

    
    passport.use(strategyGoogleOAuth)



exports.login= (passport) ->
    passport.authenticate 'google',
        scope: [
            'https://www.googleapis.com/auth/userinfo.profile'
            'https://www.googleapis.com/auth/drive.readonly'
        ]



exports.callback = (passport) ->
    passport.authenticate 'google',
        failureRedirect: '/gitweb/'
        successRedirect: '/'



#middlware авторизирован ли наш пользователь
exports.isAuth = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.redirect '/'


exports.isNoAuth = (req, res, next) ->
    if req.isUnauthenticated()
        next()
    else
        res.redirect '/'



exports.logout= (req, res) ->
    req.logout()
    res.redirect '/'
