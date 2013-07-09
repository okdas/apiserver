exports.all= (req,res) ->
    res.send 200


exports.add= (req,res) ->
    res.send 200

exports.one= (req,res) ->
    res.locals.points= [
        {
            lat: '54.4125994638497'
            lng: '22.0096868276596'
            date: '10.10.2010 15.55.64'
            geocode: 'Here'
        }
        {
            lat: '54.117788'
            lng: '21.115577'
            date: '11.10.2010 15.55.64'
            geocode: 'I dunno'
        }
        {
            lat: '54.887937'
            lng: '58.843558'
            date: '12.10.2010 15.55.64'
            geocode: 'Ok'
        }
    ]
    res.render 'Car/one.jade'

exports.change= (req,res) ->
    res.send 200


exports.delete= (req,res) ->
    res.send 200

