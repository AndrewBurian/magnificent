#!/usr/bin/env ruby

require 'logger'
require 'json'
require 'net/http'

class PingTheThing
    def initialize(uri, pingFrequency, logFrequency, logFile)
        @uri = uri
        @pingFrequency = pingFrequency
        @logFrequency = logFrequency
        @logFile = logFile
        @logger = Logger.new(logFile)
        @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{datetime}: #{msg}\n"
        end
        @failedRequests = 0
        @successfulRequests = 0
        @monitorFlag = true
        @loopThread = nil
    end

    def handleResponse(response)
        case response.to_i
        when 200
            @successfulRequests += 1
        when 500
            @failedRequests += 1
        end
    end

    def pingLoop
        begin
            @loopThread = Thread.new do
                loopCounter = 1
                while @monitorFlag == true do
                    httpResponse = Net::HTTP.get_response(@uri)
                    handleResponse(httpResponse.code)
                    if(loopCounter == @logFrequency)
                        now = Time.now
                        puts "#{now} Failed requests: #{@failedRequests}, succesful requests: #{@successfulRequests}."
                        @logger.info("Failed requests: #{@failedRequests}, succesful requests: #{@successfulRequests}.")
                        loopCounter = 0
                    end
                    loopCounter += 1
                    sleep @pingFrequency
                end
            end
            @loopThread.join
        rescue Interrupt
            self.stopMonitoring
        end
    end

    def startMonitoring
        @monitorFlag = true
        @logger.info("Monitoring started!")
        pingLoop
    end

    def stopMonitoring
        @logger.info("Monitoring is stopping!")
        @loopThread.exit
        @monitorFlag = false
        @logger.info("Failed requests: #{@failedRequests}, succesful requests: #{@successfulRequests}.")
    end
end

def main
    monitorTheThing = nil
    begin
        configFile = File.read('config.json') #read file into a string
        config = JSON.parse(configFile)
        uri = URI(config['url'])
        pingFrequency = config['pingFrequency'].to_i
        logFrequency = config['logFrequency'].to_i
        logFile = config['logFile']
        #create the object
        monitorTheThing = PingTheThing.new(uri, pingFrequency, logFrequency, logFile)
    rescue Errno::ENOENT
        STDERR.puts "Error: config file not found."
    end
    monitorTheThing.startMonitoring
end

main
