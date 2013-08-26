express= require 'express'
async= require 'async'

###
Методы API для работы c подписками аутентифицированного игрока.
###
app= module.exports= do express



app.get '/', (req, res, next) ->
    data= []

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 
                sql: "
                SELECT
                    Subscription.id,
                    Subscription.name,
                    SubscriptionPrice.score,
                    SubscriptionPrice.price
                FROM
                    ?? as Subscription
                JOIN
                    ?? as SubscriptionPrice ON SubscriptionPrice.subscriptionId = Subscription.id
                WHERE
                    Subscription.enabledAt IS NOT NULL
                "
                nestTables: true
            ,   ['subscription', 'subscription_price']
            ,   (err, rows) ->
                    if not err
                        subscriptionIds= {}
                        for row in rows
                            id= row.Subscription.id
                            subscription= subscriptionIds[id]
                            if not subscription
                                subscription= subscriptionIds[id]= row.Subscription
                                subscription.prices= {}
                                data.push subscription
                            score= row.SubscriptionPrice.score
                            subscription.prices[score]= row.SubscriptionPrice
                    return done err, conn

    ],  (err, conn) ->
            do conn.end if conn
            res.json 200, data



app.post '/:subscriptionId/subscribe', (req, res, next) ->

    playerId= req.user.id
    subscriptionId= req.params.subscriptionId

    async.waterfall [

        (done) -> # подключается к базе, начинает транзакцию
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        conn.transaction= true if not err
                        return done err, conn

        (conn, done) ->
            conn.query "
                SELECT

                SubscriptionPrice.price

                FROM
                ?? as SubscriptionPrice

                LEFT OUTER JOIN
                ?? as PlayerSubscriptionScore
                ON
                PlayerSubscriptionScore.playerId = ? AND
                PlayerSubscriptionScore.subscriptionId = SubscriptionPrice.subscriptionId

                WHERE
                SubscriptionPrice.subscriptionId = ? AND
                SubscriptionPrice.score <= IFNULL(PlayerSubscriptionScore.score, 0)

                ORDER BY SubscriptionPrice.score DESC

                LIMIT 1
                "
            ,   ['subscription_price', 'player_subscription', playerId, subscriptionId]
            ,   (err, rows) ->
                    price= do rows.shift if not err
                    return done err, price

        (conn, price, done) ->
            conn.query "
                UPDATE
                ?? as PlayerBalance

                SET
                PlayerBalance.amount = PlayerBalance.amount - ?

                WHERE
                PlayerBalance.playerId = ?
                "
            ,   ['player_balance']
            ,   (err, resp) ->
                    console.log resp

        (conn, done) ->
            conn.query "
                INSERT INTO
                ?? as PlayerSubscription

                SET
                PlayerSubscription.playerId = ?,
                PlayerSubscription.subscriptionId = ?,
                PlayerSubscription.expiredAt = NOW() + INTERVAL 1 MONTH
                "
            ,   ['player_subscription', playerId, subscriptionId]

    ],  (err, conn) ->