module Merb
  module UsersHelper
    def user_xrds
      types = [
               OpenID::OPENID_2_0_TYPE,
               OpenID::OPENID_1_0_TYPE,
               OpenID::SREG_URI,
              ]

      headers['content-type'] = 'application/xrds+xml'
      render_xrds(types)
    end

    def idp_xrds
      types = [
               OpenID::OPENID_IDP_2_0_TYPE,
              ]

      headers['content-type'] = 'application/xrds+xml'
      render_xrds(types)
    end

    def render_xrds(types)
      type_str = ""

      types.each { |uri|
        type_str += "<Type>#{uri}</Type>\n      "
      }

      yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{type_str}
      <URI>#{absolute_url(:servers)}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS

      yadis
    end
  end
end # Merb