#!/usr/local/rvm/rubies/ruby-2.1.5/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'logger'


src_email, dst_email , user= ARGV
mime_str = STDIN.read

$logger = Logger.new( '/var/log/mail.log')
$logger.info "Starting %s,%s,%s with Mime:%s" % [src_email,dst_email,user,mime_str]

r = Redis.new(:host => "redis")

r.rpush 'faxes',mime_str
