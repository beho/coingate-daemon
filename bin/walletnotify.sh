#!/bin/bash

echo ${1} >> /tmp/transactions.out
exec curl -X POST http://127.0.0.1:9393/api/txs/btc\?txid\=${1}
