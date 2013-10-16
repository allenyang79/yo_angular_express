express = require('express')
http = require('http')
path = require('path')
moment=require('moment')
stringify = require('stringify')

o=
	name:'bill'
	gender:'male'

console.dir o
console.log JSON.stringify(o)
