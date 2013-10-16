express = require 'express'
http = require 'http'
path = require 'path'
moment=require 'moment'


d=new Date;
console.log d.getTime()
console.log moment.unix(d*0.001).format('YYYY MM DD')

