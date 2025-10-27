require 'spec_helper'

module Geonames
  describe WebService do
    describe ".make_request" do
      it "uses a custom User-Agent header" do
        expect(Net::HTTP::Get).to receive(:new).with(anything, hash_including('User-Agent' => USER_AGENT))
        allow(Net::HTTP).to receive(:start)
        WebService.make_request '/foo?a=a'
      end
    end
  end
end
