#!/usr/bin/env ruby

require 'getoptlong'
require 'net/http'
require 'uri'

pid_file = '/var/run/magnificent-monitor.pid'

# set up script's arguments
opts = GetoptLong.new(
  ['--server',    '-s', GetoptLong::REQUIRED_ARGUMENT],
  ['--interval',  '-i', GetoptLong::REQUIRED_ARGUMENT],
  ['--port',      '-p', GetoptLong::REQUIRED_ARGUMENT],
  ['--warn',      '-w', GetoptLong::REQUIRED_ARGUMENT],
  ['--log',       '-l', GetoptLong::REQUIRED_ARGUMENT],
  ['--daemon',    '-d', GetoptLong::NO_ARGUMENT],
  ['--quiet',     '-q', GetoptLong::NO_ARGUMENT],
  ['--kill',      '-k', GetoptLong::NO_ARGUMENT]
)

$settings = {
  :server   => 'localhost',
  :port     => 12345,
  :interval => 15,
  :daemon   => false,
  :warn     => 10,
  :quiet    => false
}

$status = {
  :last_connected => 'never',
  :last_200 => 'never',
  :connected => 'false'
}

kill = false

# attempt to read args
begin
  opts.each do |opt, arg|

    case opt
    when '--server' || '-s'     then $settings[:server] = arg
    when '--interval' || '-s'   then $settings[:interval] = arg.to_i
    when '--daemon' || '-d'     then $settings[:daemon] = true
    when '--port' || '-p'       then $settings[:port] = arg.to_i
    when '--quiet' || '-q'      then $settings[:quiet] = true
    when '--warn' || '-w'       then $settings[:warn] = arg.to_i
    when '--log' || '-l'        then $settings[:log] = arg
    when '--kill' || '-k'       then kill = true
    end

  end

# if invalid arguments, the each loop with throw an error
rescue
  exit 1
  # just for cleanliness
end

# ensure args are set logically
if $settings[:interval] <= 0
  puts "Invalid interval"
  exit 1
end

if $settings[:port] <= 0 || $settings[:port] > 65535
  puts "Invalid port"
  exit 1
end

if $settings[:warn] < 0
  puts "Invalid warning level"
  exit 1
end

# Daemon functions
if File.exist?(pid_file)

  pid = File.new(pid_file, 'r').read

  # check root
  if Process.uid != 0
    puts "Daemon is running and daemon operations require root"
    exit 1
  end

  # if we're not killing the daemon, the only valid option is to check it
  if !kill
    puts "Checking running daemon"
    Process.kill("USR1", pid.to_i)
    exit 0
  else
    puts "Terminating daemon"
    Process.kill("TERM", pid.to_i)
    exit 0
  end

end

# if we're here to kill, then we're done
if kill
  puts "Daemon not running"
  exit 0
end

if $settings[:daemon] && Process.uid != 0
  puts "Must be root to daemonize"
  exit 1
end


if $settings[:log]
  $settings[:log] = File.new($settings[:log], 'a+')
end

# set up easy logging function
def log(msg)
  if $settings[:log]
    $settings[:log].write(Time.now.inspect + " " + msg + "\n")
    $settings[:log].flush
  end
end

# build the request URI
url = 'http://' + $settings[:server] + ':' + $settings[:port].to_s
uri = URI.parse(url)

# create the http request
http_connection = Net::HTTP.new(uri.host, uri.port)
request_header = Net::HTTP::Get.new(uri.request_uri)

# try once to validate params
begin
  response = http_connection.request(request_header)
rescue
  puts "Could not connect to the server at #{url}\nAborting" if !$settings[:quiet]
  exit 1
end

puts "Server contacted at #{url}" if !$settings[:quiet]
puts "Will now commence checking every #{$settings[:interval].to_s} seconds" + ($settings[:daemon] ? " in the background" : "") if !$settings[:quiet]
log "Beginning to monitor server at " + url

$status[:connected] = true
$status[:last_connected] = Time.now.to_s
if response.code.to_i == 200
  $status[:last_200] = Time.now.to_s
end

# become a daemon if requested
if $settings[:daemon]

  # start daemon child
  child = fork
  if child
    # parent process
    pid_file = File.new(pid_file, "w")
    pid_file.write(child.to_s)
    exit
  else
    # child setup

    # Clean the pid file
    Signal.trap("TERM") do
      File.delete(pid_file)
      log "Shutting down"
      exit 0
    end

    Signal.trap("USR1") do
      if $status[:connected]
        puts "Currently connected"
      else
        puts "Not currently connected"
      end
      puts "Last Connected: #{$status[:last_connected]}"
      puts "Last 200-OK:    #{$status[:last_200]}"
    end

  end
end

# now we begin watching the server
resp_fail = 0
last_warn = 0
loop do

  sleep $settings[:interval]

  # poll the server
  begin
    response = http_connection.request(request_header)
  rescue
    if $status[:connected]
      puts "Server contact lost!" if !$settings[:quiet] && !$settings[:daemon]
      log "Server connection lost"
      `run-parts ./hooks/fail.d`
      $status[:connected] = false
    end
    next
  end

  # response received
  if !$status[:connected]
    log "Connection reestablised"
    `run-parts ./hooks/resume.d`
    $status[:connected] = true
  end

  $status[:last_connected] = Time.now.to_s

  # on fail
  if response.code.to_i != 200
    resp_fail += 1

    # if we're at warning levels
    if resp_fail - last_warn >= $settings[:warn]
      log "Server request failed " + resp_fail.to_s + " times"
      `run-parts ./hooks/warn.d`
      last_warn = resp_fail
    end

  # on success
  else
    resp_fail = 0
    last_warn = 0
    $status[:last_200] = Time.now.to_s
  end

end

exit 0
