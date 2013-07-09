module.exports= (schema) ->
    passport= require 'passport'
    GoogleStrategy= require('passport-github').Strategy

    # Setting for Google servers
    strategyOptions=
        clientID: process.env.npm_package_config_auth_github_id
        clientSecret: process.env.npm_package_config_auth_github_secret
        callbackURL: process.env.npm_package_config_url + process.env.npm_package_config_auth_github_callback


    passport.serializeUser (user, done) ->
        done null, user


    passport.deserializeUser (obj, done) ->
        schema.findOne {googleId: obj.id}, (err, user) ->
            if err
                done err, null
            else
                done null, user


    # Applying strategy
    passport.use new GoogleStrategy strategyOptions, (token, tokenSecret, profile, done) ->
        schema.findOne {googleId: profile.id}, (err,user) ->
            if err
                done err, null
            else if user
                user.token= token
                schema.save user, (err) ->
                    if err
                        done err, null
                    else
                        done null, profile
            else
                newProfile= profile._json
                newProfile.googleId= profile.id
                newProfile.token= token
                delete newProfile.id

                outProfile= {}
                Object.keys(schema.Schema.properties).map (value) ->
                    if schema.Schema.properties[value].enumerable
                        outProfile[value]= newProfile[value]

                outProfile['created']= new Date
                newUser= new schema.Schema outProfile

                schema.save newUser, (err) ->
                    if err
                        done err, null
                    else
                        done null, profile

    passport





exports.login= (passport) ->
    passport.authenticate 'google',
        scope: [
            'https://www.googleapis.com/auth/userinfo.profile'
            'https://www.googleapis.com/auth/userinfo.email'
        ]




exports.callback= (passport) ->
    passport.authenticate 'google',
        failureRedirect: '/'
        successRedirect: '/'




exports.isAuth= (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.redirect '/'


exports.isNoAuth= (req, res, next) ->
    if req.isUnauthenticated()
        next()
    else
        res.redirect '/'



exports.logout= (req, res) ->
    req.logout()
    res.redirect '/'

