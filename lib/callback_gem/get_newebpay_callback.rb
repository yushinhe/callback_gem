# frozen_string_literal: true

require 'logger'

module CallbackGem
  class GetNewebpayCallback
    def initialize(app)
      @app = app
      @logger = Logger.new('log/newebpay_callback.log')
    end

    def call(env)
      status, headers, response = @app.call(env)
      if env['PATH_INFO'].include?('/newebpay') && env["REQUEST_METHOD"] == "POST"
        ## 取得回傳params
        request = Rack::Request.new(env)
        params = request.params
        data = params['TradeInfo']
        @newebpay =Newebpay::AES::Cryptographic.new(data)
        decrypted_trade_info = JSON.parse(@newebpay.decrypt)
        append_log(decrypted_trade_info)
      end
      [status, headers, response]
    end

    def append_log(data)
      status = data.dig('Status')
      merchant_no = data.dig('Result', 'MerchantOrderNo')
      trade_no = data.dig('Result', 'TradeNo')
      pay_time = data.dig('Result', 'PayTime')
      payment_type = data.dig('Result', 'PaymentType')
      @logger.info("status: #{status}, merchant_no: #{merchant_no}, trade_no: #{trade_no}, pay_time: #{pay_time}, payment_type: #{payment_type}")
    end
  end
end