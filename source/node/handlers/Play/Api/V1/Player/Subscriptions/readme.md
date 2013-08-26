# Подписки игрока



## 1. Оформление или продление подписки:


### 1.1 Начать транзакцию
Запрос строгого режима и начала транзакции:
```sql
SET sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE";
START TRANSACTION;
```


### 1.2 Узнать стоимость подписки для игрока
Запрос стоимости оформления или продления подписки для игрока:
```sql
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

LIMIT 1;
```


### 1.3 Списать стоимость подписки со счета игрока
Запрос на списание стоимости подписки со счета игрока:
```sql
UPDATE
?? as PlayerBalance

SET
PlayerBalance.amount = PlayerBalance.amount - ?

WHERE
PlayerBalance.playerId = ?;
```


### 1.4 Создать запись о подписке в истории подписок игрока
Запрос на создание записи о подписке в истории подписок игрока:
```sql
INSERT INTO
?? as PlayerSubscription

SET
PlayerSubscription.playerId = ?,
PlayerSubscription.subscriptionId = ?,
PlayerSubscription.expiredAt = NOW() + INTERVAL 1 MONTH;
```


### 1.5 Увеличить счетчик подписок игрока:
Запрос на увеличения счетчика кол-ва очков за оформление подписки для игрока:
```sql
INSERT INTO
?? as PlayerSubscriptionScore

SET
PlayerSubscriptionScore.playerId = ?,
PlayerSubscriptionScore.subscriptionId = ?,
PlayerSubscriptionScore.score = 1

ON DUPLICATE KEY UPDATE
PlayerSubscriptionScore.score = PlayerSubscriptionScore.score + 1;
```


### 1.6 Завершить транзакцию
Запрос завершения транзакции:
```sql
COMMIT;
```
