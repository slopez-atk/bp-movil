class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  require 'ipaddr'
  LOCAL_IPS = IPAddr.new("192.100.1.1/24").to_range


  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 3, period: 10) do |req|
    req.ip
  end

  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.ip}"
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    req.params['user'].try(:[], "email") if req.path == '/users/sign_in' &&
        req.post?
  end


  # OFFICE_IP = '192.100.1.1'
  # blocklist('bad_admin_ip') do |req|
  #   req.path.start_with?('/admin') && req.ip != OFFICE_IP
  # end

  blocklist('block local host') do |req|
    !LOCAL_IPS.include?(req.ip)
  end

  safelist('safelist_ips 1.2.3.4') do |req|
    '127.0.0.1' == req.ip
  end
end
